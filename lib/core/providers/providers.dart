import 'package:classmyte/core/ads/ads.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:classmyte/core/data/data_retrieval.dart';
import 'package:classmyte/core/services/searching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:classmyte/core/data/data_retrieval.dart';


import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Auth Provider
final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Notifications Provider
final notificationsProvider = Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});


// SharedPreferences Provider
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});


// AdManager Provider
final adManagerProvider = Provider<AdManager>((ref) {
  final adManager = AdManager();
  ref.onDispose(() => adManager.dispose());
  return adManager;
});

// Subscription State
class SubscriptionState {
  final bool isPremiumUser;
  final String subscribedPackage;
  final DateTime? expiryDate;
  final bool isLoading;

  SubscriptionState({
    this.isPremiumUser = false,
    this.subscribedPackage = 'Free',
    this.expiryDate,
    this.isLoading = true,
  });

  SubscriptionState copyWith({
    bool? isPremiumUser,
    String? subscribedPackage,
    DateTime? expiryDate,
    bool? isLoading,
  }) {
    return SubscriptionState(
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      subscribedPackage: subscribedPackage ?? this.subscribedPackage,
      expiryDate: expiryDate ?? this.expiryDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Subscription Provider
class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() {
    // We check status on build or let the UI trigger it
    return SubscriptionState();
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        var data = userDoc.data() as Map<String, dynamic>?;

        if (data != null) {
          var subscription = data['subscription'];
          if (subscription != null && subscription['package'] != 'Free') {
            final expiry = (subscription['expiryDate'] as Timestamp?)?.toDate();
            
            if (expiry != null && expiry.isBefore(DateTime.now())) {
              await updateSubscription('Free', null);
              state = state.copyWith(
                isPremiumUser: false,
                subscribedPackage: 'Free',
                expiryDate: null,
                isLoading: false,
              );
            } else {
              state = state.copyWith(
                isPremiumUser: true,
                subscribedPackage: subscription['package'],
                expiryDate: expiry,
                isLoading: false,
              );
            }
          } else {
            state = state.copyWith(
              isPremiumUser: false,
              subscribedPackage: 'Free',
              expiryDate: null,
              isLoading: false,
            );
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
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

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
      // Refresh status
      await checkSubscriptionStatus();
    }
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
        SubscriptionNotifier.new);

// Navigation Provider for HomePage
final navigationProvider = StateProvider<int>((ref) => 0);

// Selected Plan Provider for SubscriptionScreen
final selectedPlanProvider = StateProvider<String>((ref) => 'Free');

// Payment Processing Provider
// Auth UI Providers
final loginLoadingProvider = StateProvider<bool>((ref) => false);
final loginObscureProvider = StateProvider<bool>((ref) => true);

final signupLoadingProvider = StateProvider<bool>((ref) => false);
final signupObscureProvider = StateProvider<bool>((ref) => true);

final forgotPasswordLoadingProvider = StateProvider<bool>((ref) => false);

final paymentProcessingProvider = StateProvider<bool>((ref) => false);

// Student Detail Edit Provider
class StudentEditState {
  final String name;
  final String fatherName;
  final String className;
  final String phoneNumber;
  final String altNumber;
  final String dob;
  final String admissionDate;
  final bool isEditable;
  final bool isLoading;

  StudentEditState({
    required this.name,
    required this.fatherName,
    required this.className,
    required this.phoneNumber,
    required this.altNumber,
    required this.dob,
    required this.admissionDate,
    this.isEditable = false,
    this.isLoading = false,
  });

  StudentEditState copyWith({
    String? name,
    String? fatherName,
    String? className,
    String? phoneNumber,
    String? altNumber,
    String? dob,
    String? admissionDate,
    bool? isEditable,
    bool? isLoading,
  }) {
    return StudentEditState(
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      className: className ?? this.className,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      altNumber: altNumber ?? this.altNumber,
      dob: dob ?? this.dob,
      admissionDate: admissionDate ?? this.admissionDate,
      isEditable: isEditable ?? this.isEditable,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StudentEditNotifier extends FamilyNotifier<StudentEditState, Map<String, String>> {
  @override
  StudentEditState build(Map<String, String> arg) {
    return StudentEditState(
      name: arg['name'] ?? '',
      fatherName: arg['fatherName'] ?? '',
      className: arg['class'] ?? '',
      phoneNumber: arg['phoneNumber'] ?? '',
      altNumber: arg['altNumber'] ?? '',
      dob: arg['DOB'] ?? '',
      admissionDate: arg['Admission Date'] ?? '',
    );
  }

  void updateField(String field, String value) {
    switch (field) {
      case 'name': state = state.copyWith(name: value); break;
      case 'fatherName': state = state.copyWith(fatherName: value); break;
      case 'class': state = state.copyWith(className: value); break;
      case 'phoneNumber': state = state.copyWith(phoneNumber: value); break;
      case 'altNumber': state = state.copyWith(altNumber: value); break;
      case 'dob': state = state.copyWith(dob: value); break;
      case 'admissionDate': state = state.copyWith(admissionDate: value); break;
    }
  }

  void toggleEditable() => state = state.copyWith(isEditable: !state.isEditable);
  void setLoading(bool val) => state = state.copyWith(isLoading: val);
}

final studentEditProvider = NotifierProvider.family<StudentEditNotifier, StudentEditState, Map<String, String>>(StudentEditNotifier.new);

final studentDataProvider = FutureProvider<List<Map<String, String>>>((ref) async => await StudentData.getStudentData());

final studentSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedClassesProvider = StateProvider<List<String>>((ref) => []);

final filteredStudentsProvider = Provider<List<Map<String, String>>>((ref) {
  final allStudents = ref.watch(studentDataProvider).value ?? [];
  final query = ref.watch(studentSearchQueryProvider);
  final selectedClasses = ref.watch(selectedClassesProvider);

  if (query.isEmpty && selectedClasses.isEmpty) return allStudents;

  return SearchService.searchStudents(
    allStudents,
    query,
    selectedClasses: selectedClasses,
  );
});
