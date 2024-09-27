import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentData {
  static Future<List<Map<String, String>>> getStudentData() async {
    try {
      // Get the currently authenticated user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String uid = currentUser.uid;

        // Reference the Firestore collection specific to this user
        CollectionReference<Map<String, dynamic>> collectionRef =
            FirebaseFirestore.instance.collection('users').doc(uid).collection('contacts');

        QuerySnapshot<Map<String, dynamic>> snapshot = await collectionRef.get();

        List<Map<String, String>> students = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['Name'] as String,
            'class': doc['Class'] as String,
            'phoneNumber': doc['Number'] as String,
            'fatherName': doc['Father Name'] as String,
            'DOB': doc['DOB'] as String,
            'Admission Date': doc['Admission Date'] as String,
            'altNumber': doc['Alt Number'] as String,
          };
        }).toList();

        return students;
      } else {
        // ignore: avoid_print
        print('No authenticated user found. Cannot retrieve data.');
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  
}
