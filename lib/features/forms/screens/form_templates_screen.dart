import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/features/forms/models/form_template_model.dart';
import 'package:classmyte/features/forms/providers/form_providers.dart';
import 'package:classmyte/features/forms/data/form_generator_service.dart';
import 'package:classmyte/features/forms/data/form_template_service.dart';
import 'package:classmyte/features/forms/widgets/add_form_template_sheet.dart';
import 'package:classmyte/core/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class FormTemplatesScreen extends ConsumerWidget {
  const FormTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(formTemplatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomHeader(
            title: 'Generate Forms',
            rightActions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: AppColors.primary),
                onPressed: () => _showInstructionsDialog(context),
              ),
            ],
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.dynamicBackgroundGradient(isDark),
              ),
              child: templatesAsync.when(
                data: (templates) => ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return _buildTemplateCard(context, template);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddFormTemplateSheet.show(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Form',
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, FormTemplate template) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: template.isDefault 
            ? Border.all(color: AppColors.primary.withOpacity(0.1), width: 1)
            : null,
      ),
      child: InkWell(
        onTap: () async {
          await FormGenerator.generateSamplePreview(template);
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: (template.isDefault ? AppColors.primary : Colors.orange)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                template.isDefault ? Icons.article_outlined : Icons.edit_note_rounded,
                color: template.isDefault ? AppColors.primary : Colors.orange,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (template.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'PRO',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              )
            else ...[
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    size: 20, color: onSurface.withOpacity(0.4)),
                onPressed: () =>
                    AddFormTemplateSheet.show(context, template: template),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.redAccent),
                onPressed: () => _showDeleteDialog(context, template),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

  void _showDeleteDialog(BuildContext context, FormTemplate template) {
    CustomDialog.show(
      context: context,
      title: 'Delete Template',
      subtitle: 'Are you sure you want to remove this form template? This action cannot be undone.',
      confirmText: 'Yes, Delete',
      confirmColor: Colors.redAccent,
      onConfirm: () async {
        await FormTemplateService.deleteTemplate(template.id);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }

  void _showInstructionsDialog(BuildContext context) {
    CustomDialog.show(
      context: context,
      title: 'How to use Forms',
      subtitle: 'Create professional documents with auto-filled student data. Use these placeholders anywhere in your content:',
      confirmText: 'Got it!',
      confirmColor: AppColors.primary,
      onConfirm: () => Navigator.pop(context),
      content: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            _buildInfoRow('[name]', 'Student\'s Full Name'),
            _buildInfoRow('[father_name]', 'Father\'s Name'),
            _buildInfoRow('[class]', 'Current Class/Grade'),
            _buildInfoRow('[phone]', 'Primary Phone Number'),
            _buildInfoRow('[dob]', 'Date of Birth'),
            _buildInfoRow('[admission_date]', 'Enrollment Date'),
            _buildInfoRow('[schoolName]', 'Your Academy Name'),
            const SizedBox(height: 24),
            _buildAIPromptSection(context),
            const SizedBox(height: 16),
            Text(
              '💡 Tap any form card to see a sample preview with dummy data.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIPromptSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Design Prompt',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a photo of your current school form to ChatGPT or Gemini and use our custom prompt to instantly format it for ClassMyte.',
            style: GoogleFonts.outfit(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                const prompt = "I am using an app called ClassMyte that generates student forms. Please analyze the attached image of my school form and convert it into the ClassMyte template format. \n\n"
                    "Available Placeholders: [name], [father_name], [class], [phone], [dob], [admission_date], [schoolName]\n\n"
                    "Please provide me with:\n"
                    "1. Form Title\n"
                    "2. Subtitle\n"
                    "3. Main Content (Use the placeholders provided above)\n"
                    "4. Signatures (Comma-separated list)\n"
                    "5. Footer\n\n"
                    "Format the output for direct copy-pasting.";
                Clipboard.setData(const ClipboardData(text: prompt));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI Prompt copied to clipboard!')),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: Text('Copy AI Prompt', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String tag, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(tag, style: GoogleFonts.firaCode(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(desc, style: GoogleFonts.outfit(fontSize: 13))),
        ],
      ),
    );
  }
}
