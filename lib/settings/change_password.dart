import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String> errorMessage = ValueNotifier('');
  final FocusNode currentPasswordFocusNode = FocusNode();
  final FocusNode newPasswordFocusNode = FocusNode();

  Future<void> changePassword(BuildContext context) async {
    if (currentPasswordController.text.isEmpty || newPasswordController.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields.';
      return;
    }

    isLoading.value = true;
    try {
      User? user = FirebaseAuth.instance.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPasswordController.text.trim(),
      );

      // Reauthenticate user
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPasswordController.text.trim());

      // Automatically sign out from all devices
      await FirebaseAuth.instance.signOut();

      // Show success message and navigate back
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully! Please log in again.')),
      );
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    currentPasswordFocusNode.dispose();
    newPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the back button color to white
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22, // Make the font size a bit larger
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Unfocus text fields when tapping outside
          currentPasswordFocusNode.unfocus();
          newPasswordFocusNode.unfocus();
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blueAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, loading, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Current Password Field
                    _buildPasswordField(
                      controller: currentPasswordController,
                      labelText: 'Current Password',
                      focusNode: currentPasswordFocusNode,
                    ),
                    const SizedBox(height: 20),
                    // New Password Field
                    _buildPasswordField(
                      controller: newPasswordController,
                      labelText: 'New Password',
                      focusNode: newPasswordFocusNode,
                    ),
                    const SizedBox(height: 20),
                    loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => changePassword(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              backgroundColor: Colors.blue[800], // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Rounded corners
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Change Password', style: TextStyle(color: Colors.white),),
                          ),
                    const SizedBox(height: 20),
                    // Error Message Display
                    ValueListenableBuilder<String>(
                      valueListenable: errorMessage,
                      builder: (context, error, child) {
                        return Text(
                          error,
                          style: const TextStyle(color: Colors.red),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({required TextEditingController controller, required String labelText, required FocusNode focusNode}) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: true,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
