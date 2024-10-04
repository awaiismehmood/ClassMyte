import 'package:classmyte/sms_screen/whatsapp_msg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:classmyte/data_management/data_retrieval.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  TextEditingController messageController = TextEditingController();
  List<String> selectedClasses = [];
  bool sendingMessage = false;
  String messageStatus = '';
  List<Map<String, String>>? contactList;
  int _selectedDelay = 15;
  final String ongoingProcessKey = 'ongoingProcess';

  @override
  void initState() {
    super.initState();
    checkOngoingProcess();
    getContactList();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> getContactList() async {
    contactList = await StudentData.getStudentData();
    setState(() {});
  }

  Future<void> checkOngoingProcess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isOngoing = prefs.getBool(ongoingProcessKey) ?? false;

    if (isOngoing) {
      setState(() {
        sendingMessage = true;
        messageStatus = 'Sending Messages...';
      });
    }
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
        
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value:
                          selectedClasses.isEmpty ? null : selectedClasses[0],
                      hint: const Text('Select Class'),
                      onChanged: sendingMessage
                          ? null
                          : (String? value) {
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
                                )),
                      ],
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: _selectedDelay,
                      hint: const Text('Select Delay'),
                      onChanged: sendingMessage
                          ? null
                          : (int? value) {
                              setState(() {
                                _selectedDelay =
                                    value ?? 15;
                              });
                            },
                      items: [0, 15, 30, 45].map((int delay) {
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
            

              if (sendingMessage)
                ElevatedButton(
                  onPressed: _cancelMessageSending,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Cancel Sending'),
                ),
              if (messageStatus.isNotEmpty)
                Text(
                  messageStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }

Future<void> _sendMessages() async {
  final PermissionStatus status = await Permission.sms.status;
  if (status.isDenied) {
    final PermissionStatus permissionStatus = await Permission.sms.request();
    if (!permissionStatus.isGranted) {
      setState(() {
        messageStatus =
            'SMS permission denied. Please enable it to send messages.';
      });
      return;
    }
  }

  if (sendingMessage) return;

  setState(() {
    sendingMessage = true;
    messageStatus = 'Sending Messages...';
  });

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(ongoingProcessKey, true);

  List<String> allPhoneNumbers = contactList!
      .where((contact) =>
          selectedClasses.isEmpty ||
          selectedClasses.contains(contact['class']))
      .map((contact) => contact['phoneNumber']!)
      .toList();

  if (allPhoneNumbers.isNotEmpty) {
    try {
    await _startForegroundService(allPhoneNumbers, messageController.text, _selectedDelay);
    } catch (error) {
      setState(() {
        sendingMessage = false;
        messageStatus = 'Failed to send messages: $error';
      });
    } finally {
      await prefs.setBool(ongoingProcessKey, false);
    }
  } else {
    setState(() {
      sendingMessage = false;
      messageStatus = 'No contacts available to send the message.';
    });
  }
}

  Future<void> _cancelMessageSending() async {
    setState(() {
      sendingMessage = false;
      messageStatus = 'Message sending cancelled.';
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ongoingProcessKey, false);
    await _stopForegroundService();
  }

  Future<void> _stopForegroundService() async {
    const platform = MethodChannel('com.example.sms/sendSMS');
    try {
      await platform.invokeMethod('stopService');
      print('Service stopped.');
    } on PlatformException catch (e) {
      print("Failed to stop service: '${e.message}'");
    }
  }

Future<void> _startForegroundService(List<String> phoneNumbers, String message, delay) async {
    const platform = MethodChannel('com.example.sms/sendSMS');
    try {
        final result = await platform.invokeMethod('sendSMS', {
            'phoneNumbers': phoneNumbers,
            'message': message,
            'delay': delay,
        });
        print('Service started: $result');
    } on PlatformException catch (e) {
        print("Failed to start service: '${e.message}'");
    }
}
}
