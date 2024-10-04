import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SubscriptionData {
  final ValueNotifier<bool> isPremiumUser = ValueNotifier<bool>(false);
  final ValueNotifier<String> subscribedPackage = ValueNotifier<String>('');
  final ValueNotifier<DateTime?> expiryDate = ValueNotifier<DateTime?>(null);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true); // Loader state

  Future<void> checkSubscriptionStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        var subscriptionData = userDoc.data() as Map<String, dynamic>?;

        if (subscriptionData != null) {
          var subscription = subscriptionData['subscription'];
          if (subscription != null && subscription['package'] != 'Free') {
            // User is on a paid plan
            isPremiumUser.value = true;
            subscribedPackage.value = subscription['package'];
            expiryDate.value = subscription['expiryDate']?.toDate();
            _checkExpiryDate(); // Check expiry date on load
          } else {
            // Ensure non-premium users are treated as 'Free'
            isPremiumUser.value = false;
            subscribedPackage.value = 'Free';
            expiryDate.value = null; // No expiry for Free plan
          }
        }
      }
    } finally {
      isLoading.value = false; // Stop loading once the data is checked
    }
  }

  Future<void> updateSubscription(String package, DateTime? expiryDate) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    
    // Use a transaction to safely update or create the subscription document
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Attempt to get the current document
      DocumentSnapshot userDoc = await transaction.get(userDocRef);
      
      if (!userDoc.exists) {
        // Document doesn't exist, create it
        await transaction.set(userDocRef, {
          'subscription': {
            'package': package,
            'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
          },
          // Add other user fields here as necessary
        });
      } else {
        // Document exists, update the subscription field
        await transaction.update(userDocRef, {
          'subscription': {
            'package': package,
            'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
          },
        });
      }
    });
  }
}


  void _checkExpiryDate() {
    if (expiryDate.value != null && expiryDate.value!.isBefore(DateTime.now())) {
      isPremiumUser.value = false;
      subscribedPackage.value = 'Free';
      expiryDate.value = null;

      // Update Firestore to reflect this change
      updateSubscription('Free', null); // Set subscription to null
    }
  }
}
