import 'package:classmyte/core/data/add_contacts.dart';
import 'package:classmyte/core/data/data_retrieval.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_bottom_sheet.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_dropdown.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddContactSheet extends ConsumerStatefulWidget {
  final VoidCallback onRefresh;
  const AddContactSheet({super.key, required this.onRefresh});

  static void show(BuildContext context, VoidCallback onRefresh) {
    CustomBottomSheet.show(
      context,
      title: 'Add New Student',
      child: AddContactSheet(onRefresh: onRefresh),
    );
  }

  @override
  ConsumerState<AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends ConsumerState<AddContactSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController altNumberController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController admissionDateController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  String? selectedClass;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    fatherController.dispose();
    altNumberController.dispose();
    dobController.dispose();
    admissionDateController.dispose();
    classController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = "${picked.toLocal()}".split(' ')[0];
    }
  }

  Future<void> _saveContact() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      CustomSnackBar.showError(context, 'Name and Phone are required');
      return;
    }

    final finalClass = classController.text.isNotEmpty ? classController.text : selectedClass;
    if (finalClass == null || finalClass.isEmpty) {
      CustomSnackBar.showError(context, 'Please select or enter a class');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AddContactService.addContact(
        nameController.text,
        finalClass,
        phoneController.text,
        fatherController.text,
        dobController.text,
        admissionDateController.text,
        altNumberController.text,
      );
      widget.onRefresh();
      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Student added successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) CustomSnackBar.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: StudentData.getStudentData(),
      builder: (context, snapshot) {
        List<String> allClasses = [];
        if (snapshot.hasData) {
          allClasses = snapshot.data!.map((s) => s['class'] ?? '').toSet().where((c) => c.isNotEmpty).toList();
        }

        return Column(
          children: [
            CustomTextField(
              labelText: 'Full Name',
              hintText: 'Enter student name',
              prefixIcon: Icons.person_outline,
              controller: nameController,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomDropdown<String>(
                    value: selectedClass,
                    hintText: 'Select Class',
                    fillColor: AppColors.primary.withOpacity(0.05),
                    items: allClasses.map((c) => CustomDropdownItem(value: c, label: c)).toList(),
                    onChanged: (v) => setState(() {
                      selectedClass = v;
                      if (v != null) classController.clear();
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    labelText: 'New Class',
                    hintText: 'Or type new',
                    controller: classController,
                    onChanged: (v) {
                      if (v.isNotEmpty) setState(() => selectedClass = null);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              labelText: 'Phone Number',
              hintText: 'Enter mobile number',
              prefixIcon: Icons.phone_outlined,
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              labelText: 'Father Name',
              hintText: "Enter father's name",
              prefixIcon: Icons.family_restroom_outlined,
              controller: fatherController,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'DOB',
                    hintText: 'Select date',
                    prefixIcon: Icons.cake_outlined,
                    controller: dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context, dobController),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    labelText: 'Admission Date',
                    hintText: 'Select date',
                    prefixIcon: Icons.calendar_today_outlined,
                    controller: admissionDateController,
                    readOnly: true,
                    onTap: () => _selectDate(context, admissionDateController),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              labelText: 'Alternate Number',
              hintText: 'Optional contact',
              prefixIcon: Icons.phone_iphone_outlined,
              controller: altNumberController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: _isLoading ? 'Saving...' : 'Save Student',
              isLoading: _isLoading,
              onPressed: _saveContact,
            ),
          ],
        );
      },
    );
  }
}
