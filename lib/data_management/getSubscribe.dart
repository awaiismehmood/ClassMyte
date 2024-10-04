import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionData {
  static Future<Map<String, dynamic>?> getSubscriptionStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  static Future<void> updateSubscription(String package, DateTime? expiryDate) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'subscription': {
          'package': package,
          'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
        },
      });
    }
  }
}
