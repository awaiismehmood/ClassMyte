import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/features/classes/providers/class_providers.dart';
import 'package:classmyte/features/sms/providers/sms_providers.dart';
import 'package:classmyte/features/students/models/student_model.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

final attendanceStateProvider = StateProvider<Map<String, bool>>((ref) => {});
final selectedAttendanceClassProvider = StateProvider.autoDispose<String?>((ref) => null);
final completedClassesProvider = StateNotifierProvider<CompletedClassesNotifier, Set<String>>((ref) {
  return CompletedClassesNotifier();
});

class CompletedClassesNotifier extends StateNotifier<Set<String>> {
  CompletedClassesNotifier() : super({}) {
    _loadFromPrefs();
  }

  static const _key = 'completed_attendance_classes';
  static const _dateKey = 'last_attendance_date';

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastDate = prefs.getString(_dateKey);

    if (lastDate != today) {
      // New day, reset
      await prefs.remove(_key);
      await prefs.setString(_dateKey, today);
      state = {};
    } else {
      final list = prefs.getStringList(_key) ?? [];
      state = list.toSet();
    }
  }

  Future<void> markAsCompleted(String className) async {
    final prefs = await SharedPreferences.getInstance();
    state = {...state, className};
    await prefs.setStringList(_key, state.toList());
  }

  Future<void> markAsIncomplete(String className) async {
    final prefs = await SharedPreferences.getInstance();
    state = state.where((c) => c != className).toSet();
    await prefs.setStringList(_key, state.toList());
  }
}

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentDataProvider);
    final selectedClass = ref.watch(selectedAttendanceClassProvider);
    final classes = ref.watch(filteredClassesProvider);
    final completedClasses = ref.watch(completedClassesProvider);
    final attendance = ref.watch(attendanceStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const CustomHeader(title: 'Attendance'),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.dynamicBackgroundGradient(isDark),
              ),
              child: studentsAsync.when(
                data: (students) {
                  if (students.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  // Class Selector Header
                  return Column(
                    children: [
                      _buildClassSelector(context, ref, classes, selectedClass, completedClasses),
                      if (selectedClass != null) ...[
                        _buildHeader(context, students.where((s) => s.className == selectedClass).toList(), attendance, completedClasses.contains(selectedClass)),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: students.where((s) => s.className == selectedClass).length,
                            itemBuilder: (context, index) {
                              final filtered = students.where((s) => s.className == selectedClass).toList();
                              final student = filtered[index];
                              final isAbsent = attendance[student.id] ?? false;
                              return _buildStudentTile(context, ref, student, isAbsent);
                            },
                          ),
                        ),
                        _buildActionFooter(context, ref, students, attendance, selectedClass, completedClasses.contains(selectedClass)),
                      ] else ...[
                        const Spacer(),
                        _buildClassSelectPrompt(context),
                        const Spacer(),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector(BuildContext context, WidgetRef ref, List<String> classes, String? selectedClass, Set<String> completed) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final className = classes[index];
          final isSelected = className == selectedClass;
          final isCompleted = completed.contains(className);
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              avatar: isCompleted ? const Icon(Icons.check_circle, size: 16, color: Colors.green) : null,
              label: Text(className, style: GoogleFonts.outfit(color: isSelected ? Colors.white : (isCompleted ? Colors.green : Colors.black87))),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: isCompleted ? Colors.green.withOpacity(0.1) : Colors.white,
              onSelected: (selected) {
                ref.read(selectedAttendanceClassProvider.notifier).state = selected ? className : null;
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassSelectPrompt(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 64, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Select a class to start marking attendance',
            style: GoogleFonts.outfit(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Student> students, Map<String, bool> attendance, bool isCompleted) {
    final absentCount = attendance.entries.where((e) => e.value && students.any((s) => s.id == e.key)).length;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCompleted ? 'Marked as Done' : 'Today\'s Summary',
                style: GoogleFonts.outfit(fontSize: 14, color: isCompleted ? Colors.green : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
              Text(
                '$absentCount Absentees / ${students.length} Total',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
        ],
      ),
    );
  }

  Widget _buildStudentTile(BuildContext context, WidgetRef ref, Student student, bool isAbsent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(student.name[0], style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(student.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text(student.className, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusButton(
              context: context,
              label: 'P',
              isActive: !isAbsent,
              activeColor: Colors.green,
              onTap: () {
                final current = Map<String, bool>.from(ref.read(attendanceStateProvider));
                current[student.id] = false;
                ref.read(attendanceStateProvider.notifier).state = current;
              },
            ),
            const SizedBox(width: 8),
            _buildStatusButton(
              context: context,
              label: 'A',
              isActive: isAbsent,
              activeColor: Colors.redAccent,
              onTap: () {
                final current = Map<String, bool>.from(ref.read(attendanceStateProvider));
                current[student.id] = true;
                ref.read(attendanceStateProvider.notifier).state = current;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton({
    required BuildContext context,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context, WidgetRef ref, List<Student> allStudents, Map<String, bool> attendance, String? selectedClass, bool isCompleted) {
    final absentees = allStudents.where((s) => s.className == selectedClass && attendance[s.id] == true).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Mark Class as Done',
                  color: Colors.green,
                  onPressed: () {
                    if (selectedClass != null) {
                      ref.read(completedClassesProvider.notifier).markAsCompleted(selectedClass);
                    }
                  },
                ),
              ),
            if (!isCompleted) const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Send SMS to Absentees (${absentees.length})',
                onPressed: absentees.isEmpty ? null : () {
                  ref.read(preSelectedContactsProvider.notifier).state = absentees;
                  context.push('/sms', extra: 'Attendance'); 
                },
              ),
            ),
            if (isCompleted) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.read(completedClassesProvider.notifier).markAsIncomplete(selectedClass!),
                child: Text('Edit Attendance (Reset Done Status)', style: GoogleFonts.outfit(color: Colors.blue)),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text('No students found. Add students first.', style: GoogleFonts.outfit()),
    );
  }
}
