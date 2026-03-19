import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> signUpWithEmailAndPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      ref.read(signupLoadingProvider.notifier).state = true;
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await userCredential.user?.sendEmailVerification();

        if (mounted) {
          CustomSnackBar.showInfo(
              context, 'Verification email sent! Please check your inbox.');
          context.go('/login');
        }
      } on FirebaseAuthException catch (e) {
        String msg = 'Error occurred during signup';
        if (e.code == 'email-already-in-use')
          msg = 'The email is already in use.';
        if (e.code == 'weak-password') msg = 'The password is too weak.';
        if (mounted) CustomSnackBar.showError(context, msg);
      } catch (error) {
        if (mounted)
          CustomSnackBar.showError(context, 'An unexpected error occurred.');
      } finally {
        ref.read(signupLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(signupLoadingProvider);
    final isObscure = ref.watch(signupObscureProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/pencil_white.png',
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create Account',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            labelText: 'Full Name',
                            hintText: 'Enter your name',
                            prefixIcon: Icons.person_outline,
                            controller: nameController,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            labelText: 'Contact Number',
                            hintText: 'Enter your phone',
                            prefixIcon: Icons.phone_outlined,
                            controller: contactController,
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Contact is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Email is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            labelText: 'Password',
                            hintText: 'Create a password',
                            prefixIcon: Icons.lock_outline,
                            controller: passwordController,
                            obscureText: isObscure,
                            suffixIcon: IconButton(
                              icon: Icon(isObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => ref
                                  .read(signupObscureProvider.notifier)
                                  .state = !isObscure,
                            ),
                            validator: (v) => v == null || v.length < 6
                                ? 'Min 6 characters required'
                                : null,
                          ),
                          const SizedBox(height: 32),
                          CustomButton(
                            text: 'Sign Up',
                            isLoading: isLoading,
                            onPressed: () =>
                                signUpWithEmailAndPassword(context),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: GoogleFonts.outfit(
                                    color: AppColors.textSecondary),
                              ),
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Text(
                                  "Login",
                                  style: GoogleFonts.outfit(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    contactController.dispose();
    super.dispose();
  }
}
