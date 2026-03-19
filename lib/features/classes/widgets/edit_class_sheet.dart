import 'package:classmyte/core/data/edit_contacts.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_bottom_sheet.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class EditClassSheet extends ConsumerStatefulWidget {
  final List<String> classes;
  final String existingClass;
  final List<Map<String, String>> allStudents;

  const EditClassSheet({
    super.key,
    required this.classes,
    required this.existingClass,
    required this.allStudents,
  });

  static void show(BuildContext context, {
    required List<String> classes,
    required String existingClass,
    required List<Map<String, String>> allStudents,
  }) {
    CustomBottomSheet.show(
      context,
      title: 'Update Category',
      child: EditClassSheet(
        classes: classes,
        existingClass: existingClass,
        allStudents: allStudents,
      ),
    );
  }

  @override
  ConsumerState<EditClassSheet> createState() => _EditClassSheetState();
}

class _EditClassSheetState extends ConsumerState<EditClassSheet> {
  late String selectedClass;
  final TextEditingController newClassController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedClass = widget.existingClass;
  }

  Future<void> _promoteStudents(String fromClass, String toClass) async {
    for (var student in widget.allStudents) {
      if (student['class'] == fromClass) {
        String? studentId = student['id'];
        if (studentId != null) {
          await EditContactService.updateClass(studentId, toClass);
        }
      }
    }
  }

  Future<void> _updateClass() async {
    String newClassName = newClassController.text.trim();
    if (newClassName.isEmpty && selectedClass == widget.existingClass) {
      CustomSnackBar.showError(context, 'Please select a new category or enter a new name');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await _promoteStudents(widget.existingClass, newClassName.isNotEmpty ? newClassName : selectedClass);
      ref.invalidate(studentDataProvider);
      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Category updated successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) CustomSnackBar.showError(context, 'Error updating category');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    newClassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedClass,
          hint: Text('Select Category To Merge To', style: GoogleFonts.outfit()),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.primary.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          items: widget.classes.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.outfit()))).toList(),
          onChanged: (v) => setState(() {
            if (v != null) {
              selectedClass = v;
              newClassController.clear();
            }
          }),
        ),
        const SizedBox(height: 24),
        Text('OR', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        CustomTextField(
          labelText: 'Rename Category To',
          hintText: 'New category name',
          prefixIcon: Icons.edit_outlined,
          controller: newClassController,
          onChanged: (v) {
            if (v.isNotEmpty && selectedClass != widget.existingClass) {
              setState(() => selectedClass = widget.existingClass);
            }
          },
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: _isLoading ? 'Updating...' : 'Save Category',
          isLoading: _isLoading,
          onPressed: _updateClass,
        ),
      ],
    );
  }
}
