import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmyte/features/sms/providers/sms_providers.dart';
import 'package:classmyte/core/theme/app_colors.dart';

class SmsOptionsSection extends ConsumerWidget {
  final List<String> tags;
  const SmsOptionsSection({super.key, required this.tags});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(smsSessionProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Campaign Tag', onSurface),
        const SizedBox(height: 12),
        _buildTagSelector(context, ref, session),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'Advanced Options', onSurface),
        const SizedBox(height: 12),
        _buildOptionCheckbox(
          'Exclude Inactive Students',
          session.excludeInactive,
          (val) => ref.read(smsSessionProvider.notifier).setExcludeInactive(val),
          onSurface,
        ),
        _buildOptionCheckbox(
          'Enable Personalization (Prefix/Suffix)',
          session.includePersonalization,
          (val) => ref.read(smsSessionProvider.notifier).setPersonalization(val),
          onSurface,
        ),
        if (session.includePersonalization) ...[
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 4),
            child: Wrap(
              spacing: 16,
              children: [
                _buildSmallCheckbox(
                  'Inline Prefix',
                  session.inlinePrefix,
                  (val) => ref.read(smsSessionProvider.notifier).setInlinePrefix(val),
                  onSurface,
                ),
                _buildSmallCheckbox(
                  'Inline Suffix',
                  session.inlineSuffix,
                  (val) => ref.read(smsSessionProvider.notifier).setInlineSuffix(val),
                  onSurface,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        _buildSectionHeader(context, 'Sending Delay', onSurface),
        const SizedBox(height: 8),
        _buildDelaySelector(context, ref, session, onSurface),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color onSurface) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: onSurface.withOpacity(0.5),
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildTagSelector(BuildContext context, WidgetRef ref, SmsSessionState session) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags.map((tag) {
          final isSelected = session.tag == tag;
          return InkWell(
            onTap: () => ref.read(smsSessionProvider.notifier).setTag(tag),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                ),
              ),
              child: Text(
                tag,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOptionCheckbox(String label, bool value, Function(bool) onChanged, Color onSurface) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: value,
                activeColor: AppColors.primary,
                onChanged: (v) => onChanged(v ?? false),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(fontSize: 14, color: onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCheckbox(String label, bool value, Function(bool) onChanged, Color onSurface) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: Checkbox(
              value: value,
              activeColor: AppColors.primary,
              onChanged: (v) => onChanged(v ?? false),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 12, color: onSurface.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildDelaySelector(BuildContext context, WidgetRef ref, SmsSessionState session, Color onSurface) {
    final delays = [15, 30, 45, 60, 90, 120];
    return Container(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: delays.length,
        itemBuilder: (context, index) {
          final delay = delays[index];
          final isSelected = session.selectedDelay == delay;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${delay}s'),
              selected: isSelected,
              onSelected: (val) {
                 if (val) ref.read(smsSessionProvider.notifier).setDelay(delay);
              },
              selectedColor: AppColors.primary,
              labelStyle: GoogleFonts.outfit(
                color: isSelected ? Colors.white : AppColors.primary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: AppColors.primary.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }
}
