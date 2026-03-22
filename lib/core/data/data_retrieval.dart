import 'package:classmyte/features/students/models/student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentData {
  static Stream<List<Student>> studentStream() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;

      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
      });
    } else {
      return Stream.value([]);
    }
  }

}

