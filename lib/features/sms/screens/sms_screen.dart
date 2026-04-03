import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/core/widgets/custom_dialog.dart';
import 'package:classmyte/core/providers/providers.dart';

// Features
import 'package:classmyte/features/sms/providers/sms_providers.dart';
import 'package:classmyte/features/sms/providers/template_providers.dart';
import 'package:classmyte/features/sms/data/sms_service.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:classmyte/features/premium/providers/subscription_providers.dart';
import 'package:classmyte/features/sms/widgets/sms_remote_lock_card.dart';
import 'package:classmyte/features/sms/widgets/sms_guide_dialog.dart';
import 'package:classmyte/features/sms/widgets/sms_preview_card.dart';
import 'package:classmyte/features/sms/widgets/sms_recipient_selector.dart';
import 'package:classmyte/features/sms/widgets/sms_options_section.dart';

class NewMessageScreen extends ConsumerStatefulWidget {
  const NewMessageScreen({super.key});

  @override
  ConsumerState<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends ConsumerState<NewMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  final ValueNotifier<String> messageStatus = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowGuide();
      final isPremium = ref.read(subscriptionProvider).isPremiumUser;
      if (!isPremium) {
        ref.read(adManagerProvider).loadRewardedAd();
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    messageStatus.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final showAgain = prefs.getBool('show_sms_guide') ?? true;
    if (showAgain) {
      MessagingGuideDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentDataAsync = ref.watch(studentDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preSelected = ref.watch(preSelectedContactsProvider);
    final isPreSelectedMode = preSelected != null;

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
              title: isPreSelectedMode ? 'Selective Messaging' : 'Bulk Messaging',
              rightActions: [
                _buildCircleHeaderButton(
                  icon: Icons.help_outline,
                  onTap: () => MessagingGuideDialog.show(context, force: true),
                ),
              ],
            ),
            Expanded(
              child: studentDataAsync.when(
                data: (students) {
                  final availableClasses = students.map((s) => s.className).toSet().toList();
                  return Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.dynamicBackgroundGradient(isDark),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const RemoteProcessLockCard(),
                          _buildStatusMessage(),
                          SmsRecipientSelector(availableClasses: availableClasses),
                          const SizedBox(height: 24),
                          _buildSectionHeader(context, 'Message Content'),
                          const SizedBox(height: 12),
                          _buildMessageInput(context),
                          const SizedBox(height: 24),
                          ValueListenableBuilder<String>(
                            valueListenable: messageStatus,
                            builder: (context, msg, _) => SmsPreviewCard(message: msg),
                          ),
                          const SizedBox(height: 24),
                          SmsOptionsSection(tags: const ['General', 'Attendance', 'Fees', 'Event']),
                          const SizedBox(height: 40),
                          _buildSendButton(context, students),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: messageController,
        maxLines: 5,
        onChanged: (v) => messageStatus.value = v,
        style: GoogleFonts.outfit(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Enter your message study here...\nUse [name] for student personalization.',
          hintStyle: GoogleFonts.outfit(color: Colors.grey.withOpacity(0.5)),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return ValueListenableBuilder<String>(
      valueListenable: messageStatus,
      builder: (context, status, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSendButton(BuildContext context, List<dynamic> allStudents) {
    final progress = ref.watch(smsProgressProvider);
    final isSending = progress.status == 'sending';
    final isPremium = ref.read(subscriptionProvider).isPremiumUser;

    return CustomButton(
      text: isSending ? 'Campaign in Progress...' : 'Launch Campaign',
      icon: Icons.send_rounded,
      isLoading: isSending,
      onPressed: isSending ? null : () => _validateAndSend(context, allStudents, isPremium),
    );
  }

  Future<void> _validateAndSend(BuildContext context, List<dynamic> allStudents, bool isPremium) async {
    final session = ref.read(smsSessionProvider);
    final preSelected = ref.read(preSelectedContactsProvider);
    
    if (messageController.text.trim().isEmpty) {
      CustomSnackBar.showError(context, 'Please enter a message content.');
      return;
    }

    List<dynamic> targetStudents = [];
    if (preSelected != null) {
      targetStudents = preSelected;
    } else {
      if (session.selectedClasses.isEmpty) {
        targetStudents = allStudents;
      } else {
        targetStudents = allStudents.where((s) => session.selectedClasses.contains(s.className)).toList();
      }
    }

    if (targetStudents.isEmpty) {
      CustomSnackBar.showError(context, 'No recipients found for the selected criteria.');
      return;
    }

    if (!isPremium) {
      final isUsingPremiumFeature = session.selectedDelay != 30 || session.excludeInactive || preSelected != null;
      if (isUsingPremiumFeature) {
        _showPremiumWarning(context, targetStudents);
        return;
      }
      final adManager = ref.read(adManagerProvider);
      final success = await adManager.showRewardedAd();
      if (success) {
        _executeSending(targetStudents);
      } else {
        if (mounted) CustomSnackBar.showError(context, 'Ad failed to show. Please try again.');
      }
    } else {
      _executeSending(targetStudents);
    }
  }

  void _executeSending(List<dynamic> students) {
    final session = ref.read(smsSessionProvider);
    final schoolSettings = ref.read(personalizationProvider);
    final prefixText = schoolSettings['prefix'] ?? '';
    final suffixText = schoolSettings['suffix'] ?? '';
    
    final List<String> phoneNumbers = [];
    final List<String> names = [];
    final List<String> customMessages = [];
    
    for (var student in students) {
      phoneNumbers.add(student.phoneNumber);
      names.add(student.name);
      
      String msg = messageController.text;
      
      if (session.includePersonalization) {
        final prefix = session.inlinePrefix ? '$prefixText ' : '$prefixText\n';
        final suffix = session.inlineSuffix ? ' $suffixText' : '\n$suffixText';
        msg = "${prefixText.isNotEmpty ? prefix : ''}$msg${suffixText.isNotEmpty ? suffix : ''}";
      }

      msg = msg.replaceAll('[name]', student.name);
      msg = msg.replaceAll('[father_name]', student.fatherName);
      msg = msg.replaceAll('[class]', student.className);
      msg = msg.replaceAll('[dob]', student.dob ?? '');
      msg = msg.replaceAll('[id]', student.id);
      msg = msg.replaceAll('[phone]', student.phoneNumber);
      
      customMessages.add(msg);
    }

    // Setup progress tracker filters
    ref.read(smsProgressProvider.notifier).setLastMessage(messageController.text);
    ref.read(smsProgressProvider.notifier).setTag(session.tag);
    ref.read(smsProgressProvider.notifier).startListening();

    // Trigger Native SMS
    MessageSender.sendMessages(
      phoneNumbers: phoneNumbers,
      names: names,
      messages: customMessages,
      delay: session.selectedDelay,
    );
    
    CustomSnackBar.showSuccess(context, 'Campaign started! You can track progress here.');
  }

  void _showPremiumWarning(BuildContext context, List<dynamic> students) {
    CustomDialog.show(
      context: context,
      title: 'Premium Required',
      subtitle: 'Custom delays, selective sending, and excluding inactive students are premium features. Upgrade to unlock full campaign control!',
      confirmText: 'Upgrade Now',
      cancelText: 'Use Free Mode (30s delay)',
      onConfirm: () => context.push('/subscription'),
      onCancel: () {
        ref.read(smsSessionProvider.notifier).setDelay(30);
        ref.read(smsSessionProvider.notifier).setExcludeInactive(false);
        // If they were in selective mode, they must go back to "All" or a single class
        _executeSending(students);
      },
    );
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
}
