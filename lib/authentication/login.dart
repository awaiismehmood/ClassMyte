import 'package:classmyte/homepage/home_screen.dart';
import 'package:classmyte/authentication/forgetPassword.dart';
import 'package:classmyte/authentication/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Check if email is verified
        if (userCredential.user != null &&
            !userCredential.user!.emailVerified) {
          // Inform the user to verify their email
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please verify your email before logging in.')),
          );
          FirebaseAuth.instance.signOut(); 
          return;
        }

        // Continue with your app's login logic if verified
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  const HomePage()),
        );
      } catch (error) {
        errorMessage.value = 'Incorrect email or password';
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // Path to your image
            fit: BoxFit.cover, // Adjust the fit according to your need
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/pencil_white.png',
                  height: 100,
                ),
                Container(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.55,
                  decoration: BoxDecoration(
                    // Use a linear gradient for a sleek effect
                    gradient: LinearGradient(
                      colors: [
                        Colors.white, // Start color
                        Colors.grey[100]!, // End color
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    // Add a subtle shadow to elevate the container
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: Offset(0, 4), // X and Y offset
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    // White background with a border and rounded corners
                    border: Border.all(
                        color: Colors.white
                            .withOpacity(0.5)), // Semi-transparent border
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: emailError,
                            builder: (context, hasError, child) {
                              return TextFormField(
                                controller: emailController,
                                onChanged: validateEmail,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                  errorText:
                                      hasError ? 'Email is required' : null,
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
                                      errorText:
                                          hasError ? errorMessage.value : null,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          // Add this TextButton to your LoginScreen build method below the login button
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          ValueListenableBuilder<bool>(
                            valueListenable: isLoading,
                            builder: (context, loading, child) {
                              return loading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : ElevatedButton(
                                      onPressed: () =>
                                          signInWithEmailAndPassword(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.blue.withOpacity(0.9),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        textStyle:
                                            const TextStyle(fontSize: 18),
                                      ),
                                      child: const Text(
                                        'Sign In',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignupScreen()), // Navigate to SignupScreen
                              );
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
