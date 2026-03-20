import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(loginLoadingProvider.notifier).state = false;
      }
    });
  }

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      ref.read(loginLoadingProvider.notifier).state = true;
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (userCredential.user != null &&
            !userCredential.user!.emailVerified) {
          if (mounted) {
            CustomSnackBar.showError(
                context, 'Please verify your email before logging in.');
          }
          FirebaseAuth.instance.signOut();
          return;
        }
      } on FirebaseAuthException catch (e) {
        String msg = 'Incorrect email or password';
        if (e.code == 'user-not-found') msg = 'No user found with this email.';
        if (e.code == 'wrong-password') msg = 'Incorrect password.';
        if (mounted) CustomSnackBar.showError(context, msg);
      } catch (error) {
        if (mounted) {
          CustomSnackBar.showError(context, 'An unexpected error occurred.');
        }
      } finally {
        ref.read(loginLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loginLoadingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ClassMyte',
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
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
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
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
                          const SizedBox(height: 20),
                          CustomTextField(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            controller: passwordController,
                            isPassword: true,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Password is required'
                                : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              child: Text(
                                "Forgot Password?",
                                style: GoogleFonts.outfit(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomButton(
                            text: 'Sign In',
                            isLoading: isLoading,
                            onPressed: () =>
                                signInWithEmailAndPassword(context),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.outfit(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6)),
                              ),
                              GestureDetector(
                                onTap: () => context.push('/signup'),
                                child: Text(
                                  "Sign Up",
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
