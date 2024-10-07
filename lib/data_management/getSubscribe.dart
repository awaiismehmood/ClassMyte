// ignore_for_file: await_only_futures

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
            isPremiumUser.value = true;
            subscribedPackage.value = subscription['package'];
            expiryDate.value = subscription['expiryDate']?.toDate();
            _checkExpiryDate();
          } else {
            isPremiumUser.value = false;
            subscribedPackage.value = 'Free';
            expiryDate.value = null;
          }
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSubscription(String package, DateTime? expiryDate) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userDoc = await transaction.get(userDocRef);
      
      if (!userDoc.exists) {
        await transaction.set(userDocRef, {
          'subscription': {
            'package': package,
            'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
          },
        });
      } else {
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

      updateSubscription('Free', null);
    }
  }
}
