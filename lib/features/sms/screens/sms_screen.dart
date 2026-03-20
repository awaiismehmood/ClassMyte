import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_dialog.dart';
import 'package:classmyte/core/widgets/custom_dropdown.dart';
import 'package:classmyte/features/premium/providers/subscription_providers.dart';
import 'package:classmyte/features/sms/data/sms_service.dart';
import 'package:classmyte/features/sms/providers/template_providers.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

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
    Future.microtask(() {
      final templateText = ref.read(selectedTemplateProvider);
      if (templateText != null) {
        messageController.text = templateText;
        ref.read(selectedTemplateProvider.notifier).state = null;
      }
    });
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
    await ref
        .read(notificationsProvider)
        .initialize(settings: initializationSettings);
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

  void _showPremiumDialog(
      BuildContext context, List<Map<String, String>> contactList) {
    final adManager = ref.read(adManagerProvider);
    
    CustomDialog.show(
      context: context,
      title: 'Send Bulk Message',
      subtitle: 'To send bulk messages, you can either watch a quick ad or upgrade to premium for an ad-free experience.',
      confirmText: 'Go Premium',
      cancelText: 'Watch Ad',
      confirmColor: AppColors.primary,
      onConfirm: () {
        Navigator.of(context).pop();
        context.push('/subscription');
      },
      onCancel: () async {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentDataAsync = ref.watch(studentDataProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremiumUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomHeader(title: 'Bulk Messaging'),
          Expanded(
            child: Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.backgroundGradient),
              child: studentDataAsync.when(
                data: (contactList) => Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ValueListenableBuilder<String?>(
                              valueListenable: warningMessage,
                              builder: (context, warning, _) => warning != null
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Text(warning,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold)))
                                  : const SizedBox.shrink(),
                            ),
                            ValueListenableBuilder<String>(
                              valueListenable: messageStatus,
                              builder: (context, status, _) => status.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Text(status,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.outfit(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold)))
                                  : const SizedBox.shrink(),
                            ),
                            Text('Select Recipients',
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 12),
                            CustomDropdown<String>(
                              value: null,
                              hintText: 'Choose Classes',
                              fillColor: Colors.white,
                              items: [
                                const CustomDropdownItem(value: 'All', label: 'All Students', icon: Icons.groups_outlined),
                                ...contactList
                                    .map((c) => c['class']!)
                                    .toSet()
                                    .map((name) => CustomDropdownItem(value: name, label: name, icon: Icons.class_outlined)),
                              ],
                              onChanged: (String? value) {
                                if (value != null) {
                                  if (value == 'All') {
                                    selectedClasses.value = ['All'];
                                  } else {
                                    if (!selectedClasses.value.contains(value)) {
                                      selectedClasses.value =
                                          List.from(selectedClasses.value)
                                            ..add(value);
                                      selectedClasses.value = selectedClasses
                                          .value
                                          .where((e) => e != 'All')
                                          .toList();
                                    }
                                  }
                                  warningMessage.value = null;
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            ValueListenableBuilder<List<String>>(
                              valueListenable: selectedClasses,
                              builder: (context, classes, _) => Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: classes
                                    .map((c) => Chip(
                                          label: Text(c,
                                              style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                          backgroundColor: AppColors.primary,
                                          deleteIconColor: Colors.white,
                                          onDeleted: () {
                                            selectedClasses.value =
                                                List.from(selectedClasses.value)
                                                  ..remove(c);
                                          },
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                        ))
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildDelaySection(),
                            const SizedBox(height: 32),
                            Text('Message Content',
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 12),
                            TextField(
                              controller: messageController,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText: "Type your message here...",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none),
                              ),
                              style: GoogleFonts.outfit(),
                            ),
                            const SizedBox(height: 32),
                            ValueListenableBuilder<bool>(
                              valueListenable: sendingMessage,
                              builder: (context, isSending, _) => CustomButton(
                                text:
                                    isSending ? 'Sending...' : 'Send Messages',
                                isLoading: isSending,
                                onPressed: isSending
                                    ? null
                                    : () {
                                        if (isPremium) {
                                          sendMessage(contactList);
                                        } else {
                                          _showPremiumDialog(
                                              context, contactList);
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDelaySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.more_time_rounded, color: Colors.teal),
              const SizedBox(width: 8),
              Text('Message delay time', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '(We strongly recommend a 15 second+ delay if you don\'t want to risk your SIM being blocked by Mobile Carriers or the PTA for spamming)',
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<int>(
            valueListenable: selectedDelay,
            builder: (context, delay, _) => CustomDropdown<int>(
              value: [0, 5, 10, 15, 30, 45, 60].contains(delay) ? delay : 15, // Provide safe fallback
              fillColor: Colors.white,
              items: [0, 5, 10, 15, 30, 45, 60].map((d) {
                return CustomDropdownItem<int>(
                  value: d,
                  label: 'Fixed ($d Sec)',
                  icon: Icons.timer_outlined,
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) selectedDelay.value = val;
              },
            ),
          ),
        ],
      ),
    );
  }
}
