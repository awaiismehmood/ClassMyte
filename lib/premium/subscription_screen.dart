import 'package:classmyte/data_management/getSubscribe.dart';
import 'package:classmyte/payment/payment_Screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final ValueNotifier<String> _selectedPlan = ValueNotifier<String>('Free');
  final ValueNotifier<bool> _isPremiumUser = ValueNotifier<bool>(false);
  final ValueNotifier<String> _subscribedPackage = ValueNotifier<String>('');
  final ValueNotifier<DateTime?> _expiryDate = ValueNotifier<DateTime?>(null);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true); // Loader state

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final subscriptionData = await SubscriptionData.getSubscriptionStatus();

      if (subscriptionData != null) {
        var subscription = subscriptionData['subscription'];
        if (subscription != null) {
          _isPremiumUser.value = true;
          _subscribedPackage.value = subscription['package'] ?? 'Free';
          _expiryDate.value = subscription['expiryDate']?.toDate();
          _checkExpiryDate(); // Check expiry date on load
        }
      }
    } finally {
      _isLoading.value = false; // Stop loading once the data is checked
    }
  }

  void _checkExpiryDate() {

    if (_expiryDate.value != null && _expiryDate.value!.isBefore(DateTime.now())) {
      _isPremiumUser.value = false;
      _subscribedPackage.value = 'Free';
      _expiryDate.value = null;

      // Update Firestore to reflect this change
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        SubscriptionData.updateSubscription('Free', null); // Set subscription to null
      }
    }
  }

  Future<void> _cancelSubscription() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await SubscriptionData.updateSubscription('Free', null); // Update Firestore to cancel subscription

      // Update local state
      _isPremiumUser.value = false;
      _subscribedPackage.value = 'Free';
      _expiryDate.value = null;
    }
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Subscription'),
          content: const Text('This will cancel your current subscription. Do you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelSubscription();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToPaymentScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PaymentScreen(plan: _selectedPlan.value)),
    );

    if (result == true) {
      _isPremiumUser.value = true;
      _subscribedPackage.value = _selectedPlan.value;
      if (_selectedPlan.value == 'Month') {
        _expiryDate.value = DateTime.now().add(const Duration(days: 30));
      } else if (_selectedPlan.value == 'Year') {
        _expiryDate.value = DateTime.now().add(const Duration(days: 365));
      } else {
        _expiryDate.value = null; // Free plan doesn't have an expiry
      }
      // Update Firestore with new subscription data
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        SubscriptionData.updateSubscription(_subscribedPackage.value, _expiryDate.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const CircularProgressIndicator(); // Show loader while checking subscription
            }
            return ValueListenableBuilder<bool>(
              valueListenable: _isPremiumUser,
              builder: (context, isPremiumUser, child) {
                return isPremiumUser ? _buildPremiumUserView() : _buildSubscriptionOptionsView();
              },
            );
          },
        ),
      ),
    );
  }

  // View for premium users showing their subscription details
  Widget _buildPremiumUserView() {
    Duration remainingTime = _expiryDate.value!.difference(DateTime.now());
    int remainingDays = remainingTime.inDays;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/pencil_white.png', height: 100), // App logo
        const SizedBox(height: 20),
        Text(
          'You are subscribed to the ${_subscribedPackage.value} package.',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 10),
        const Text(
          'Subscription expires on: ',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 10),
        Text(
          'Days remaining: $remainingDays',
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _showCancelConfirmationDialog,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            backgroundColor: Colors.blue[800],
          ),
          child: const Text(
            'Cancel Subscription',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Default view for non-subscribed users
  Widget _buildSubscriptionOptionsView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/pencil_white.png', height: 100), // App logo
        const SizedBox(height: 20),
        const Text(
          'Select a plan that suits your needs:',
          style: TextStyle(fontSize: 16, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            _buildSubscriptionOption('Free', 'Free', 'Ads included, Limited features and storage'),
            _buildSubscriptionOption('Month', 'PKR 1,000', 'No ads, No limitations, All features'),
            _buildSubscriptionOption('Year', 'PKR 10,000', 'No ads, No limitations, All features, save 20%'),
          ],
        ),
        const SizedBox(height: 30),
        ValueListenableBuilder<String>(
          valueListenable: _selectedPlan,
          builder: (context, selectedPlan, child) {
            return ElevatedButton(
              onPressed: selectedPlan == 'Free' ? null : _navigateToPaymentScreen, // Disable if Free is selected
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                backgroundColor: Colors.blue[800],
              ),
              child: const Text(
                'Subscribe Now',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            );
          },
        ),
        TextButton(
          onPressed: () {
            // Close or skip the screen
          },
          child: const Text('Terms and Condition | Privacy Policy'),
        ),
      ],
    );
  }

  // Subscription option button
  Widget _buildSubscriptionOption(String plan, String price, String benefit) {
    return ValueListenableBuilder<String>(
      valueListenable: _selectedPlan,
      builder: (context, selectedPlan, child) {
        return RadioListTile<String>(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                price,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
          subtitle: Text(benefit),
          value: plan,
          groupValue: selectedPlan,
          onChanged: (value) {
            _selectedPlan.value = value!;
          },
        );
      },
    );
  }
}
