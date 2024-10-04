// ignore_for_file: use_build_context_synchronously

import 'package:classmyte/data_management/getSubscribe.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final String plan;
  final ValueNotifier<bool> _isProcessing = ValueNotifier<bool>(false);

  PaymentScreen({required this.plan});

  @override
  Widget build(BuildContext context) {
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
                            // Simulate payment processing logic here
                            await Future.delayed(
                                const Duration(seconds: 2)); // Simulate a delay
                            bool paymentSuccessful =
                                true; // Simulate payment success

                            if (paymentSuccessful) {
                              // Calculate expiry date based on plan
                              DateTime expiryDate;
                              if (plan == 'Month') {
                                expiryDate = DateTime.now()
                                    .add(const Duration(days: 30));
                              } else if (plan == 'Year') {
                                expiryDate = DateTime.now()
                                    .add(const Duration(days: 365));
                              } else {
                                expiryDate = DateTime.now();
                              }

                              await SubscriptionData.updateSubscription(
                                  plan, expiryDate);

                              // Inside PaymentScreen class
                              Navigator.pop(context,
                                  paymentSuccessful); // Return payment status

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    'Payment successful for the $plan Plan!'),
                              ));
                            }

                            _isProcessing.value = false; // Stop processing
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
}
