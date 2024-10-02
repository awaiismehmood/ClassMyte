import 'package:classmyte/contacts_screen/contacts.dart';
import 'package:classmyte/settings/settings.dart';
import 'package:classmyte/sms_screen/sms.dart';
import 'package:flutter/material.dart';
import 'package:classmyte/components/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:classmyte/main.dart';

Widget buildHomeScreen(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ClassMyte', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
             onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  },
),
        ],
      ),
    ),
    body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'),
          fit: BoxFit.fill,
          opacity: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 70),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildGridCard(context, 'Students', icon: Icons.people, onPressed: () {
                  Routes.navigateTocontacts(context);
                }),
                _buildGridCard(context, 'Classes', icon: Icons.class_, onPressed: () {
                  Routes.navigateToClasses(context);
                }),
                _buildGridCard(context, 'Send SMS', icon: Icons.sms, onPressed: () {
                  Routes.navigateToSms(context);
                }),
                _buildGridCard(context, 'Teachers', icon: Icons.person_outline, onPressed: () {
                  
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildGridCard(
              context,
              'Signout',
              icon: Icons.logout,
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
              color: Colors.red,
            ),
          ),
           const SizedBox(height: 70),
        ],
      ),
    ),
  );
}

Widget _buildGridCard(BuildContext context, String title, {IconData? icon, VoidCallback? onPressed, Color color = Colors.blue}) {
  return GestureDetector(
    onTap: onPressed,
    child: Card(
      elevation: 4,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget getPage(int index, BuildContext context) {
  switch (index) {
    case 0:
      return buildHomeScreen(context);
    case 1:
      return const StudentContactsScreen();
    case 2:
      return const NewMessageScreen();
    default:
      return buildHomeScreen(context);
  }
}

