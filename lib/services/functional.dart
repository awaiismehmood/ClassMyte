// student_contacts_functions.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> makeCall(String phoneNumber) async {
  final Uri call = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );

  // ignore: deprecated_member_use
  if (await canLaunch(call.toString())) {
    // ignore: deprecated_member_use
    await launch(call.toString());
  }
}

List<String> getUniqueClasses(List<Map<String, String>> allStudents) {
  return allStudents
      .map((student) => student['class']) // Get the class from each student
      .where((className) => className != null && className.isNotEmpty) // Filter out null or empty classes
      .toSet() // Convert to a Set to ensure uniqueness
      .map((className) => className!) // Convert back to non-nullable
      .toList(); // Convert back to List
}


class FilteringService {
  static List<Map<String, String>> filterByClasses(
      List<Map<String, String>> allStudents, List<String> selectedClasses) {
    if (selectedClasses.isEmpty) {
      return allStudents;
    }
    return allStudents.where((student) {
      return selectedClasses.contains(student['class']);
    }).toList();
  }
}


class SearchService {
  static List<Map<String, String>> searchStudents(
      List<Map<String, String>> allStudents, String query,
      {List<String> selectedClasses = const []}) {
    if (query.isEmpty) {
      return allStudents;
    }
    List<Map<String, String>> filteredStudents = allStudents.where((student) {
      return student['name']!.toLowerCase().contains(query.toLowerCase()) ||
          student['fatherName']!.toLowerCase().contains(query.toLowerCase()) ||
          student['class']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (selectedClasses.isNotEmpty) {
      filteredStudents = filteredStudents.where((student) {
        return selectedClasses.contains(student['class']);
      }).toList();
    }

    return filteredStudents;
  }
}


class StudentDialogNotifier {
  final ValueNotifier<String> name = ValueNotifier('');
  final ValueNotifier<String> phoneNumber = ValueNotifier('');
  final ValueNotifier<String> fatherName = ValueNotifier('');
  final ValueNotifier<String> dob = ValueNotifier('');
  final ValueNotifier<String> admissionDate = ValueNotifier('');
  final ValueNotifier<String> altNumber = ValueNotifier('');
  final ValueNotifier<String> selectedClass = ValueNotifier('');
  final ValueNotifier<String> typedClass = ValueNotifier('');
}


