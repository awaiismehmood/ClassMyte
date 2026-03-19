import 'package:classmyte/features/classes/classes.dart';
import 'package:classmyte/features/students/students.dart';
import 'package:classmyte/features/sms/sms.dart';
import 'package:flutter/material.dart';

class Routes {
  static void navigateTocontacts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudentContactsScreen()),
    );
  }

  static void navigateToSms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  const NewMessageScreen()),
    );
  }

   static void navigateToClasses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClassScreen()),
    );
  }
}

