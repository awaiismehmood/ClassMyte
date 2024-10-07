// ignore_for_file: use_build_context_synchronously
import 'package:classmyte/data_management/edit_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void showDeleteClassDialog(BuildContext context, String className, ValueNotifier<List<String>> allClassesNotifier) {
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
                  bool isPasswordValid = await validateUserPassword(enteredPassword);

                  if (isPasswordValid) {
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
                    await EditContactService.deleteClassAndStudents(className);
                    Navigator.pop(context);
                    allClassesNotifier.value.remove(className);
                    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                    allClassesNotifier.notifyListeners();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Class deleted successfully')),
                    );
                  } else {
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


Future<bool> validateUserPassword(String password) async {
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
