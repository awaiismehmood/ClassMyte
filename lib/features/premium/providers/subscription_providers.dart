import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subscription_state.dart';

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() => SubscriptionState();

  Future<void> checkSubscriptionStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        var data = userDoc.data() as Map<String, dynamic>?;

        if (data != null) {
          var subscription = data['subscription'];
          if (subscription != null && subscription['package'] != 'Free') {
            final expiry = (subscription['expiryDate'] as Timestamp?)?.toDate();
            if (expiry != null && expiry.isBefore(DateTime.now())) {
              await updateSubscription('Free', null);
              state = state.copyWith(isPremiumUser: false, subscribedPackage: 'Free', expiryDate: null, isLoading: false);
            } else {
              state = state.copyWith(isPremiumUser: true, subscribedPackage: subscription['package'], expiryDate: expiry, isLoading: false);
            }
          } else {
            state = state.copyWith(isPremiumUser: false, subscribedPackage: 'Free', expiryDate: null, isLoading: false);
          }
        } else {
          state = state.copyWith(isLoading: false);
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateSubscription(String package, DateTime? expiryDate) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userDocRef);
        if (!userDoc.exists) {
          await transaction.set(userDocRef, {'subscription': {'package': package, 'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null}});
        } else {
          await transaction.update(userDocRef, {'subscription': {'package': package, 'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null}});
        }
      });
      await checkSubscriptionStatus();
    }
  }
}

final subscriptionProvider = NotifierProvider<SubscriptionNotifier, SubscriptionState>(SubscriptionNotifier.new);
final selectedPlanProvider = StateProvider<String>((ref) => 'Free');
final paymentProcessingProvider = StateProvider<bool>((ref) => false);
