import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_button.dart';

class MessagingGuideDialog extends StatefulWidget {
  final bool force;
  const MessagingGuideDialog({super.key, this.force = false});

  static void show(BuildContext context, {bool force = false}) {
    showDialog(
      context: context,
      builder: (context) => MessagingGuideDialog(force: force),
    );
  }

  @override
  State<MessagingGuideDialog> createState() => _MessagingGuideDialogState();
}

class _MessagingGuideDialogState extends State<MessagingGuideDialog> {
  bool dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            if (!widget.force)
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: dontShowAgain,
                      activeColor: AppColors.primary,
                      onChanged: (v) {
                        setState(() => dontShowAgain = v ?? false);
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
                  if (!widget.force && dontShowAgain) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('show_sms_guide', false);
                  }
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ],
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
}
