// ignore_for_file: avoid_print

import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  TextEditingController messageController = TextEditingController();
  List<String> selectedClasses = [];
  bool sendingMessage = false; // Track sending process status
  String messageStatus = '';
  List<Map<String, String>>? contactList; // Make contactList nullable
  List<String> logMessages = []; // List to store log messages
  int successfulSends = 0;
  int unsuccessfulSends = 0;
  int _selectedDelay = 15; // Variable to store the selected delay
  final String ongoingProcessKey = 'ongoingProcess';
  final String logsKey = 'logs'; // Key for logs in SharedPreferences

  @override
  void initState() {
    super.initState();
    // Fetch contact list when the screen initializes
    getContactList();
  // _checkOngoingProcess(); // Check ongoing process
  // _loadLogs(); // Load logs on startup
  }

  Future<void> _loadLogs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  logMessages = prefs.getStringList(logsKey) ?? [];
  setState(() {}); // Update UI
}

  Future<void> _checkOngoingProcess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool ongoingProcess = prefs.getBool(ongoingProcessKey) ?? false;
    if (ongoingProcess) {
      setState(() {
        sendingMessage = true;
        messageStatus = 'Sending messages...';
      });
      // Load the logs if necessary
      logMessages = prefs.getStringList(logsKey) ?? [];
      setState(() {}); // Update UI with loaded logs
    }
  }

  @override
  void dispose() {
    // Dispose of any controllers or listeners
    messageController.dispose();
    super.dispose();
  }

  Future<void> getContactList() async {
    contactList = await StudentData.getStudentData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (contactList == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Messages",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 5,
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 78, 136, 207),
              Color.fromARGB(255, 156, 184, 215)
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        labelText: 'Enter your message',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {
                          messageController.text = value;
                        });
                      },
                    ),
                    Text(
                      'Character Count: ${messageController.text.characters.length}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value:
                          selectedClasses.isEmpty ? null : selectedClasses[0],
                      hint: const Text('Select Class'),
                      onChanged: (String? value) {
                        setState(() {
                          selectedClasses.clear();
                          if (value != null && value != "All") {
                            selectedClasses.add(value);
                          }
                        });
                      },
                      items: [
                        const DropdownMenuItem<String>(
                          value: "All",
                          child: Text("All Classes"),
                        ),
                        ...contactList!
                            .map((contact) => contact['class']!)
                            .toSet()
                            .map((className) => DropdownMenuItem<String>(
                                  value: className,
                                  child: Text("Class $className"),
                                ))
                            .toList(),
                      ],
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: _selectedDelay,
                      hint: const Text('Select Delay'),
                      onChanged: (int? value) {
                        setState(() {
                          _selectedDelay = value!;
                        });
                      },
                      items: [0, 15, 30, 40].map((int delay) {
                        return DropdownMenuItem<int>(
                          value: delay,
                          child: Text('$delay seconds delay'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: messageController.text.isEmpty || sendingMessage
                    ? null
                    : _sendMessages,
                child: sendingMessage
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Send Message'),
              ),
              const SizedBox(height: 8),
              if (messageStatus.isNotEmpty)
                Text(
                  messageStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: logMessages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        logMessages[index],
                        style: TextStyle(
                          color: logMessages[index].contains('sent')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sent: $successfulSends, Error: $unsuccessfulSends',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: unsuccessfulSends > 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessages() async {
    // Check and request SMS permission
    final PermissionStatus status = await Permission.sms.status;
    if (status.isDenied) {
      final PermissionStatus permissionStatus = await Permission.sms.request();
      if (!permissionStatus.isGranted) {
        setState(() {
          messageStatus = 'SMS permission denied. Please enable it to send messages.';
        });
        return;
      }
    }

    // Proceed if SMS permission is granted
    if (sendingMessage) return; // Prevent starting another sending process

    setState(() {
      sendingMessage = true;
      messageStatus = 'Starting to send messages...';
    });

    // Persist sending state
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ongoingProcessKey, true);

    successfulSends = 0;
    unsuccessfulSends = 0;

    List<String> allPhoneNumbers = contactList!
        .where((contact) =>
            selectedClasses.isEmpty ||
            selectedClasses.contains(contact['class']))
        .map((contact) => contact['phoneNumber']!)
        .toList();

    if (allPhoneNumbers.isNotEmpty) {
      try {
        // Start foreground service with all phone numbers
        await _startForegroundService(allPhoneNumbers, messageController.text);

        // Send messages asynchronously
     await Future.forEach<String>(allPhoneNumbers, (phoneNumber) async {
  try {
    final bool sent = await _sendSMSUsingPlatformChannel(phoneNumber, messageController.text);
    if (mounted) {
      setState(() {
        if (sent) {
          logMessages.add('Message sent to $phoneNumber');
          successfulSends++;
        } else {
          logMessages.add('Failed to send message to $phoneNumber');
          unsuccessfulSends++;
        }
      });
      // Persist logs after updating
      await prefs.setStringList(logsKey, logMessages);
    }
    // Update notification
    await _updateNotification(phoneNumber);
  } catch (error) {
    if (mounted) {
      setState(() {
        logMessages.add('Could not send message to $phoneNumber');
        unsuccessfulSends++;
      });
    }
  }
  // Implement delay
  await Future.delayed(Duration(seconds: _selectedDelay));
});


        // After all messages have been processed
        if (mounted) {
          setState(() {
            sendingMessage = false;
            messageStatus = 'Operation Completed!';
          });
          await _completeNotification(); // Mark the notification as complete
        }
      } catch (error) {
        if (mounted) {
          setState(() {
            sendingMessage = false;
            messageStatus = 'Failed to send messages: $error';
          });
        }
      } finally {
        // Clean up sending state
        await prefs.setBool(ongoingProcessKey, false);
      }
    } else {
      if (mounted) {
        setState(() {
          sendingMessage = false;
          messageStatus = 'No contacts available to send the message.';
        });
      }
    }
  }

  Future<void> _startForegroundService(List<String> phoneNumbers, String message) async {
    const platform = MethodChannel('com.example.sms/sendSMS');
    try {
      final result = await platform.invokeMethod('sendSMS', {
        'phoneNumbers': phoneNumbers, // Pass the list of phone numbers
        'message': message,
      });
      print('Service started: $result');
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }

  Future<void> _updateNotification(String phoneNumber) async {
    await platform.invokeMethod('updateNotification', {'phoneNumber': phoneNumber});
  }

  Future<void> _completeNotification() async {
    await platform.invokeMethod('completeNotification');
  }

  Future<bool> _sendSMSUsingPlatformChannel(String phoneNumber, String message) async {
    try {
      final bool result = await platform.invokeMethod('sendSMS', {'phoneNumber': phoneNumber, 'message': message});
      return result;
    } on PlatformException catch (e) {
      print("Failed to send SMS: '${e.message}'.");
      return false;
    }
  }
}

// Define the method channel
const platform = MethodChannel('com.example.sms/sendSMS');
