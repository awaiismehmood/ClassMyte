import 'package:classmyte/data_management/getSubscribe.dart';
import 'package:classmyte/payment/payment_Screen.dart';
import 'package:classmyte/payment/payment_UI.dart';
import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionData subscriptionData = SubscriptionData();
  final ValueNotifier<String> _selectedPlan = ValueNotifier<String>('Free');

  @override
  void initState() {
    super.initState();
    subscriptionData.checkSubscriptionStatus();
  }

  Future<void> _cancelSubscription() async {
    await subscriptionData.updateSubscription('Free', null); // Ensure this is called on the instance

    // Update local state
    subscriptionData.isPremiumUser.value = false;
    subscriptionData.subscribedPackage.value = 'Free';
    subscriptionData.expiryDate.value = null;
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
      // MaterialPageRoute(builder: (context) => PaymentScreenTest(plan: _selectedPlan.value)),
       MaterialPageRoute(builder: (context) => PaymentScreen(plan: _selectedPlan.value)),
    );

    if (result == true) {
      subscriptionData.isPremiumUser.value = true;
      subscriptionData.subscribedPackage.value = _selectedPlan.value;
      subscriptionData.expiryDate.value = _selectedPlan.value == 'Month'
          ? DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 365));

      // Update Firestore with new subscription data using the instance
      await subscriptionData.updateSubscription(
        subscriptionData.subscribedPackage.value,
        subscriptionData.expiryDate.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the back button color to white
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22, // Make the font size a bit larger
            fontWeight: FontWeight.bold,
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
          valueListenable: subscriptionData.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const CircularProgressIndicator(); // Show loader while checking subscription
            }
            return ValueListenableBuilder<bool>(
              valueListenable: subscriptionData.isPremiumUser,
              builder: (context, isPremiumUser, child) {
                return isPremiumUser ? _buildPremiumUserView() : _buildSubscriptionOptionsView();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPremiumUserView() {
    String formattedDate = subscriptionData.expiryDate.value != null
        ? subscriptionData.expiryDate.value!.toLocal().toString().split(' ')[0]  // Get only the date part
        : 'No active subscription';

    int remainingDays = subscriptionData.expiryDate.value != null
        ? subscriptionData.expiryDate.value!.difference(DateTime.now()).inDays
        : 0;  // Default to 0 if there's no expiry date

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/pencil_white.png', height: 100), // App logo
        const SizedBox(height: 20),
        Text(
          'You are subscribed to the ${subscriptionData.subscribedPackage.value} package.',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 10),
        Text(
          'Subscription expires on: $formattedDate',
          style: const TextStyle(fontSize: 16, color: Colors.black),
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
      ],
    );
  }

  // Subscription option builder
  Widget _buildSubscriptionOption(String planName, String price, String description) {
    return GestureDetector(
      onTap: () {
        _selectedPlan.value = planName; // Update selected plan
      },
      child: ValueListenableBuilder<String>(
        valueListenable: _selectedPlan,
        builder: (context, selectedPlan, child) {
          return Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 1),
              borderRadius: BorderRadius.circular(10),
              color: selectedPlan == planName ? Colors.blueAccent.withOpacity(0.2) : Colors.white,
            ),
            child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(planName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(price, style: const TextStyle(fontSize: 16)),
                  Text(description, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
