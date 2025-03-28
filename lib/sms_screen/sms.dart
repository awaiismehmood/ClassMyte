// ignore_for_file: library_private_types_in_public_api
import 'package:classmyte/ads/ads.dart';
import 'package:classmyte/data_management/getSubscribe.dart';
import 'package:classmyte/main.dart';
import 'package:classmyte/premium/subscription_screen.dart';
import 'package:classmyte/sms_screen/sendingLogic.dart';
import 'package:flutter/material.dart';
import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  TextEditingController messageController = TextEditingController();
  ValueNotifier<List<String>> selectedClasses = ValueNotifier([]);
  ValueNotifier<bool> sendingMessage = ValueNotifier(false);
  ValueNotifier<String> messageStatus = ValueNotifier('');
  ValueNotifier<String?> warningMessage = ValueNotifier(null);
  ValueNotifier<int> selectedDelay = ValueNotifier(30); // Default delay
  List<Map<String, String>>? contactList;
  final SubscriptionData subscriptionData = SubscriptionData();
  final adManager = AdManager(); // Instantiate AdManager

  @override
  void initState() {
    super.initState();
    _initializeData();
    // getContactList();
    _requestNotificationPermission();
  }

  Future<void> _initializeData() async {
    await getContactList();
    await subscriptionData.checkSubscriptionStatus();
  }

  @override
  void dispose() {
    messageController.dispose();
    sendingMessage.dispose();
    messageStatus.dispose();
    selectedClasses.dispose();
    selectedDelay.dispose();
    warningMessage.dispose();
    adManager.dispose(); // Ensure the AdManager is also disposed
    super.dispose();
  }

  Future<void> _requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();

    if (status.isGranted) {
      _initializeNotifications();
    } else if (status.isDenied) {
      print("Notification permission denied");
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> getContactList() async {
    contactList = await StudentData.getStudentData();
    setState(() {});
  }

  void sendMessage() async {
    if (selectedClasses.value.isEmpty) {
      warningMessage.value = 'Please select at least one recipient';
      return;
    }

    if (messageController.text.isEmpty) {
      warningMessage.value = 'Please enter a message';
      return;
    }

    sendingMessage.value = true;
    messageStatus.value = "Sending messages...";

    final permissionGranted = await MessageSender.checkSmsPermission();
    if (permissionGranted) {
      List<String> allPhoneNumbers = contactList!
          .where((contact) =>
              selectedClasses.value.contains("All") ||
              selectedClasses.value.contains(contact['class']))
          .map((contact) => contact['phoneNumber']!)
          .toList();

      await MessageSender.sendMessages(
        allPhoneNumbers,
        messageController.text,
        selectedDelay.value,
        sendingMessage,
        messageStatus,
      );

      sendingMessage.value = false;
      messageStatus.value = "Messages sent successfully.";
    } else {
      sendingMessage.value = false;
      messageStatus.value = "Permission denied.";
    }
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Send Message',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: const Text(
            'To send a message, you can either watch an ad or upgrade to premium for uninterrupted access.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                if (adManager.isAdLoaded.value) {
                  // Show the ad if it is already loaded
                  bool adCompleted = await adManager.showRewardedAd();
                  if (adCompleted) {
                    sendMessage();
                  } else {
                    Fluttertoast.showToast(
                        msg: "Ad not completed. Please try again.");
                  }
                } else {
                  // Load and wait for the ad to be ready
                  Fluttertoast.showToast(msg: "Loading ad, please wait...");
                  adManager.loadRewardedAd(onAdLoaded: () async {
                    bool adCompleted = await adManager.showRewardedAd();
                    if (adCompleted) {
                      sendMessage();
                    } else {
                      Fluttertoast.showToast(
                          msg: "Ad not completed. Please try again.");
                    }
                  });
                }
              },
              child: const Text(
                'Watch Ad',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Navigate to Subscription screen
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ));
              },
              child: const Text('Go Premium'),
            ),
          ],
        );
      },
    );
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
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22, // Make the font size a bit larger
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [ IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {},
          ),],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                // physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      ValueListenableBuilder<String?>(
                        valueListenable: warningMessage,
                        builder: (context, warning, _) {
                          return warning != null
                              ? Text(
                                  warning,
                                  style: const TextStyle(color: Colors.red),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                      // const SizedBox(height: 10),
                      ValueListenableBuilder<String>(
                        valueListenable: messageStatus,
                        builder: (context, status, _) {
                          return Text(
                            status,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          );
                        },
                      ),

                      const SizedBox(height: 25),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 15.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        dropdownColor: Colors.grey.shade50,
                        // Background color of the dropdown items list
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        value: selectedClasses.value.isEmpty
                            ? null
                            : selectedClasses.value[0],
                        hint: const Text('Select Recipients'),
                        onChanged: (String? value) {
                          if (value != null) {
                            if (value == "All") {
                              selectedClasses.value = ["All"];
                            } else {
                              selectedClasses.value.add(value);
                              selectedClasses.value = selectedClasses.value
                                  .where((element) => element != "All")
                                  .toList();
                            }
                            warningMessage.value = null;
                          }
                        },
                        items: [
                          const DropdownMenuItem<String>(
                            value: "All",
                            child: Center(child: Text("All")),
                          ),
                          ...contactList!
                              .map((contact) => contact['class']!)
                              .toSet()
                              .map((className) => DropdownMenuItem<String>(
                                    value: className,
                                    child: Center(child: Text(className)),
                                  )),
                        ],
                      ),
                      const SizedBox(height: 20),

                      ValueListenableBuilder<List<String>>(
                        valueListenable: selectedClasses,
                        builder: (context, classes, _) {
                          return Wrap(
                            spacing: 6.0,
                            children: classes.map((String className) {
                              return Chip(
                                label: Text(className),
                                onDeleted: () {
                                  selectedClasses.value.remove(className);
                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  selectedClasses.notifyListeners();
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const Row(
                        children: [
                          SizedBox(height: 40),
                          Text(
                            'Select Delay',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: selectedDelay,
                        builder: (context, delay, _) {
                          return Column(
                            children: [
                              RadioListTile<int>(
                                title: const Text('0 seconds delay'),
                                value: 0,
                                groupValue: delay,
                                onChanged: (int? value) {
                                  if (value != null) {
                                    selectedDelay.value = value;
                                  }
                                },
                              ),
                              RadioListTile<int>(
                                title: const Text('15 seconds delay'),
                                value: 15,
                                groupValue: delay,
                                onChanged: (int? value) {
                                  if (value != null) {
                                    selectedDelay.value = value;
                                  }
                                },
                              ),
                              RadioListTile<int>(
                                title: const Text('30 seconds delay'),
                                value: 30,
                                groupValue: delay,
                                onChanged: (int? value) {
                                  if (value != null) {
                                    selectedDelay.value = value;
                                  }
                                },
                              ),
                              RadioListTile<int>(
                                title: const Text('45 seconds delay'),
                                value: 45,
                                groupValue: delay,
                                onChanged: (int? value) {
                                  if (value != null) {
                                    selectedDelay.value = value;
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Text Field with Send Button
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: Colors.white54),
                            hintText: "Enter your message",
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: sendingMessage,
                      builder: (context, isSending, _) {
                        return IconButton(
                          onPressed: isSending
                              ? null
                              : () {
                                  if (subscriptionData.isPremiumUser.value) {
                                    // Premium user sends message directly
                                    sendMessage();
                                  } else {
                                    if (selectedClasses.value.isEmpty) {
                                      warningMessage.value =
                                          'Please select at least one recipient';
                                      return;
                                    }

                                    if (messageController.text.isEmpty) {
                                      warningMessage.value =
                                          'Please enter a message';
                                      return;
                                    }
                                    // Non-premium user, show dialog
                                    _showPremiumDialog(context);
                                  }
                                },
                          icon: isSending
                              ? const CircularProgressIndicator()
                              : const Icon(Icons.send),
                          color: Colors.blue.shade900,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Cancel Sending Button (if message is being sent)
            ValueListenableBuilder<bool>(
              valueListenable: sendingMessage,
              builder: (context, isSending, _) {
                if (isSending) {
                  return ElevatedButton(
                    onPressed: () async {
                      await MessageSender.cancelMessageSending(
                        sendingMessage,
                        messageStatus,
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Cancel Sending'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
