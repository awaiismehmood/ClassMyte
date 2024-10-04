// settings.dart
import 'package:classmyte/main.dart';
import 'package:classmyte/onboarding/term.dart';
import 'package:classmyte/premium/subscription_screen.dart';
import 'package:classmyte/settings/change_password.dart';
import 'package:classmyte/settings/delete_account.dart'; // Ensure to import DeleteAccount
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
          decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Account'),
                onTap: () async {
                  await DeleteAccount.delete(context); // Call the delete method
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.subscriptions),
                title: const Text('My Subcription'),
                onTap: () {
                 Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.policy),
                title: const Text('Terms and conditions'),
                onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                   FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
