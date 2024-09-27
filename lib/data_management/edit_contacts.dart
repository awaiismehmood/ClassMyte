// ignore_for_file: avoid_print, invalid_return_type_for_catch_error

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditContactService {
  static Future<void> updateContact(
    String id,
    String name,
    String classValue,
    String phoneNumber,
    String fatherName,
    // ignore: non_constant_identifier_names
    String DOB,
    String admission,
    String altNumber,
  ) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String uid = currentUser.uid;
        CollectionReference<Map<String, dynamic>> collectionRef =
            FirebaseFirestore.instance.collection('users').doc(uid).collection('contacts');

        await collectionRef
            .doc(id)
            .update({
              'Name': name,
              'Class': classValue,
              'Number': phoneNumber,
              'Father Name': fatherName,
              'DOB': DOB,
              'Admission Date': admission,
              'Alt Number': altNumber,
            })

            .then((value) => print('Contact updated successfully'))
            .catchError((error) => print('Failed to update contact: $error'));
      } else {
        print('No authenticated user found. Cannot update contact.');
      }
    } catch (e) {
      print('Error updating contact: $e');
    }
  }

  /// Updates the class of a specific student in the authenticated user's collection
  static Future<void> updateClass(String studentId, String newClassName) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String uid = currentUser.uid;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('contacts')
            .doc(studentId)
            .update({'Class': newClassName});

      } else {

        print('No authenticated user found. Cannot update class.');
      }
    } catch (e) {

      print('Failed to update class for student ID: $studentId, Error: $e');
    }
  }

  /// Deletes a class and all students associated with it in the authenticated user's collection
  static Future<void> deleteClassAndStudents(String className) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String uid = currentUser.uid;

        CollectionReference<Map<String, dynamic>> collectionRef =
            FirebaseFirestore.instance.collection('users').doc(uid).collection('contacts');

        // Get all students in the class to be deleted
        QuerySnapshot<Map<String, dynamic>> studentsInClass = await collectionRef
            .where('Class', isEqualTo: className)
            .get();

        // Delete each student in the class
        for (QueryDocumentSnapshot<Map<String, dynamic>> student in studentsInClass.docs) {
          await student.reference.delete();
        }

      } else {
        print('No authenticated user found. Cannot delete class.');
      }
    } catch (e) {
      print('Error deleting class and students: $e');
    }
  }

  /// Deletes a contact in the authenticated user's collection
  static Future<void> deleteContact(String id) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String uid = currentUser.uid;

        CollectionReference<Map<String, dynamic>> collectionRef =
            FirebaseFirestore.instance.collection('users').doc(uid).collection('contacts');

        await collectionRef.doc(id).delete().then((value) {
          print('Contact deleted successfully');
        }).catchError((error) => print('Failed to delete contact: $error'));
      } else {
        print('No authenticated user found. Cannot delete contact.');
      }
    } catch (e) {
      print('Error deleting contact: $e');
    }
  }
}
