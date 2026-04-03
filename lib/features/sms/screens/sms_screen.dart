import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/features/students/models/student_model.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class NewMessageScreen extends ConsumerStatefulWidget {
  final String? type;
  const NewMessageScreen({super.key, this.type});

  @override
  ConsumerState<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends ConsumerState<NewMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  final ValueNotifier<List<String>> selectedClasses = ValueNotifier([]);
  final ValueNotifier<bool> sendingMessage = ValueNotifier(false);
  final ValueNotifier<String> messageStatus = ValueNotifier('');
  final ValueNotifier<int> selectedDelay = ValueNotifier(30);
  final ValueNotifier<bool> excludeInactive =
      ValueNotifier(false); // Default to false for free
  final ValueNotifier<bool> includePersonalization = ValueNotifier(true);
  final ValueNotifier<bool> inlinePrefix = ValueNotifier(false);
  final ValueNotifier<bool> inlineSuffix = ValueNotifier(false);
  final ValueNotifier<String> selectedTag = ValueNotifier('General');

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

      if (widget.type == 'Attendance') {
        messageController.text = "Hello! [name] was marked as absent from [class] today. Please contact us for more details.";
        selectedTag.value = 'Attendance';
      }

      _checkAndShowGuide();
    });

    ref.read(smsProgressProvider.notifier).startListening();

    // Preload ads for free users
    Future.microtask(() {
      final isPremium = ref.read(subscriptionProvider).isPremiumUser;
      if (!isPremium) {
        final adManager = ref.read(adManagerProvider);
        if (!adManager.isBannerLoaded) {
          adManager.loadBannerAd(() {
            if (mounted) setState(() {});
          });
        }
        if (!adManager.isAdLoaded.value) {
          adManager.loadRewardedAd();
        }
      }
    });
  }

  @override
  void dispose() {
    // Clear pre-selected contacts when leaving so normal mode resumes next time
    ref.read(preSelectedContactsProvider.notifier).state = null;
    messageController.dispose();
    sendingMessage.dispose();
    messageStatus.dispose();
    selectedClasses.dispose();
    selectedDelay.dispose();
    excludeInactive.dispose();
    includePersonalization.dispose();
    inlinePrefix.dispose();
    inlineSuffix.dispose();
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
        AndroidInitializationSettings('@drawable/ic_sms');
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

  void sendMessage(List<Student> contactList) async {
    final preSelected = ref.read(preSelectedContactsProvider);
    final isPreSelectedMode = preSelected != null;
    final progress = ref.read(smsProgressProvider);
    if (progress.status == 'sending') {
      _showProcessOngoingSnackbar();
      return;
    }

    if (!isPreSelectedMode && selectedClasses.value.isEmpty) {
      CustomSnackBar.showWarning(
          context, 'Please select at least one recipient');
      return;
    }
    if (messageController.text.isEmpty) {
      CustomSnackBar.showWarning(context, 'Please enter a message');
      return;
    }

    final permissionGranted = await MessageSender.checkSmsPermission();
    if (permissionGranted) {
      final personalization = ref.read(personalizationProvider);
      bool filterByStatus(Student contact) {
        if (!excludeInactive.value) return true;
        return contact.status.toLowerCase() == 'active';
      }

      List<Student> selectedContacts;
      if (isPreSelectedMode) {
        // In pre-selected mode, send to exactly those contacts (optionally filter inactive)
        selectedContacts = preSelected.where(filterByStatus).toList();
      } else {
        selectedContacts = contactList
            .where((contact) =>
                (selectedClasses.value.contains("All") ||
                    selectedClasses.value.contains(contact.className)) &&
                filterByStatus(contact))
            .toList();
      }

      if (selectedContacts.isEmpty) {
        CustomSnackBar.showWarning(
            context, isPreSelectedMode
                ? 'No active contacts in selection'
                : 'No active contacts found for selected classes');
        return;
      }

      List<String> messages = [];
      for (var student in selectedContacts) {
        String msg = messageController.text;
        
        // Dynamic Placeholders
        msg = msg.replaceAll('[name]', student.name);
        msg = msg.replaceAll('[father_name]', student.fatherName);
        msg = msg.replaceAll('[class]', student.className);
        msg = msg.replaceAll('[dob]', student.dob);
        msg = msg.replaceAll('[id]', student.id);
        msg = msg.replaceAll('[phone]', student.phoneNumber);

        if (includePersonalization.value) {
          final prefix = personalization['prefix'] ?? '';
          final suffix = personalization['suffix'] ?? '';

          if (prefix.isNotEmpty) {
            msg = inlinePrefix.value ? '$prefix $msg' : '$prefix\n$msg';
          }
          if (suffix.isNotEmpty) {
            msg = inlineSuffix.value ? '$msg $suffix' : '$msg\n$suffix';
          }
        }
        messages.add(msg.trim());
      }

      List<String> phoneNumbers =
          selectedContacts.map((c) => c.phoneNumber).toList();
      List<String> names = selectedContacts.map((c) => c.name).toList();

      ref.read(smsProgressProvider.notifier).setTag(selectedTag.value);
      
      ref
          .read(smsProgressProvider.notifier)
          .setLastMessage(messages.first); // Store first message as preview

      await MessageSender.sendMessages(
        phoneNumbers: phoneNumbers,
        names: names,
        messages: messages,
        delay: selectedDelay.value,
      );

      if (mounted) context.push('/message-report');
    } else {
      Fluttertoast.showToast(msg: "SMS Permission Denied!");
    }
  }

  void _startFreeSendFlow(
      BuildContext context, List<Student> contactList) async {
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
                    'Loading Ad...',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your messages will be sent automatically after the ad.',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Wait for 10 seconds as a "free tier" penalty/processing time
      await Future.delayed(const Duration(seconds: 10));

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        sendMessage(contactList);
      }
    }
  }

  void _showPremiumOptionsDialog(
      BuildContext context, List<Student> contactList) {
    List<String> selectedPremium = [];
    if (selectedDelay.value != 30)
      selectedPremium.add('Custom Delay (${selectedDelay.value}s)');
    if (excludeInactive.value) selectedPremium.add('Inactive Student Filter');

    CustomDialog.show(
      context: context,
      title: 'Premium Options Selected',
      subtitle:
          'You have selected features reserved for premium members:\n\n• ${selectedPremium.join('\n• ')}\n\nUpgrade to use these features, or continue with basic settings.',
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
    final preSelectedContacts = ref.watch(preSelectedContactsProvider);
    final isPreSelectedMode = preSelectedContacts != null;

    return PopScope(
      canPop: !isPreSelectedMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isPreSelectedMode) {
          ref.read(preSelectedContactsProvider.notifier).state = null;
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            CustomHeader(
              title: isPreSelectedMode
                  ? 'Message ${preSelectedContacts.length} Student${preSelectedContacts.length == 1 ? '' : 's'}'
                  : 'Bulk Messaging',
              leftAction: isPreSelectedMode
                  ? InkWell(
                      onTap: () {
                        ref.read(preSelectedContactsProvider.notifier).state = null;
                        context.go('/home');
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.chevron_left,
                            color: AppColors.primary, size: 24),
                      ),
                    )
                  : null,
              rightActions: [
                _buildCircleHeaderButton(
                  icon: Icons.help_outline,
                  onTap: () => _showMessagingGuide(force: true),
                ),
              ],
            ),
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
                            if (isPreSelectedMode) ..._buildPreSelectedBanner(context, preSelectedContacts)
                            else ...[
                              Text('Select Recipients',
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface)),
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
                                      .map((c) => c.className)
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
                                      if (!selectedClasses.value
                                          .contains(value)) {
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
                            ],
                            const SizedBox(height: 32),
                            _buildDelaySection(context, contactList, isPremium),
                            const SizedBox(height: 32),
                            _buildOptionsSection(
                                context, contactList, isPremium),
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
                                text:
                                    isSending ? 'Sending...' : 'Send Messages',
                                isLoading: isSending,
                                onPressed: isSending
                                    ? null
                                    : () {
                                        if (isPremium) {
                                          sendMessage(contactList);
                                          return;
                                        }

                                        // Free User Logic
                                        final usingPremium =
                                            selectedDelay.value != 30 ||
                                                excludeInactive.value;
                                        if (usingPremium) {
                                          _showPremiumOptionsDialog(
                                              context, contactList);
                                        } else {
                                          _startFreeSendFlow(
                                              context, contactList);
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
          if (!isPremium) ref.watch(adManagerProvider).displayBannerAd(),
        ],
      ),
    ),
  );
}

  Widget _buildDelaySection(BuildContext context,
      List<Student> contactList, bool isPremium) {
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
                  trailingIcon:
                      (!isPremium && d != 30) ? Icons.lock_outline : null,
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

          final prefix =
              showPersonalization ? (personalization['prefix'] ?? '') : '';
          final suffix =
              showPersonalization ? (personalization['suffix'] ?? '') : '';

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
      List<Student> contactList, bool isPremium) {
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
              activeThumbColor: AppColors.primary,
              onChanged: (v) => excludeInactive.value = v,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: includePersonalization,
            builder: (context, val, _) => Column(
              children: [
                SwitchListTile(
                  title: Text('Apply Personalization',
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: onSurface)),
                  subtitle: Text('Add Prefix & Suffix from database',
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: onSurface.withOpacity(0.6))),
                  value: val,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => includePersonalization.value = v,
                ),
                if (val) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildInlineCheckbox(
                            'Inline Prefix',
                            inlinePrefix,
                            onSurface,
                          ),
                        ),
                        Expanded(
                          child: _buildInlineCheckbox(
                            'Inline Suffix',
                            inlineSuffix,
                            onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          Divider(color: onSurface.withOpacity(0.1), height: 1),
          ValueListenableBuilder<String>(
            valueListenable: selectedTag,
            builder: (context, tag, _) => Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Message Campaign Tag',
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: onSurface)),
                  const SizedBox(height: 12),
                  CustomDropdown<String>(
                    value: tag,
                    items: ['General', 'Attendance', 'Fees', 'Event']
                        .map((e) => CustomDropdownItem<String>(
                            value: e,
                            label: e,
                            icon: _getTagIcon(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) selectedTag.value = v;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getTagIcon(String tag) {
    switch (tag) {
      case 'Attendance': return Icons.fact_check;
      case 'Fees': return Icons.payments;
      case 'Event': return Icons.event;
      default: return Icons.campaign;
    }
  }
  List<Widget> _buildPreSelectedBanner(BuildContext context, List<Student> contacts) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(isDark ? 0.12 : 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sending to ${contacts.length} selected student${contacts.length == 1 ? '' : 's'}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ref.read(preSelectedContactsProvider.notifier).state = null;
                  },
                  child: const Icon(Icons.close, color: AppColors.primary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: contacts.map((c) => Chip(
                label: Text(
                  c.name,
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.white),
                ),
                backgroundColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide.none,
              )).toList(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Options',
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: onSurface,
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  Widget _buildCircleHeaderButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
    );
  }

  Future<void> _checkAndShowGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final showAgain = prefs.getBool('show_sms_guide') ?? true;
    if (showAgain) {
      _showMessagingGuide();
    }
  }

  void _showMessagingGuide({bool force = false}) {
    bool dontShowAgain = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.tips_and_updates, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Messaging Tips',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildGuideItem(Icons.alternate_email, 'Personalization Tags', 
                    'Use [name], [father_name], or [class] in your message. We\'ll automatically replace them for each student.'),
                const SizedBox(height: 16),
                _buildGuideItem(Icons.history, 'Batch Sending', 
                    'Messages are sent one-by-one with a delay to ensure safety and prevent spam flagging.'),
                const SizedBox(height: 16),
                _buildGuideItem(Icons.label_important_outline, 'Campaign Tags', 
                    'Tag your messages (Fees, Attendance, etc.) and track them later in the History section.'),
                const SizedBox(height: 24),
                if (!force)
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: dontShowAgain,
                          activeColor: AppColors.primary,
                          onChanged: (v) {
                            setDialogState(() => dontShowAgain = v ?? false);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Don\'t show this again', style: GoogleFonts.outfit(fontSize: 14)),
                    ],
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Got it!',
                    onPressed: () async {
                      if (!force && dontShowAgain) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('show_sms_guide', false);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(desc, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInlineCheckbox(String label, ValueNotifier<bool> notifier, Color onSurface) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, val, _) => InkWell(
        onTap: () => notifier.value = !val,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 32,
              width: 32,
              child: Checkbox(
                value: val,
                activeColor: AppColors.primary,
                onChanged: (v) => notifier.value = v ?? false,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Text(label, style: GoogleFonts.outfit(fontSize: 13, color: onSurface)),
          ],
        ),
      ),
    );
  }
}
