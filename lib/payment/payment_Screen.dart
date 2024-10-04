// ignore_for_file: use_build_context_synchronously

import 'package:classmyte/data_management/getSubscribe.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final String plan;
  final ValueNotifier<bool> _isProcessing = ValueNotifier<bool>(false);

  PaymentScreen({Key? key, required this.plan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create an instance of SubscriptionData
    final SubscriptionData subscriptionData = SubscriptionData();

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment for $plan Plan'),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: _isProcessing,
            builder: (context, isProcessing, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed with payment for the $plan Plan',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            _isProcessing.value = true; // Start processing

                            try {
                              // Simulate payment processing logic here
                              await Future.delayed(
                                  const Duration(seconds: 2)); // Simulate a delay

                              // Simulate payment success
                              bool paymentSuccessful = true;

                              if (paymentSuccessful) {
                                // Calculate expiry date based on plan
                                DateTime expiryDate = _calculateExpiryDate(plan);

                                // Update subscription in the database
                                await subscriptionData.updateSubscription(
                                    plan, expiryDate);

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Payment successful for the $plan Plan!'),
                                ));
                                // Return payment status and navigate back
                                Navigator.pop(context, paymentSuccessful);
                              }
                            } catch (error) {
                              // Handle payment error
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text(
                                  'Payment failed. Please try again.',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ));
                            } finally {
                              _isProcessing.value = false; // Stop processing
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      backgroundColor: Colors.blue[800],
                    ),
                    child: isProcessing
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Proceed to Pay',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  DateTime _calculateExpiryDate(String plan) {
    switch (plan) {
      case 'Month':
        return DateTime.now().add(const Duration(days: 30));
      case 'Year':
        return DateTime.now().add(const Duration(days: 365));
      default:
        return DateTime.now();
    }
  }
}
