import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmyte/features/sms/providers/sms_providers.dart';
import 'package:classmyte/features/students/models/student_model.dart';
import 'package:classmyte/core/theme/app_colors.dart';

class SmsRecipientSelector extends ConsumerWidget {
  final List<String> availableClasses;
  const SmsRecipientSelector({super.key, required this.availableClasses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preSelected = ref.watch(preSelectedContactsProvider);
    final session = ref.watch(smsSessionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (preSelected != null) {
      return _buildPreSelectedBanner(context, ref, preSelected, isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Send To', onSurface),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildClassChip(context, ref, 'All Students', session.selectedClasses.isEmpty),
            ...availableClasses.map((className) => _buildClassChip(
              context, 
              ref, 
              className, 
              session.selectedClasses.contains(className)
            )),
          ],
        ),
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

  Widget _buildClassChip(BuildContext context, WidgetRef ref, String label, bool isSelected) {
    return InkWell(
      onTap: () {
        if (label == 'All Students') {
          ref.read(smsSessionProvider.notifier).setClasses([]);
        } else {
          ref.read(smsSessionProvider.notifier).toggleClass(label);
        }
      },
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
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildPreSelectedBanner(BuildContext context, WidgetRef ref, List<Student> students, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Selective Sending Mode',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
              InkWell(
                onTap: () => ref.read(preSelectedContactsProvider.notifier).state = null,
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Target: ${students.length} specific students selected from the Students screen.',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
