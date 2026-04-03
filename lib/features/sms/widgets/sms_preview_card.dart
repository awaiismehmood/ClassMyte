import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmyte/features/sms/providers/sms_providers.dart';
import 'package:classmyte/features/sms/providers/template_providers.dart';
import 'package:classmyte/core/theme/app_colors.dart';

class SmsPreviewCard extends ConsumerWidget {
  final String message;
  const SmsPreviewCard({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(smsSessionProvider);
    final schoolSettings = ref.watch(personalizationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final prefixText = schoolSettings['prefix'] ?? '';
    final suffixText = schoolSettings['suffix'] ?? '';

    String previewText = message;
    
    // Preview Personalization
    if (session.includePersonalization) {
      final prefix = session.inlinePrefix 
          ? '$prefixText '
          : '$prefixText\n';
      
      final suffix = session.inlineSuffix
          ? ' $suffixText'
          : '\n$suffixText';

      previewText = "${prefixText.isNotEmpty ? prefix : ''}$message${suffixText.isNotEmpty ? suffix : ''}";
    }

    // Mock student data for preview
    previewText = previewText.replaceAll('[name]', 'Ahmad Ali');
    previewText = previewText.replaceAll('[father_name]', 'Zubair Ahmad');
    previewText = previewText.replaceAll('[class]', 'Class 5th (B)');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Live Preview',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            previewText.isEmpty ? 'Start typing to see preview...' : previewText,
            style: GoogleFonts.outfit(
              fontSize: 15,
              height: 1.5,
              color: previewText.isEmpty ? Colors.grey : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
