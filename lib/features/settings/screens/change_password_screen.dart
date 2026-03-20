import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<void> changePassword(BuildContext context) async {
    final currentPass = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();

    if (currentPass.isEmpty || newPass.isEmpty) {
      CustomSnackBar.showError(context, 'Please fill in all fields.');
      return;
    }
    
    if (newPass.length < 6) {
      CustomSnackBar.showError(context, 'New password must be at least 6 characters.');
      return;
    }

    isLoading.value = true;
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPass,
      );

      // Reauthenticate user
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPass);

      // Success feedback
      if (context.mounted) {
        CustomSnackBar.showSuccess(context, 'Password changed successfully! Please log in again.');
      }

      // Automatically sign out as security best practice
      await FirebaseAuth.instance.signOut();
      
      // Navigate to login using GoRouter
      if (context.mounted) {
        context.go('/login');
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to change password.';
      if (e.code == 'wrong-password') msg = 'Current password is incorrect.';
      if (context.mounted) CustomSnackBar.showError(context, msg);
    } catch (e) {
      if (context.mounted) CustomSnackBar.showError(context, 'An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomHeader(title: 'Change Password'),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update Security',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your current and new password to update your account security.',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          CustomTextField(
                            labelText: 'Current Password',
                            hintText: 'Enter old password',
                            prefixIcon: Icons.lock_open_outlined,
                            controller: currentPasswordController,
                            isPassword: true,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            labelText: 'New Password',
                            hintText: 'Enter new password',
                            prefixIcon: Icons.lock_outline,
                            controller: newPasswordController,
                            isPassword: true,
                          ),
                          const SizedBox(height: 32),
                          ValueListenableBuilder<bool>(
                            valueListenable: isLoading,
                            builder: (context, loading, _) => CustomButton(
                              text: 'Update Password',
                              isLoading: loading,
                              onPressed: () => changePassword(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


