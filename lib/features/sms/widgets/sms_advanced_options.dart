import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmyte/features/sms/providers/sms_providers.dart';
import 'package:classmyte/core/theme/app_colors.dart';

class SmsAdvancedOptions extends ConsumerStatefulWidget {
  final List<String> tags;
  const SmsAdvancedOptions({super.key, required this.tags});

  @override
  ConsumerState<SmsAdvancedOptions> createState() => _SmsAdvancedOptionsState();
}

class _SmsAdvancedOptionsState extends ConsumerState<SmsAdvancedOptions> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(smsSessionProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'More Customizations',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                // Icon(
                //   _isExpanded
                //       ? Icons.keyboard_arrow_up_rounded
                //       : Icons.keyboard_arrow_down_rounded,
                //   color: AppColors.primary,
                // ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('Campaign Tag', onSurface),
          const SizedBox(height: 12),
          _buildTagSelector(ref, session),
          const SizedBox(height: 24),
          _buildSectionHeader('Advanced Controls', onSurface),
          const SizedBox(height: 12),
          _buildOptionCheckbox(
            'Exclude Inactive Students',
            session.excludeInactive,
            (val) =>
                ref.read(smsSessionProvider.notifier).setExcludeInactive(val),
            onSurface,
          ),
          _buildOptionCheckbox(
            'Enable Personalization (Prefix/Suffix)',
            session.includePersonalization,
            (val) =>
                ref.read(smsSessionProvider.notifier).setPersonalization(val),
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
                    (val) => ref
                        .read(smsSessionProvider.notifier)
                        .setInlinePrefix(val),
                    onSurface,
                  ),
                  _buildSmallCheckbox(
                    'Inline Suffix',
                    session.inlineSuffix,
                    (val) => ref
                        .read(smsSessionProvider.notifier)
                        .setInlineSuffix(val),
                    onSurface,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color onSurface) {
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

  Widget _buildTagSelector(WidgetRef ref, SmsSessionState session) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.tags.map((tag) {
        final isSelected = session.tag == tag;
        return FilterChip(
          label: Text(tag,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.primary)),
          selected: isSelected,
          onSelected: (_) => ref.read(smsSessionProvider.notifier).setTag(tag),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.primary.withOpacity(0.05),
          checkmarkColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildOptionCheckbox(
      String label, bool value, Function(bool) onChanged, Color onSurface) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              activeColor: AppColors.primary,
              onChanged: (v) => onChanged(v ?? false),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.outfit(fontSize: 14, color: onSurface)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCheckbox(
      String label, bool value, Function(bool) onChanged, Color onSurface) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (v) => onChanged(v ?? false),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 13, color: onSurface.withOpacity(0.7))),
        ],
      ),
    );
  }
}
