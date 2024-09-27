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
  bool _isObscure = true;
  bool _passwordError = false;
  String _errorMessage = '';
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _passwordError = false;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } catch (error) {
        // If sign-in fails, show an error on the password field
        setState(() {
          _passwordError = true;
          _errorMessage = 'Incorrect password';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } 
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color.fromARGB(255, 8, 8, 8),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Image.asset(
                      'assets/l.png', // Replace with your logo image path
                      height: 100,
                    ),
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                      errorText: _passwordError ? _errorMessage : null,
                      errorStyle: const TextStyle(color: Colors.red),
                      focusedErrorBorder: _passwordError
                          ? const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            )
                          : null,
                    ),
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 16.0),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: () => signInWithEmailAndPassword(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Sign In'),
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
