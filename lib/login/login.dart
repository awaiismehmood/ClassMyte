import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<bool> isObscure = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> passwordError = ValueNotifier(false);
  final ValueNotifier<bool> emailError = ValueNotifier(false);
  final ValueNotifier<String> errorMessage = ValueNotifier('');
  final _formKey = GlobalKey<FormState>();

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } catch (error) {
        errorMessage.value = 'Incorrect password';
        passwordError.value = true;
      } finally {
        isLoading.value = false;
      }
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      emailError.value = true;
      return 'Email is required';
    }
    emailError.value = false; // Reset error if valid
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      passwordError.value = true;
      return 'Password is required';
    }
    passwordError.value = false; // Reset error if valid
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      'ClassMyte',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: const [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 3,
                            color: Colors.black12,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Image.asset(
                      'assets/l.png',
                      height: 100,
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: emailError,
                    builder: (context, hasError, child) {
                      return TextFormField(
                        controller: emailController,
                        onChanged: validateEmail,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          errorText: hasError ? 'Email is required' : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ValueListenableBuilder<bool>(
                    valueListenable: isObscure,
                    builder: (context, obscure, child) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: passwordError,
                        builder: (context, hasError, _) {
                          return TextFormField(
                            controller: passwordController,
                            onChanged: validatePassword,
                            obscureText: obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  isObscure.value = !isObscure.value;
                                },
                              ),
                              errorText: hasError ? errorMessage.value : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      // Add Forget Password logic here
                    },
                    child: const Text(
                      'Forget Password?',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ValueListenableBuilder<bool>(
                    valueListenable: isLoading,
                    builder: (context, loading, child) {
                      return loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () =>
                                  signInWithEmailAndPassword(context),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                              child: const Text('Sign In'),
                            );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      // Add Sign Up logic here
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
