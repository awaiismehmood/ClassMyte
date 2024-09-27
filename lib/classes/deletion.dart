import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:classmyte/data_management/edit_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void showDeleteClassDialog(BuildContext context, String className) {
  TextEditingController passwordController = TextEditingController();
  bool isPasswordIncorrect = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Delete Class'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please enter your password to confirm deletion'),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: isPasswordIncorrect ? 'Incorrect password' : null,
                    errorStyle: const TextStyle(color: Colors.red),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    if (isPasswordIncorrect) {
                      setState(() {
                        isPasswordIncorrect = false;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  String enteredPassword = passwordController.text;

                  // Validate the entered password using Firebase authentication
                  bool isPasswordValid = await validateUserPassword(enteredPassword);

                  if (isPasswordValid) {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const AlertDialog(
                        title: Text('Deleting Class...'),
                        content: SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    );

                    // Delete the class and associated students
                    await EditContactService.deleteClassAndStudents(className);

                    // Close all dialogs and refresh the class list
                    Navigator.pop(context); // Close the loading indicator
                    Navigator.pop(context); // Close the password confirmation dialog
                    StudentData.getStudentData(); // Refresh class list

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Class deleted successfully')),
                    );
                  } else {
                    // Display incorrect password message
                    setState(() {
                      isPasswordIncorrect = true;
                    });
                  }
                },
                child: const Text('Delete'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Function to validate the user's password for re-authentication
Future<bool> validateUserPassword(String password) async {
  try {
    // Get the current authenticated user
    var currentUser = FirebaseAuth.instance.currentUser;

    // Create credentials using the entered email and password
    var credential = EmailAuthProvider.credential(
      email: currentUser!.email!,
      password: password,
    );

    // Re-authenticate the user with the entered credentials
    await currentUser.reauthenticateWithCredential(credential);
    return true; // Password is correct
  } catch (e) {
    return false; // Password is incorrect
  }
}
