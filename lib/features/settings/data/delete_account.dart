// ignore_for_file: use_build_context_synchronously
import 'package:classmyte/main.dart';
import 'package:classmyte/core/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteAccount {
  static Future<void> delete(BuildContext context) async {
    CustomDialog.show(
      context: context,
      title: 'Confirm Delete Account',
      subtitle: 'Are you sure you want to delete your account? This action cannot be undone, and all your data will be lost.',
      confirmText: 'Delete',
      confirmColor: Colors.redAccent,
      onConfirm: () {
        Navigator.pop(context); // Close confirmation
        _reauthenticateAndDelete(context);
      },
    );
  }

  static Future<void> _reauthenticateAndDelete(BuildContext context) async {
    final passwordController = TextEditingController();
    
    CustomDialog.show(
      context: context,
      title: 'Confirm Password',
      subtitle: 'Please enter your password to proceed with account deletion.',
      confirmText: 'Confirm Delete',
      confirmColor: Colors.redAccent,
      controller: passwordController,
      inputLabel: 'Password',
      inputHint: 'Enter your password',
      isPassword: true,
      onConfirm: () async {
        final password = passwordController.text.trim();
        if (password.isEmpty) return;

        try {
          // Show loading
          CustomDialog.show(
            context: context,
            title: 'Deleting Account',
            subtitle: 'Please wait...',
            isLoading: true,
            onConfirm: () {},
          );

          User? user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            Navigator.pop(context); // Close loading
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

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MyApp()),
            (Route<dynamic> route) => false,
          );
        } catch (e) {
          Navigator.pop(context); // Close loading
          _showErrorDialog(context, 'Error: ${e.toString()}');
        }
      },
    );
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

  static void _showErrorDialog(BuildContext context, String message) {
    CustomDialog.show(
      context: context,
      title: 'Error',
      subtitle: message,
      confirmText: 'OK',
      onConfirm: () => Navigator.pop(context),
    );
  }
}

