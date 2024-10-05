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
  List<String> selectedClasses = [];
  ValueNotifier<bool> sendingMessage = ValueNotifier(false);
  ValueNotifier<String> messageStatus = ValueNotifier('');
  List<Map<String, String>>? contactList;
  int _selectedDelay = 15;
  InterstitialAd? _interstitialAd;
  final SubscriptionData subscriptionData =
      SubscriptionData(); // Instance of SubscriptionData

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
    super.dispose();
  }

  Future<void> getContactList() async {
    contactList = await StudentData.getStudentData();
    setState(() {});
  }

  void sendMessage() async {
    sendingMessage.value = true; // Set sending to true
    messageStatus.value = "Sending messages...";

    final permissionGranted = await MessageSender.checkSmsPermission();
    if (permissionGranted) {
      List<String> allPhoneNumbers = contactList!
          .where((contact) =>
              selectedClasses.isEmpty ||
              selectedClasses.contains(contact['class']))
          .map((contact) => contact['phoneNumber']!)
          .toList();

      await MessageSender.sendMessages(
        allPhoneNumbers,
        messageController.text,
        _selectedDelay,
        sendingMessage,
        messageStatus,
      );

      // Reset sending state after sending is complete
      sendingMessage.value = false;
      messageStatus.value = "Messages sent successfully.";
    } else {
      sendingMessage.value = false; // Reset sending state if permission denied
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
        title: const Text("Messages"),
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
      resizeToAvoidBottomInset: true,
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
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
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
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            value: selectedClasses.isEmpty
                                ? null
                                : selectedClasses[0],
                            hint: const Text('Select Class'),
                            onChanged: (String? value) {
                              if (value != null && value != "All") {
                                selectedClasses.clear();
                                selectedClasses.add(value);
                              }
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
                          const Text('Select Delay'),
                          RadioListTile<int>(
                            title: const Text('0 seconds delay'),
                            value: 0,
                            groupValue: _selectedDelay,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedDelay = value!;
                                if (!subscriptionData.isPremiumUser.value) {
                                  _showInterstitialAd(() {
                                    // Action to take after the ad is shown or dismissed
                                    // Continue with selecting 0 delay, etc.
                                    _selectedDelay = 0;
                                  });
                                } else {
                                  // If the user is premium, proceed without showing the ad
                                  _selectedDelay = 0;
                                }
                              });
                            },
                          ),
                          if (_selectedDelay == 0)
                            const Text(
                              "Terms and Conditions apply!",
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          RadioListTile<int>(
                            title: const Text('15 seconds delay'),
                            value: 15,
                            groupValue: _selectedDelay,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedDelay = value!;
                              });
                            },
                          ),
                          RadioListTile<int>(
                            title: const Text('30 seconds delay'),
                            value: 30,
                            groupValue: _selectedDelay,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedDelay = value!;
                              });
                            },
                          ),
                          RadioListTile<int>(
                            title: const Text('45 seconds delay'),
                            value: 45,
                            groupValue: _selectedDelay,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedDelay = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(30)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            hintText: "Enter your message",
                            // labelText: 'Enter your message',
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ValueListenableBuilder<bool>(
                        valueListenable: sendingMessage,
                        builder: (context, isSending, _) {
                          return IconButton(
                            onPressed:
                                messageController.text.isEmpty || isSending
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
                                : const Icon(Icons.send), // Send message icon
                            padding: EdgeInsets.zero, // Remove any padding
                            constraints:
                                const BoxConstraints(), // Remove constraints for the icon button
                            color: Colors
                                .black, // Change this to your preferred icon color
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
