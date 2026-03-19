import 'package:classmyte/core/data/edit_contacts.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_bottom_sheet.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:classmyte/features/students/models/student_edit_state.dart';
import 'package:classmyte/core/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentDetailSheet extends ConsumerWidget {
  final Map<String, String> student;

  const StudentDetailSheet({super.key, required this.student});

  static void show(BuildContext context, Map<String, String> student) {
    CustomBottomSheet.show(
      context,
      title: 'Student Details',
      child: StudentDetailSheet(student: student),
    );
  }

  void _deleteStudent(BuildContext context, WidgetRef ref) async {
    // Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete Contact', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove this student from your list?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.outfit(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes, Delete', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirmed == true) {
      await EditContactService.deleteContact(student['id'] ?? '');
      ref.invalidate(studentDataProvider);
      if (context.mounted) {
        Navigator.pop(context); // Close bottom sheet
      }
    }
  }

  void _saveChanges(BuildContext context, WidgetRef ref, StudentEditState state) async {
    ref.read(studentEditProvider(student).notifier).setLoading(true);
    await EditContactService.updateContact(
      student['id'] ?? '',
      state.name,
      state.className,
      state.phoneNumber,
      state.fatherName,
      state.dob,
      state.admissionDate,
      state.altNumber,
    );
    ref.read(studentEditProvider(student).notifier).toggleEditable();
    ref.read(studentEditProvider(student).notifier).setLoading(false);
    ref.invalidate(studentDataProvider);
    // Optionally close or stay. The user said "the save does this too" implying it might finish the task.
  }

  void _selectDate(BuildContext context, WidgetRef ref, String field) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final dateStr = "${picked.toLocal()}".split(' ')[0];
      ref.read(studentEditProvider(student).notifier).updateField(field, dateStr);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentEditProvider(student));

    return Column(
      children: [
        // Header info with Edit/Delete buttons
        Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                state.name.isNotEmpty ? state.name[0].toUpperCase() : '?',
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    'Class ${state.className}',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            // Edit Button
            IconButton(
              icon: Icon(state.isEditable ? Icons.check_circle : Icons.edit_note, color: state.isEditable ? Colors.green : AppColors.primary, size: 28),
              onPressed: () {
                if (state.isEditable) {
                  _saveChanges(context, ref, state);
                } else {
                  ref.read(studentEditProvider(student).notifier).toggleEditable();
                }
              },
            ),
            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
              onPressed: () => _deleteStudent(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Detail Fields
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.02), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary.withOpacity(0.05))),
          child: Column(
            children: [
              _buildField(ref, 'Name', state.name, 'name', state.isEditable),
              _buildField(ref, 'Class', state.className, 'class', state.isEditable),
              _buildField(ref, 'Phone#', state.phoneNumber, 'phoneNumber', state.isEditable, isPhone: true),
              _buildField(ref, 'Alt#', state.altNumber, 'altNumber', state.isEditable, isPhone: true),
              _buildField(ref, 'Father Name', state.fatherName, 'fatherName', state.isEditable),
              _buildDateField(context, ref, 'DOB', state.dob, 'dob', state.isEditable),
              _buildDateField(context, ref, 'Admission Date', state.admissionDate, 'admissionDate', state.isEditable),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Optional Save Button at the bottom if in edit mode
        if (state.isEditable)
          CustomButton(
            text: state.isLoading ? 'Saving...' : 'Save Updates',
            isLoading: state.isLoading,
            onPressed: () => _saveChanges(context, ref, state),
          ),
      ],
    );
  }

  Widget _buildField(WidgetRef ref, String label, String value, String field, bool isEditable, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (isEditable)
            TextField(
              controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
              onChanged: (v) => ref.read(studentEditProvider(student).notifier).updateField(field, v),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1))),
              ),
              style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textPrimary),
              keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            )
          else
            Text(value.isNotEmpty ? value : '-', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, WidgetRef ref, String label, String value, String field, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: isEditable ? () => _selectDate(context, ref, field) : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isEditable ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isEditable ? Border.all(color: AppColors.primary.withOpacity(0.1)) : null,
              ),
              child: Text(
                value.isNotEmpty ? value : '-',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: isEditable ? AppColors.primary : AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
