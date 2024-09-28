import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddContactService {
  /// Adds a contact to the authenticated user's contacts collection
  static Future<void> addContact(
    String name,
    String classValue,
    String phoneNumber,
    String fatherName,
    String DOB,
    String admission,
    String altNumber,
  ) async {
    try {
      // Get the currently authenticated user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;

        // Reference the Firestore collection specific to this user
        CollectionReference<Map<String, dynamic>> collectionRef =
            FirebaseFirestore.instance.collection('users').doc(uid).collection('contacts');

        // Add the contact to the user's collection
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
