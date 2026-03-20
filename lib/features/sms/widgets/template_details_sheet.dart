import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_bottom_sheet.dart';
import 'package:classmyte/features/sms/providers/template_providers.dart';
import 'package:classmyte/features/sms/widgets/add_template_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class TemplateDetailsSheet extends ConsumerWidget {
  final TemplateModel template;
  final bool isMyTemplates;

  const TemplateDetailsSheet({
    super.key,
    required this.template,
    required this.isMyTemplates,
  });

  static void show(BuildContext context, TemplateModel template, bool isMyTemplates) {
    CustomBottomSheet.show(context, title: 'Template Details', child: TemplateDetailsSheet(template: template, isMyTemplates: isMyTemplates));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (template.title.isNotEmpty) ...[
          Text(
            template.title,
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            template.text,
            style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            if (isMyTemplates) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    AddTemplateSheet.show(context, template: template);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Edit', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: CustomButton(
                text: 'Use This',
                onPressed: () {
                  ref.read(selectedTemplateProvider.notifier).state = template.text;
                  Navigator.pop(context);
                  context.push('/sms');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isMyTemplates)
          Center(
            child: TextButton(
              onPressed: () async {
                await TemplateService.removeTemplate(template.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(
                'Delete Template',
                style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
