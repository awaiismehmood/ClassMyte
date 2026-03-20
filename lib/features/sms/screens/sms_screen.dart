import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_dialog.dart';
import 'package:classmyte/core/widgets/custom_dropdown.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:classmyte/features/premium/providers/subscription_providers.dart';
import 'package:classmyte/features/sms/data/sms_service.dart';
import 'package:classmyte/features/sms/providers/template_providers.dart';
import 'package:classmyte/features/sms/providers/sms_providers.dart';
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
  final ValueNotifier<int> selectedDelay = ValueNotifier(30);
  final ValueNotifier<bool> excludeInactive = ValueNotifier(false); // Default to false for free
  final ValueNotifier<bool> includePersonalization = ValueNotifier(true);

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

      final progress = ref.read(smsProgressProvider);
      if (progress.status == 'sending') {
        _showProcessOngoingSnackbar();
        context.push('/message-report');
      }
    });

    ref.read(smsProgressProvider.notifier).startListening();
  }

  @override
  void dispose() {
    messageController.dispose();
    sendingMessage.dispose();
    messageStatus.dispose();
    selectedClasses.dispose();
    selectedDelay.dispose();
    excludeInactive.dispose();
    includePersonalization.dispose();
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

  void _showProcessOngoingSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'A messaging process is already running.',
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => context.push('/message-report'),
        ),
      ),
    );
  }

  void sendMessage(List<Map<String, String>> contactList) async {
    final progress = ref.read(smsProgressProvider);
    if (progress.status == 'sending') {
      _showProcessOngoingSnackbar();
      return;
    }

    if (selectedClasses.value.isEmpty) {
      CustomSnackBar.showWarning(context, 'Please select at least one recipient');
      return;
    }
    if (messageController.text.isEmpty) {
      CustomSnackBar.showWarning(context, 'Please enter a message');
      return;
    }

    final permissionGranted = await MessageSender.checkSmsPermission();
    if (permissionGranted) {
      final personalization = ref.read(personalizationProvider);
      final filterByStatus = (Map<String, String> contact) {
        if (!excludeInactive.value) return true;
        return (contact['status'] ?? 'Active').toLowerCase() == 'active';
      };

      final selectedContacts = contactList
          .where((contact) =>
              (selectedClasses.value.contains("All") ||
                  selectedClasses.value.contains(contact['class'])) &&
              filterByStatus(contact))
          .toList();

      if (selectedContacts.isEmpty) {
        CustomSnackBar.showWarning(context, 'No active contacts found for selected classes');
        return;
      }

      String finalMessage = messageController.text;
      if (includePersonalization.value) {
        final prefix = personalization['prefix'] ?? '';
        final suffix = personalization['suffix'] ?? '';
        if (prefix.isNotEmpty) finalMessage = '$prefix\n$finalMessage';
        if (suffix.isNotEmpty) finalMessage = '$finalMessage\n$suffix';
      }

      List<String> phoneNumbers = selectedContacts.map((c) => c['phoneNumber']!).toList();
      List<String> names = selectedContacts.map((c) => c['name']!).toList();

      ref.read(smsProgressProvider.notifier).setLastMessage(finalMessage.trim());

      await MessageSender.sendMessages(
        phoneNumbers: phoneNumbers,
        names: names,
        message: finalMessage.trim(),
        delay: selectedDelay.value,
      );

      if (mounted) context.push('/message-report');
    } else {
      Fluttertoast.showToast(msg: "SMS Permission Denied!");
    }
  }

  void _startFreeSendFlow(BuildContext context, List<Map<String, String>> contactList) async {
    final adManager = ref.read(adManagerProvider);
    
    if (adManager.isAdLoaded.value) {
      bool adCompleted = await adManager.showRewardedAd();
      if (adCompleted) sendMessage(contactList);
    } else {
      // No ad available, show a temporary "Loading" state and then proceed after a delay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Preparing your messages...',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait a few seconds.',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Wait for 8-10 seconds as a "free tier" penalty/processing time
      await Future.delayed(const Duration(seconds: 8));
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        sendMessage(contactList);
      }
    }
  }

  void _showPremiumOptionsDialog(BuildContext context, List<Map<String, String>> contactList) {
    List<String> selectedPremium = [];
    if (selectedDelay.value != 30) selectedPremium.add('Custom Delay (${selectedDelay.value}s)');
    if (excludeInactive.value) selectedPremium.add('Inactive Student Filter');

    CustomDialog.show(
      context: context,
      title: 'Premium Options Selected',
      subtitle: 'You have selected features reserved for premium members:\n\n• ${selectedPremium.join('\n• ')}\n\nUpgrade to use these features, or continue with basic settings.',
      confirmText: 'Go Premium',
      cancelText: 'Use Basic Features',
      confirmColor: AppColors.primary,
      onConfirm: () {
        Navigator.of(context).pop();
        context.push('/subscription');
      },
      onCancel: () {
        Navigator.of(context).pop();
        // Reset to basic features
        selectedDelay.value = 30;
        excludeInactive.value = false;
        // Start the free flow
        _startFreeSendFlow(context, contactList);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentDataAsync = ref.watch(studentDataProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremiumUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final personalization = ref.watch(personalizationProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const CustomHeader(title: 'Bulk Messaging'),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.dynamicBackgroundGradient(isDark),
              ),
              child: studentDataAsync.when(
                data: (contactList) => Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                    color: Theme.of(context).colorScheme.onSurface)),
                            const SizedBox(height: 12),
                            CustomDropdown<String>(
                              value: null,
                              hintText: 'Choose Classes',
                              items: [
                                const CustomDropdownItem(
                                    value: 'All',
                                    label: 'All Students',
                                    icon: Icons.groups_outlined),
                                ...contactList
                                    .map((c) => c['class']!)
                                    .toSet()
                                    .map((name) => CustomDropdownItem(
                                        value: name,
                                        label: name,
                                        icon: Icons.class_outlined)),
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
                            _buildDelaySection(context, contactList, isPremium),
                            const SizedBox(height: 32),
                            _buildOptionsSection(context, contactList, isPremium),
                            const SizedBox(height: 32),
                            _buildMessagePreview(context, personalization),
                            const SizedBox(height: 16),
                            CustomTextField(
                              labelText: 'Message Content',
                              hintText: "Type your message here...",
                              controller: messageController,
                              maxLines: 6,
                            ),
                            const SizedBox(height: 32),
                            ValueListenableBuilder<bool>(
                              valueListenable: sendingMessage,
                              builder: (context, isSending, _) => CustomButton(
                                text: isSending ? 'Sending...' : 'Send Messages',
                                isLoading: isSending,
                                onPressed: isSending
                                    ? null
                                    : () {
                                        if (isPremium) {
                                          sendMessage(contactList);
                                          return;
                                        }

                                        // Free User Logic
                                        final usingPremium = selectedDelay.value != 30 || excludeInactive.value;
                                        if (usingPremium) {
                                          _showPremiumOptionsDialog(context, contactList);
                                        } else {
                                          _startFreeSendFlow(context, contactList);
                                        }
                                      },
                                color: AppColors.primary,
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

  Widget _buildDelaySection(BuildContext context,
      List<Map<String, String>> contactList, bool isPremium) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.more_time_rounded, color: Colors.teal),
              const SizedBox(width: 8),
              Text('Message delay time',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '(We strongly recommend a 15 second+ delay if you don\'t want to risk your SIM being blocked by Mobile Carriers or the PTA for spamming)',
            style: GoogleFonts.outfit(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                height: 1.4),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<int>(
            valueListenable: selectedDelay,
            builder: (context, delay, _) => CustomDropdown<int>(
              value: [0, 5, 10, 15, 30, 45, 60].contains(delay) ? delay : 30,
              items: [0, 5, 10, 15, 30, 45, 60].map((d) {
                return CustomDropdownItem<int>(
                  value: d,
                  label: 'Fixed ($d Sec)',
                  icon: Icons.timer_outlined,
                  trailingIcon: (!isPremium && d != 30) ? Icons.lock_outline : null,
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  selectedDelay.value = val;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagePreview(
      BuildContext context, Map<String, String> personalization) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<bool>(
      valueListenable: includePersonalization,
      builder: (context, showPersonalization, _) =>
          ValueListenableBuilder<TextEditingValue>(
        valueListenable: messageController,
        builder: (context, value, _) {
          if (value.text.isEmpty) return const SizedBox.shrink();

          final prefix = showPersonalization ? (personalization['prefix'] ?? '') : '';
          final suffix = showPersonalization ? (personalization['suffix'] ?? '') : '';

          List<String> combinedParts = [];
          if (prefix.isNotEmpty) combinedParts.add(prefix);
          combinedParts.add(value.text);
          if (suffix.isNotEmpty) combinedParts.add(suffix);

          final finalMsg = combinedParts.join('\n');
          final charCount = finalMsg.length;
          final segments = (charCount / 160).ceil();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(isDark ? 0.08 : 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Message Preview',
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    Text(
                        '$charCount chars | $segments segment${segments > 1 ? "s" : ""}',
                        style: GoogleFonts.outfit(
                            fontSize: 11, color: onSurface.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  finalMsg,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: onSurface.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context,
      List<Map<String, String>> contactList, bool isPremium) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: excludeInactive,
            builder: (context, val, _) => SwitchListTile(
              title: Row(
                children: [
                  Text('Exclude Inactive',
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: onSurface)),
                  if (!isPremium) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.lock_outline,
                        size: 14, color: Colors.amber),
                  ],
                ],
              ),
              subtitle: Text('Don\'t send to inactive students',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: onSurface.withOpacity(0.6))),
              value: val,
              activeColor: AppColors.primary,
              onChanged: (v) => excludeInactive.value = v,
            ),
          ),
          Divider(color: onSurface.withOpacity(0.1), height: 1),
          ValueListenableBuilder<bool>(
            valueListenable: includePersonalization,
            builder: (context, val, _) => SwitchListTile(
              title: Text('Apply Personalization',
                  style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: onSurface)),
              subtitle: Text('Add Prefix & Suffix from database',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: onSurface.withOpacity(0.6))),
              value: val,
              activeColor: AppColors.primary,
              onChanged: (v) => includePersonalization.value = v,
            ),
          ),
        ],
      ),
    );
  }
}
