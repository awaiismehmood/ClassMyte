// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// Future<void> transferUserData(String oldUserId, String newUserId) async {
//   // Get the Firestore instance
//   FirebaseFirestore firestore = FirebaseFirestore.instance;

//   // Retrieve contacts from the old user account
//   CollectionReference oldContactsRef = firestore.collection('users').doc(oldUserId).collection('contacts');
//   QuerySnapshot oldContactsSnapshot = await oldContactsRef.get();

//   // Iterate through old contacts and add them to the new user account
//   for (var doc in oldContactsSnapshot.docs) {
//     await firestore.collection('users').doc(newUserId).collection('contacts').doc(doc.id).set(doc.data());
//   }

//   // Optionally, delete the old user account if needed
//   // Uncomment the following line after confirming data transfer
//   // await FirebaseAuth.instance.currentUser?.delete();
// }
