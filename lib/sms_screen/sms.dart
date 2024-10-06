// ignore_for_file: library_private_types_in_public_api

import 'package:classmyte/data_management/getSubscribe.dart';
import 'package:classmyte/sms_screen/sendingLogic.dart';
import 'package:flutter/material.dart';
import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  InterstitialAd? _interstitialAd;
  final SubscriptionData subscriptionData = SubscriptionData();

  @override
  void initState() {
    super.initState();
    getContactList();
    subscriptionData
        .checkSubscriptionStatus(); // Check subscription status on init
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ad unit ID
      // adUnitId: 'ca-app-pub-6452085379535380/6875134840', // Real ad unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  void _showInterstitialAd(Function onAdShowComplete) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _loadInterstitialAd(); // Load a new ad for the next time
          onAdShowComplete();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          print('Interstitial ad failed to show: $error');
          onAdShowComplete(); // Proceed even if ad fails to show
        },
      );

      _interstitialAd!.show();
    } else {
      print('Interstitial ad is not ready yet.');
      onAdShowComplete(); // Proceed if ad is not ready
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    sendingMessage.dispose();
    messageStatus.dispose();
    selectedClasses.dispose();
    selectedDelay.dispose();
    warningMessage.dispose();
    super.dispose();
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
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
                          fillColor: Colors.grey
                              .shade50,
                        ),
                        dropdownColor: Colors.grey
                              .shade50,
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                            hintStyle: TextStyle(color: Colors.black38),
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
                                  sendMessage();
                                },
                          icon: isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(),
                                )
                              : const Icon(Icons.send, color: Colors.black,),
                          padding:
                              EdgeInsets.zero, // Remove padding for the icon
                          constraints:
                              const BoxConstraints(), // Remove constraints
                          color: Colors
                              .blue, // Change this to the color you prefer
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Cancel Sending Button (if message is being sent)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ValueListenableBuilder<bool>(
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
            ),
          ],
        ),
      ),
    );
  }
}
