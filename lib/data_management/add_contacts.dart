// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddContactService {
  static Future<void> addContact(
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
            .add({
              'Name': name,
              'Class': classValue,
              'Number': phoneNumber,
              'Father Name': fatherName,
              'DOB': DOB,
              'Admission Date': admission,
              'Alt Number': altNumber,
            })
            .then((value) => print('Contact added successfully'))
            .catchError((error) => print('Failed to add contact: $error'));
      } else {
        print('No authenticated user found. Cannot add contact.');
      }
    } catch (e) {
      print('Error adding contact: $e');
    }
  }
}
