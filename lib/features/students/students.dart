import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/features/students/addcontact_dialouge.dart';
import 'package:classmyte/features/students/filter_dialouge.dart';
import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/core/services/functional.dart';
import 'package:classmyte/features/sms/whatsapp_msg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentContactsScreen extends ConsumerWidget {
  const StudentContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentDataAsync = ref.watch(studentDataProvider);
    final filteredStudents = ref.watch(filteredStudentsProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremiumUser;
    final adManager = ref.read(adManagerProvider);
    final selectedClasses = ref.watch(selectedClassesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomHeader(
            title: 'Students',
            rightActions: [
              studentDataAsync.when(
                data: (allStudents) => _buildCircleAction(
                  icon: Icons.filter_list,
                  onTap: () {
                    FilterDialog.show(
                      context,
                      allClasses: getUniqueClasses(allStudents),
                      selectedClasses: selectedClasses,
                      onApply: (newClasses) => ref.read(selectedClassesProvider.notifier).state = newClasses,
                    );
                  },
                ),
                error: (_, __) => const SizedBox(),
                loading: () => const SizedBox(),
              ),
              const SizedBox(width: 8),
              _buildCircleAction(
                icon: Icons.add,
                onTap: () => showAddContactDialog(context, () {
                  ref.invalidate(studentDataProvider);
                }),
              ),
            ],
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) => ref.read(studentSearchQueryProvider.notifier).state = v,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _buildBadge('Total: ${studentDataAsync.value?.length ?? 0}', AppColors.primary),
                        const SizedBox(width: 8),
                        _buildBadge('Filtered: ${filteredStudents.length}', Colors.black54),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: studentDataAsync.when(
                      data: (_) => filteredStudents.isEmpty
                          ? Center(child: Text('No students found', style: GoogleFonts.outfit(color: AppColors.textSecondary)))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                return _buildStudentCard(context, ref, student);
                              },
                            ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('Error: $e')),
                    ),
                  ),
                  if (!isPremium) adManager.displayBannerAd(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(text, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildStudentCard(BuildContext context, WidgetRef ref, Map<String, String> student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(student['name']?[0] ?? '?', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
        title: Text(student['name'] ?? 'Unknown', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text('Class: ${student['class'] ?? 'N/A'}', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
        onTap: () async {
          context.push('/students/details', extra: student);
          ref.invalidate(studentDataProvider);
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.phone, color: AppColors.primary),
              onPressed: () => makeCall(student['phoneNumber']!),
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble, color: Colors.green),
              onPressed: () => WhatsAppMessaging().sendWhatsAppMessageIndividually(student['phoneNumber']!),
            ),
          ],
        ),
      ),
    );
  }
}
