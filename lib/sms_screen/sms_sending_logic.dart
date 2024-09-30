// // ignore_for_file: avoid_print

// import 'package:classmyte/data_management/data_retrieval.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';

// class NewMessageScreen extends StatefulWidget {
//   const NewMessageScreen({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _NewMessageScreenState createState() => _NewMessageScreenState();
// }

// class _NewMessageScreenState extends State<NewMessageScreen> {
//   TextEditingController messageController = TextEditingController();
//   List<String> selectedClasses = [];
//   bool sendingMessage = false; // Track sending process status
//   String messageStatus = '';
//   List<Map<String, String>>? contactList; // Make contactList nullable
//   List<String> logMessages = []; // List to store log messages
//   int successfulSends = 0;
//   int unsuccessfulSends = 0;

//   int _selectedDelay = 0; // Variable to store the selected delay

//   @override
//   void initState() {
//     super.initState();
//     // Fetch contact list when the screen initializes
//     getContactList();
//   }

//   @override
//   void dispose() {
//     // Dispose of any controllers or listeners
//     messageController.dispose();
//     super.dispose();
//   }

//   Future<void> getContactList() async {
//     contactList = await StudentData.getStudentData();
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (contactList == null) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Messages",
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 26,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.blue,
//         elevation: 5,
//       ),
//       resizeToAvoidBottomInset: true,
//       body: Container(
//         alignment: Alignment.center,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color.fromARGB(255, 78, 136, 207),
//               Color.fromARGB(255, 156, 184, 215)
//             ],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 10),
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 20),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     TextField(
//                       controller: messageController,
//                       decoration: InputDecoration(
//                         labelText: 'Enter your message',
//                         border: const OutlineInputBorder(),
//                         filled: true,
//                         fillColor: Colors.grey.shade200,
//                       ),
//                       maxLines: 3,
//                       onChanged: (value) {
//                         setState(() {
//                           messageController.text = value;
//                         });
//                       },
//                     ),
//                     Text(
//                       'Character Count: ${messageController.text.characters.length}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     DropdownButtonFormField<String>(
//                       value: selectedClasses.isEmpty ? null : selectedClasses[0],
//                       hint: const Text('Select Class'),
//                       onChanged: (String? value) {
//                         setState(() {
//                           selectedClasses.clear();
//                           if (value != null) selectedClasses.add(value);
//                         });
//                       },
//                       items: contactList!
//                           .map((contact) => contact['class']!)
//                           .toSet()
//                           .map((className) => DropdownMenuItem<String>(
//                                 value: className,
//                                 child: Text("Class $className"),
//                               ))
//                           .toList(),
//                     ),
//                     const SizedBox(height: 15),
//                     DropdownButtonFormField<int>(
//                       value: _selectedDelay,
//                       hint: const Text('Select Delay'),
//                       onChanged: (int? value) {
//                         setState(() {
//                           _selectedDelay = value!;
//                         });
//                       },
//                       items: [0, 15, 30].map((int delay) {
//                         return DropdownMenuItem<int>(
//                           value: delay,
//                           child: Text('$delay seconds delay'),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: messageController.text.isEmpty || sendingMessage
//                     ? null
//                     : _sendMessages,
//                 child: sendingMessage
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(),
//                       )
//                     : const Text('Send Message'),
//               ),
//               const SizedBox(height: 8),
//               if (messageStatus.isNotEmpty)
//                 Text(
//                   messageStatus,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               const SizedBox(height: 20),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: logMessages.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(
//                         logMessages[index],
//                         style: TextStyle(
//                           color: logMessages[index].contains('sent')
//                               ? Colors.green
//                               : Colors.red,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Sent: $successfulSends, Error: $unsuccessfulSends',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: unsuccessfulSends > 0 ? Colors.red : Colors.green,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _sendMessages() async {
//     // Check and request SMS permission
//     final PermissionStatus status = await Permission.sms.status;
//     if (status.isDenied) {
//       final PermissionStatus permissionStatus = await Permission.sms.request();
//       if (!permissionStatus.isGranted) {
//         setState(() {
//           messageStatus = 'SMS permission denied. Please enable it to send messages.';
//         });
//         return;
//       }
//     }

//     // Prevent starting another sending process
//     if (sendingMessage) return;

//     setState(() {
//       sendingMessage = true;
//       messageStatus = 'Sending message...';
//     });

//     successfulSends = 0;
//     unsuccessfulSends = 0;

//     List<String> allPhoneNumbers = contactList!
//         .where((contact) =>
//             selectedClasses.isEmpty || selectedClasses.contains(contact['class']))
//         .map((contact) => contact['phoneNumber']!)
//         .toList();

//     if (allPhoneNumbers.isNotEmpty) {
//       try {
//         // Send messages asynchronously
//         await Future.forEach<String>(allPhoneNumbers, (phoneNumber) async {
//           try {
//             final bool sent = await _sendSMSUsingPlatformChannel(
//                 phoneNumber, messageController.text);
//             if (mounted) {
//               setState(() {
//                 if (sent) {
//                   logMessages.add('Message sent to $phoneNumber');
//                   successfulSends++;
//                 } else {
//                   logMessages.add('Could not send message to $phoneNumber');
//                   unsuccessfulSends++;
//                 }
//                 messageStatus = 'Sending message to $phoneNumber...';
//               });
//             }
//             // Apply the selected delay between messages
//             if (_selectedDelay > 0) {
//               await Future.delayed(Duration(seconds: _selectedDelay));
//             }
//           } catch (error) {
//             if (mounted) {
//               setState(() {
//                 logMessages.add('Could not send message to $phoneNumber');
//                 unsuccessfulSends++;
//               });
//             }
//           }
//         });

//         if (mounted) {
//           setState(() {
//             sendingMessage = false;
//             messageStatus = 'Operation Completed!!';
//           });
//         }
//       } catch (error) {
//         if (mounted) {
//           setState(() {
//             sendingMessage = false;
//             messageStatus = 'Failed to send messages: $error';
//           });
//         }
//       }
//     } else {
//       if (mounted) {
//         setState(() {
//           sendingMessage = false;
//           messageStatus = 'No contacts available to send the message.';
//         });
//       }
//     }
//   }

//   Future<bool> _sendSMSUsingPlatformChannel(
//       String phoneNumber, String message) async {
//     try {
//       final bool result = await platform.invokeMethod(
//           'sendSMS', {'phoneNumber': phoneNumber, 'message': message});
//       return result;
//     } on PlatformException catch (e) {
//       print("Failed to send SMS: '${e.message}'.");
//       return false;
//     }
//   }
// }

// // Define the method channel
// const platform = MethodChannel('com.example.classmyte/sms');
