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
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (preSelected != null) {
      return _buildPreSelectedBanner(context, ref, preSelected);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send To',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: onSurface.withOpacity(0.5),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        _buildMultiClassDropdown(context, ref, session),
        if (session.selectedClasses.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSelectedChipsWrap(ref, session),
        ],
      ],
    );
  }

  Widget _buildMultiClassDropdown(BuildContext context, WidgetRef ref, SmsSessionState session) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    
    final summaryLabel = session.selectedClasses.isEmpty 
        ? 'All Students' 
        : '${session.selectedClasses.length} Classes Selected';

    return InkWell(
      onTap: () => _showMultiSelectDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.group_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                summaryLabel,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: session.selectedClasses.isEmpty ? onSurface.withOpacity(0.4) : onSurface,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: onSurface.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _showMultiSelectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final session = ref.watch(smsSessionProvider);
            final classes = ['All Students', ...availableClasses];
            return AlertDialog(
              title: Text('Select Targets', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              content: Container(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: classes.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.05)),
                  itemBuilder: (context, index) {
                    final label = classes[index];
                    final bool isSelected = label == 'All Students' 
                        ? session.selectedClasses.isEmpty 
                        : session.selectedClasses.contains(label);
                    
                    return CheckboxListTile(
                      title: Text(label, style: GoogleFonts.outfit(fontSize: 15)),
                      value: isSelected,
                      activeColor: AppColors.primary,
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        if (label == 'All Students') {
                          ref.read(smsSessionProvider.notifier).setClasses([]);
                        } else {
                          ref.read(smsSessionProvider.notifier).toggleClass(label);
                        }
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Done', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSelectedChipsWrap(WidgetRef ref, SmsSessionState session) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: session.selectedClasses.map((cl) => Chip(
        label: Text(cl, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white)),
        backgroundColor: AppColors.primary,
        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
        onDeleted: () => ref.read(smsSessionProvider.notifier).toggleClass(cl),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      )).toList(),
    );
  }

  Widget _buildPreSelectedBanner(BuildContext context, WidgetRef ref, List<Student> students) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Target: ${students.length} specific students selected.',
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
