import 'package:classmyte/core/data/edit_contacts.dart';
import 'package:classmyte/core/widgets/custom_bottom_sheet.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteClassSheet extends ConsumerStatefulWidget {
  final String className;

  const DeleteClassSheet({super.key, required this.className});

  static void show(BuildContext context, String className) {
    CustomBottomSheet.show(
      context,
      title: 'Delete Category',
      child: DeleteClassSheet(className: className),
    );
  }

  @override
  ConsumerState<DeleteClassSheet> createState() => _DeleteClassSheetState();
}

class _DeleteClassSheetState extends ConsumerState<DeleteClassSheet> {
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<bool> _validateUserPassword(String password) async {
    try {
      var currentUser = FirebaseAuth.instance.currentUser;
      var credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _deleteClass() async {
    final password = passwordController.text;
    if (password.isEmpty) {
      CustomSnackBar.showError(context, 'Please enter your password');
      return;
    }

    setState(() => _isLoading = true);

    bool isValid = await _validateUserPassword(password);
    if (!isValid) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackBar.showError(context, 'Incorrect password');
      }
      return;
    }

    try {
      await EditContactService.deleteClassAndStudents(widget.className);
      ref.invalidate(studentDataProvider);
      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Category deleted successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) CustomSnackBar.showError(context, 'Error deleting category');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Warning! Deleting this category will remove all students associated with it. Please enter your password to confirm.',
          style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        CustomTextField(
          labelText: 'Password',
          hintText: 'Enter account password',
          prefixIcon: Icons.lock_outline,
          controller: passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: _isLoading ? 'Deleting...' : 'Confirm Delete',
          color: Colors.redAccent,
          isLoading: _isLoading,
          onPressed: _deleteClass,
        ),
      ],
    );
  }
}
