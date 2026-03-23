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
    String status, {
    String gender = 'Not Specified',
    String religion = '',
    String nationality = '',
    String address = '',
  }) async {
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
              'status': status,
              'Gender': gender,
              'Religion': religion,
              'Nationality': nationality,
              'Address': address,
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

  static Future<void> deleteClassAndStudents(String className) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String uid = currentUser.uid;

        CollectionReference<Map<String, dynamic>> collectionRef =
            FirebaseFirestore.instance.collection('users').doc(uid).collection('contacts');

        QuerySnapshot<Map<String, dynamic>> studentsInClass = await collectionRef
            .where('Class', isEqualTo: className)
            .get();

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

  static Future<void> deleteMultipleContacts(List<String> ids) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      
      final collectionRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('contacts');
      final batch = FirebaseFirestore.instance.batch();
      
      for (var id in ids) {
        batch.delete(collectionRef.doc(id));
      }
      
      await batch.commit();
    } catch (e) {
      print('Error deleting multiple contacts: $e');
    }
  }

  static Future<void> updateMultipleStatus(List<String> ids, String status) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      
      final collectionRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('contacts');
      final batch = FirebaseFirestore.instance.batch();
      
      for (var id in ids) {
        batch.update(collectionRef.doc(id), {'status': status});
      }
      
      await batch.commit();
    } catch (e) {
      print('Error updating multiple contacts status: $e');
    }
  }
}

