// ignore_for_file: use_build_context_synchronously
import 'package:classmyte/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteAccount {
  static Future<void> delete(BuildContext context) async {
    bool confirm = await _showDeleteConfirmationDialog(context);
    if (confirm) {
      String? password = await _showPasswordDialog(context);
      if (password != null) {
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(child: CircularProgressIndicator());
            },
          );

          User? user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            Navigator.of(context).pop(); 
            _showErrorDialog(context, 'No user is currently logged in.');
            return;
          }

          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(credential);
          await _deleteUserData(user.uid);
          await user.delete();

          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MyApp()),
            (Route<dynamic> route) => false,
          );
        } catch (e) {
          Navigator.of(context).pop();
          _showErrorDialog(context, 'Error: ${e.toString()}');
        }
      }
    }
  }

  static Future<void> _deleteUserData(String uid) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await firestore
        .collection('users')
        .doc(uid)
        .collection('images')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await firestore.collection('users').doc(uid).delete();
  }

  static Future<void> _showErrorDialog(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone, and all your data will be lost.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  static Future<String?> _showPasswordDialog(BuildContext context) async {
    String password = '';
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Password'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Enter your password"),
            onChanged: (value) {
              password = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(password);
              },
            ),
          ],
        );
      },
    );
  }
}
