import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmyte/features/sms/providers/sms_providers.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_dropdown.dart';

class SmsDelaySelector extends ConsumerWidget {
  const SmsDelaySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(smsSessionProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final delays = [0, 15, 30, 45, 60, 90, 120];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sending Delay',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: onSurface.withOpacity(0.5),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        CustomDropdown<int>(
          value: session.selectedDelay,
          hintText: 'Select Delay',
          prefixIcon: const Icon(Icons.timer_outlined,
              color: AppColors.primary, size: 20),
          items: delays
              .map((d) => CustomDropdownItem<int>(
                    value: d,
                    label: '$d Seconds Delay',
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              ref.read(smsSessionProvider.notifier).setDelay(val);
            }
          },
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline,
                size: 14, color: onSurface.withOpacity(0.4)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'A longer delay (e.g., 30s+) is recommended for large campaigns to prevent SIM blocking by your carrier.',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: onSurface.withOpacity(0.5),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
