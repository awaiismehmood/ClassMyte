import 'package:classmyte/core/data/edit_contacts.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_dialog.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/features/students/models/student_edit_state.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:classmyte/core/services/student_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentDetailsScreen extends ConsumerWidget {
  final Map<String, String> student;

  const StudentDetailsScreen({super.key, required this.student});

  void _deleteStudent(BuildContext context, WidgetRef ref) async {
    CustomDialog.show(
      context: context,
      title: 'Delete Student',
      subtitle: 'Are you sure you want to delete this contact?',
      confirmText: 'Yes, Delete',
      confirmColor: Colors.redAccent,
      onConfirm: () async {
        try {
          await EditContactService.deleteContact(student['id'] ?? '');
          ref.invalidate(studentDataProvider);
          if (context.mounted) {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Go back to student list
            CustomSnackBar.showSuccess(context, 'Student deleted successfully');
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context); // Close dialog
            CustomSnackBar.showError(context, 'Error deleting student');
          }
        }
      },
    );
  }

  void _saveChanges(
      BuildContext context, WidgetRef ref, StudentEditState state) async {
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
      state.isActive ? 'Active' : 'Inactive',
    );
    ref.read(studentEditProvider(student).notifier).toggleEditable();
    ref.read(studentEditProvider(student).notifier).setLoading(false);
    ref.invalidate(studentDataProvider);
    if (context.mounted) Navigator.pop(context);
  }

  void _selectDate(BuildContext context, WidgetRef ref, String field) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final dateStr = "${picked.toLocal()}".split(' ')[0];
      ref
          .read(studentEditProvider(student).notifier)
          .updateField(field, dateStr);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentEditProvider(student));

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Details',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: AppColors.primaryGradient)),
        actions: [
          IconButton(
            icon: Icon(state.isEditable ? Icons.save : Icons.edit,
                color: Colors.white),
            onPressed: state.isEditable
                ? () => _saveChanges(context, ref, state)
                : () => ref
                    .read(studentEditProvider(student).notifier)
                    .toggleEditable(),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        state.name.isNotEmpty
                            ? state.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24)),
                      child: Column(
                        children: [
                          _buildDetailRow(ref, 'Name', state.name, 'name', state.isEditable),
                          _buildDetailRow(ref, 'Father Name', state.fatherName, 'fatherName', state.isEditable),
                          _buildDetailRow(ref, 'Class', state.className, 'class', state.isEditable),
                          _buildDetailRow(ref, 'Phone', state.phoneNumber, 'phoneNumber', state.isEditable, isPhone: true),
                          _buildDetailRow(ref, 'Alternate', state.altNumber, 'altNumber', state.isEditable, isPhone: true),
                          _buildDateRow(context, ref, 'Date of Birth', state.dob, 'dob', state.isEditable, showAge: true),
                          _buildDateRow(context, ref, 'Admission Date', state.admissionDate, 'admissionDate', state.isEditable),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _deleteStudent(context, ref),
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.white),
                      label: const Text('Delete Student',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDetailRow(WidgetRef ref, String label, String value, String field,
      bool isEditable, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          isEditable
              ? TextField(
                  controller: TextEditingController(text: value)
                    ..selection = TextSelection.collapsed(offset: value.length),
                  onChanged: (v) => ref.read(studentEditProvider(student).notifier).updateField(field, v),
                  decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 6)),
                  keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                )
              : Text(value.isNotEmpty ? value : '—',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const Divider(height: 20, color: Color(0xFFF0F0F0)),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, WidgetRef ref, String label,
      String value, String field, bool isEditable, {bool showAge = false}) {
    final int? age = showAge ? StudentUtils.calculateAge(value) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: isEditable ? () => _selectDate(context, ref, field) : null,
            child: Row(
              children: [
                Text(
                  value.isNotEmpty ? value : (isEditable ? 'Tap to select' : '—'),
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isEditable ? AppColors.primary : AppColors.textPrimary),
                ),
                if (age != null && age > 0) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Age $age',
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 20, color: Color(0xFFF0F0F0)),
        ],
      ),
    );
  }
}
