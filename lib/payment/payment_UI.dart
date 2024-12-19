// payment_screen.dart

import 'package:classmyte/payment/logic.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final String plan;
  const PaymentScreen({Key? key, required this.plan}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _accountNumberController = TextEditingController();
  final ValueNotifier<bool> _isProcessing = ValueNotifier(false);

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pass the plan name and fee based on the plan
    int fee = widget.plan == 'Month' ? 1000 : 10000;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Payment for ${widget.plan} Plan',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: _isProcessing,
            builder: (context, isProcessing, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Account Number:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _accountNumberController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your account number',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Amount to Pay: Rs. $fee',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            _isProcessing.value = true;
                            String accountNumber = _accountNumberController.text;

                            if (accountNumber.isEmpty) {
                              _showError('Please enter your account number.');
                              _isProcessing.value = false;
                              return;
                            }

                            // Call payment logic to process payment
                            bool success = await PaymentLogic.processPayment(
                                widget.plan, accountNumber, fee);

                            if (success) {
                              // Payment successful, navigate back or show success
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Payment successful for the ${widget.plan} Plan!'),
                              ));
                              Navigator.pop(context, true);
                            } else {
                              // Payment failed, show error
                              _showError('Payment failed. Please try again.');
                            }

                            _isProcessing.value = false;
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      backgroundColor: Colors.blue[800],
                    ),
                    child: isProcessing
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Proceed to Pay', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Show error message in a SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.red)),
    ));
  }
}
