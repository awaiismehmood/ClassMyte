import 'package:classmyte/payment/logic.dart';
import 'package:flutter/material.dart';
import 'package:classmyte/data_management/getSubscribe.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionData subscriptionData = SubscriptionData();
  final ValueNotifier<String> _selectedPlan = ValueNotifier<String>('Free');
  final ValueNotifier<bool> _isProcessingPayment = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    subscriptionData.checkSubscriptionStatus();
  }

  Future<void> _cancelSubscription() async {
    await subscriptionData.updateSubscription('Free', null);
    subscriptionData.isPremiumUser.value = false;
    subscriptionData.subscribedPackage.value = 'Free';
    subscriptionData.expiryDate.value = null;
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'This will cancel your current subscription. Do you want to proceed?',
        ),
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
      ),
    );
  }

  Future<void> _subscribe(String plan) async {
    _isProcessingPayment.value = true;

    String productId;
    if (plan == 'Month') {
      productId = 'monthly_plan';
    } else if (plan == 'Year') {
      productId = 'yearly_plan';
    } else {
      _isProcessingPayment.value = false;
      return;
    }

    final success = await PaymentLogic.purchasePlan(productId);
    _isProcessingPayment.value = false;

    if (success) {
      // Update subscription details based on plan
      final expiryDate = plan == 'Month'
          ? DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 365));
      subscriptionData.isPremiumUser.value = true;
      subscriptionData.subscribedPackage.value = plan;
      subscriptionData.expiryDate.value = expiryDate;

      await subscriptionData.updateSubscription(plan, expiryDate);
    } else {
      // Show error if payment fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Failed'),
          content: const Text('Could not process your payment. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan',  style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade900],
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
          valueListenable: subscriptionData.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const CircularProgressIndicator();
            }
            return ValueListenableBuilder<bool>(
              valueListenable: subscriptionData.isPremiumUser,
              builder: (context, isPremiumUser, child) {
                return isPremiumUser
                    ? _buildPremiumUserView()
                    : _buildSubscriptionOptionsView();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPremiumUserView() {
    String formattedDate = subscriptionData.expiryDate.value != null
        ? subscriptionData.expiryDate.value!.toLocal().toString().split(' ')[0]
        : 'No active subscription';

    int remainingDays = subscriptionData.expiryDate.value != null
        ? subscriptionData.expiryDate.value!
            .difference(DateTime.now())
            .inDays
        : 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
          Image.asset('assets/pencil_white.png', height: 100),
          const SizedBox(height: 20),
        const Text(
          'You are subscribed to:',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          subscriptionData.subscribedPackage.value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text('Expiry: $formattedDate'),
        Text('Days Remaining: $remainingDays'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _showCancelConfirmationDialog,
          child: const Text('Cancel Subscription'),
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
        _buildSubscriptionOption(
          'Free',
          'PKR 0',
          'Ads included, Limited features and storage',
        ),
        _buildSubscriptionOption(
          'Month',
          'PKR 1,000',
          'No ads, No limitations, All features',
        ),
        _buildSubscriptionOption(
          'Year',
          'PKR 10,000',
          'No ads, All features, save 20%',
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<bool>(
          valueListenable: _isProcessingPayment,
          builder: (context, isProcessing, child) {
            return ValueListenableBuilder<String>(
              valueListenable: _selectedPlan,
              builder: (context, selectedPlan, child) {
                return isProcessing
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: selectedPlan == 'Free'
                            ? null
                            : () => _subscribe(selectedPlan),
                        child: const Text('Subscribe Now'),
                      );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubscriptionOption(
    String planName,
    String price,
    String description,
  ) {
    return GestureDetector(
      onTap: () => _selectedPlan.value = planName,
      child:  ValueListenableBuilder<String>(
        valueListenable: _selectedPlan,
        builder: (context, selectedPlan, child) {
          return Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(10),
              color: _selectedPlan.value == planName
                  ? Colors.blueAccent.withOpacity(0.2)
                  : Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  planName,
                  style: const TextStyle(  fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(price , style: const TextStyle(fontSize: 16)),
                Text(description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          );
        }
      ),
    );
  }
}
