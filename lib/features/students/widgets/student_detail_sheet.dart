import 'package:classmyte/core/data/edit_contacts.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/communication_dialogs.dart';
import 'package:classmyte/core/services/functional.dart';
import 'package:classmyte/features/sms/data/whatsapp_service.dart';
import 'package:classmyte/core/widgets/custom_bottom_sheet.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_dialog.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:classmyte/features/students/models/student_edit_state.dart';
import 'package:classmyte/core/services/student_utils.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
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
    CustomDialog.show(
      context: context,
      title: 'Delete Student',
      subtitle: 'Are you sure you want to remove this student from your list?',
      confirmText: 'Yes, Delete',
      confirmColor: Colors.redAccent,
      onConfirm: () async {
        try {
          await EditContactService.deleteContact(student['id'] ?? '');
          ref.invalidate(studentDataProvider);
          if (context.mounted) {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Close bottom sheet
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
      ref
          .read(studentEditProvider(student).notifier)
          .updateField(field, dateStr);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentEditProvider(student));
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                state.name.isNotEmpty ? state.name[0].toUpperCase() : '?',
                style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
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
                    style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: onSurface),
                  ),
                  Text(
                    'Class ${state.className}',
                    style: GoogleFonts.outfit(
                        color: onSurface.withOpacity(0.6), fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                  state.isEditable ? Icons.check_circle : Icons.edit_note,
                  color: state.isEditable ? Colors.green : AppColors.primary,
                  size: 28),
              onPressed: () {
                if (state.isEditable) {
                  _saveChanges(context, ref, state);
                } else {
                  ref
                      .read(studentEditProvider(student).notifier)
                      .toggleEditable();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 28),
              onPressed: () => _deleteStudent(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.02)
                  : AppColors.primary.withOpacity(0.02),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: onSurface.withOpacity(0.05))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                  context, ref, 'Name', state.name, 'name', state.isEditable),
              _buildField(context, ref, 'Class', state.className, 'class',
                  state.isEditable),
              _buildField(context, ref, 'Phone#', state.phoneNumber,
                  'phoneNumber', state.isEditable,
                  isPhone: true),
              _buildField(context, ref, 'Alt#', state.altNumber, 'altNumber',
                  state.isEditable,
                  isPhone: true),
              _buildField(context, ref, 'Father Name', state.fatherName,
                  'fatherName', state.isEditable),
              _buildDateField(
                  context, ref, 'DOB', state.dob, 'dob', state.isEditable,
                  trailing: Text('Age: ${StudentUtils.calculateAge(state.dob)}',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold))),
              _buildDateField(context, ref, 'Admission Date',
                  state.admissionDate, 'admissionDate', state.isEditable),
              _buildStatusField(context, ref, state.isActive, state.isEditable),
            ],
          ),
        ),
        const SizedBox(height: 32),
        if (state.isEditable)
          CustomButton(
            text: state.isLoading ? 'Saving...' : 'Save Updates',
            isLoading: state.isLoading,
            onPressed: () => _saveChanges(context, ref, state),
          ),
      ],
    );
  }

  Widget _buildField(BuildContext context, WidgetRef ref, String label,
      String value, String field, bool isEditable,
      {bool isPhone = false}) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditable)
            CustomTextField(
              labelText: label,
              hintText: 'Enter $label',
              controller: TextEditingController(text: value)
                ..selection = TextSelection.collapsed(offset: value.length),
              onChanged: (v) => ref
                  .read(studentEditProvider(student).notifier)
                  .updateField(field, v),
              keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            )
          else if (isPhone && value.isNotEmpty && value != '0')
            Row(
              children: [
                Text(value,
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: onSurface)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.phone_outlined,
                      size: 20, color: AppColors.primary),
                  onPressed: () => makeCall(value),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline,
                      size: 20, color: Colors.green),
                  onPressed: () {
                    CommunicationDialogs.showMessageOptionDialog(
                      context: context,
                      phoneNumber: value,
                      onSMS: () => sendSMS(value),
                      onWhatsApp: () => WhatsAppMessaging()
                          .sendWhatsAppMessageIndividually(value),
                    );
                  },
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            )
          else
            Text(value.isNotEmpty ? value : '-',
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: onSurface)),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, WidgetRef ref, String label,
      String value, String field, bool isEditable,
      {Widget? trailing}) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.bold)),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: isEditable ? () => _selectDate(context, ref, field) : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isEditable
                    ? (isDark ? Colors.white.withOpacity(0.05) : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isEditable
                    ? Border.all(color: onSurface.withOpacity(0.1))
                    : null,
              ),
              child: Text(
                value.isNotEmpty ? value : '-',
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isEditable ? AppColors.primary : onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusField(
      BuildContext context, WidgetRef ref, bool isActive, bool isEditable) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.bold)),
                  Text(isActive ? 'Active' : 'Inactive',
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.green : Colors.redAccent)),
                ],
              ),
              const Spacer(),
              if (isEditable)
                Switch(
                  value: isActive,
                  onChanged: (v) => ref
                      .read(studentEditProvider(student).notifier)
                      .toggleActive(v),
                  activeThumbColor: Colors.green,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
