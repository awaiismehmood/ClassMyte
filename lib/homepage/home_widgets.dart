import 'package:flutter/material.dart';
import 'package:classmyte/components/routes.dart';
import 'package:classmyte/contacts_screen/contacts.dart';
import 'package:classmyte/sms_screen/sms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:classmyte/main.dart';

Widget buildHomeScreen(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: buildCard(
            context,
            'Students',
            onPressed: () {
              Routes.navigateTocontacts(context);
            },
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: buildCard(
            context,
            'Classes',
            onPressed: () {
              Routes.navigateToClasses(context);
            },
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: buildCard(
            context,
            'Send SMS',
            onPressed: () {
              Routes.navigateToSms(context);
            },
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: buildCard(
            context,
            'Signout',
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget buildCard(BuildContext context, String title, {VoidCallback? onPressed}) {
  return GestureDetector(
    onTap: onPressed,
    child: Card(
      elevation: 4,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 0.2,
        decoration: BoxDecoration(
          color: title == 'Signout' ? Colors.red : Colors.blue,
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    ),
  );
}

Widget _buildHeader() {
  return Container(
    height: 180,
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 3),
        ),
      ],
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
