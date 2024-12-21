// import 'package:flutter/material.dart';

// class PaymentScreen extends StatelessWidget {
//   final String plan;
//   const PaymentScreen({Key? key, required this.plan}) : super(key: key);

//   Future<void> _processPayment(BuildContext context) async {
//     // Simulate a payment process
//     await Future.delayed(const Duration(seconds: 2));

//     final expiryDate = plan == 'Month'
//         ? DateTime.now().add(const Duration(days: 30))
//         : DateTime.now().add(const Duration(days: 365));

//     Navigator.pop(context, {
//       'paymentSuccess': true,
//       'plan': plan,
//       'expiryDate': expiryDate,
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Payment')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => _processPayment(context),
//           child: Text('Pay for $plan'),
//         ),
//       ),
//     );
//   }
// }
