import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/features/premium/subscription_screen.dart';
import 'package:classmyte/features/sms/sendingLogic.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class NewMessageScreen extends ConsumerStatefulWidget {
  const NewMessageScreen({super.key});

  @override
  ConsumerState<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends ConsumerState<NewMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  final ValueNotifier<List<String>> selectedClasses = ValueNotifier([]);
  final ValueNotifier<bool> sendingMessage = ValueNotifier(false);
  final ValueNotifier<String> messageStatus = ValueNotifier('');
  final ValueNotifier<String?> warningMessage = ValueNotifier(null);
  final ValueNotifier<int> selectedDelay = ValueNotifier(30);

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
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

  Future<void> _requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      _initializeNotifications();
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await ref.read(notificationsProvider).initialize(settings: initializationSettings);
  }

  void sendMessage(List<Map<String, String>> contactList) async {
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
      List<String> allPhoneNumbers = contactList
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
    } else {
      sendingMessage.value = false;
      messageStatus.value = "Permission denied.";
    }
  }

  void _showPremiumDialog(BuildContext context, List<Map<String, String>> contactList) {
    final adManager = ref.read(adManagerProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Send Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          content: const Text('To send a message, you can either watch an ad or upgrade to premium.', style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (adManager.isAdLoaded.value) {
                  bool adCompleted = await adManager.showRewardedAd();
                  if (adCompleted) sendMessage(contactList);
                } else {
                  Fluttertoast.showToast(msg: "Loading ad, please wait...");
                  adManager.loadRewardedAd(onAdLoaded: () async {
                    bool adCompleted = await adManager.showRewardedAd();
                    if (adCompleted) sendMessage(contactList);
                  });
                }
              },
              child: const Text('Watch Ad', style: TextStyle(color: Colors.blue, fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
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
    final studentDataAsync = ref.watch(studentDataProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremiumUser;

    return studentDataAsync.when(
      data: (contactList) => Scaffold(
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
          title: const Text('Messages', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        ValueListenableBuilder<String?>(
                          valueListenable: warningMessage,
                          builder: (context, warning, _) => warning != null
                              ? Text(warning, style: const TextStyle(color: Colors.red))
                              : const SizedBox.shrink(),
                        ),
                        ValueListenableBuilder<String>(
                          valueListenable: messageStatus,
                          builder: (context, status, _) => Text(status, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 25),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          hint: const Text('Select Recipients'),
                          onChanged: (String? value) {
                            if (value != null) {
                              if (value == "All") {
                                selectedClasses.value = ["All"];
                              } else {
                                selectedClasses.value.add(value);
                                selectedClasses.value = selectedClasses.value.where((e) => e != "All").toList();
                              }
                              warningMessage.value = null;
                            }
                          },
                          items: [
                            const DropdownMenuItem(value: "All", child: Center(child: Text("All"))),
                            ...contactList.map((c) => c['class']!).toSet().map((name) => DropdownMenuItem(value: name, child: Center(child: Text(name)))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder<List<String>>(
                          valueListenable: selectedClasses,
                          builder: (context, classes, _) => Wrap(
                            spacing: 6.0,
                            children: classes.map((c) => Chip(
                              label: Text(c),
                              onDeleted: () {
                                selectedClasses.value = List.from(selectedClasses.value)..remove(c);
                              },
                            )).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDelaySection(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomInput(isPremium, contactList),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildDelaySection() {
    return ValueListenableBuilder<int>(
      valueListenable: selectedDelay,
      builder: (context, delay, _) => Column(
        children: [0, 15, 30, 45].map((d) => RadioListTile<int>(
          title: Text('$d seconds delay'),
          value: d,
          groupValue: delay,
          onChanged: (v) => selectedDelay.value = v!,
        )).toList(),
      ),
    );
  }

  Widget _buildBottomInput(bool isPremium, List<Map<String, String>> contactList) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(hintText: "Enter your message", border: InputBorder.none),
                  maxLines: null,
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: sendingMessage,
              builder: (context, isSending, _) => IconButton(
                onPressed: isSending ? null : () {
                  if (isPremium) {
                    sendMessage(contactList);
                  } else {
                    _showPremiumDialog(context, contactList);
                  }
                },
                icon: isSending ? const CircularProgressIndicator() : const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
