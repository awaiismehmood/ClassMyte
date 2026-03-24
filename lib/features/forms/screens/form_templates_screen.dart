import 'dart:ui';
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
                data: (templates) => GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: templates.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildAddDashedCard(context);
                    }
                    final template = templates[index - 1];
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
    );
  }

  Widget _buildAddDashedCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => AddFormTemplateSheet.show(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
            style: BorderStyle.none, // We'll use a custom painter if we want real dots, but dashed border package might not be there. Use opacity + border for now.
          ),
          color: AppColors.primary.withOpacity(0.05),
        ),
        child: Stack(
          children: [
            // Dotted border simulation
            Positioned.fill(
              child: CustomPaint(
                painter: DashedRectPainter(
                  color: AppColors.primary.withOpacity(0.4),
                  strokeWidth: 2,
                  gap: 8,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create New',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, FormTemplate template) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () async {
            await FormGenerator.generateSamplePreview(template);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview area
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: onSurface.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: onSurface.withOpacity(0.05)),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header + Title based on placement
                            if (template.titlePlacement == 'above_header') ...[
                               if (template.titleEnabled) _buildMiniTitle(template, onSurface),
                               if (template.headerEnabled) _buildMiniHeader(template, onSurface),
                            ] else ...[
                               if (template.headerEnabled) _buildMiniHeader(template, onSurface),
                               if (template.titleEnabled) _buildMiniTitle(template, onSurface),
                            ],
                            
                            const SizedBox(height: 12),
                            // Fake body
                            if (template.bodyEnabled)
                              Column(
                                crossAxisAlignment: _getMiniAlign(template.bodyAlignment),
                                children: List.generate(3, (i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Container(
                                    height: template.bodyBold ? 5 : 3,
                                    width: i == 2 ? 40 : double.infinity,
                                    decoration: BoxDecoration(
                                      color: onSurface.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(1.5),
                                      border: template.bodyUnderline ? Border(bottom: BorderSide(color: onSurface.withOpacity(0.2), width: 1)) : null,
                                    ),
                                  ),
                                )),
                              ),
                            const Spacer(),
                            // Fake footer/signatures
                            if (template.signaturesEnabled)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(height: 2, width: 25, color: onSurface.withOpacity(0.1)),
                                  Container(height: 2, width: 25, color: onSurface.withOpacity(0.1)),
                                ],
                              ),
                          ],
                        ),
                      ),
                      // Badge
                      if (template.isDefault)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: GoogleFonts.outfit(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Info Area
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 4, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.formName,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            template.title,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 20, color: onSurface.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            AddFormTemplateSheet.show(context, template: template);
                            break;
                          case 'duplicate':
                            await FormTemplateService.duplicateTemplate(template);
                            break;
                          case 'delete':
                            _showDeleteDialog(context, template);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.copy_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Duplicate'),
                            ],
                          ),
                        ),
                        if (!template.isDefault)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
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
      subtitle:
          'Are you sure you want to remove this form template? This action cannot be undone.',
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
      subtitle:
          'Create professional documents with auto-filled student data. Use these placeholders anywhere in your content:',
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
            style: GoogleFonts.outfit(
                fontSize: 12,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                const prompt =
                    "I am using an app called ClassMyte that generates student forms. Please analyze the attached image of my school form and convert it into the ClassMyte template format. \n\n"
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
                  const SnackBar(
                      content: Text('AI Prompt copied to clipboard!')),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: Text('Copy AI Prompt',
                  style: GoogleFonts.outfit(
                      fontSize: 12, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
            child: Text(tag,
                style: GoogleFonts.firaCode(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(desc, style: GoogleFonts.outfit(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildMiniHeader(FormTemplate template, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: template.logoAlignment == 'center'
            ? MainAxisAlignment.center
            : (template.logoAlignment == 'left'
                ? MainAxisAlignment.start
                : MainAxisAlignment.end),
        children: [
          if (template.showLogo && template.logoAlignment != 'right')
            _buildMiniLogo(template),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (template.showLogo && template.logoAlignment == 'right')
            _buildMiniLogo(template),
        ],
      ),
    );
  }

  Widget _buildMiniTitle(FormTemplate template, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: _getMiniAlign(template.titleAlignment),
        children: [
          Container(
            height: template.titleBold ? 7 : 5,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
              border: template.titleUnderline
                  ? Border(
                      bottom: BorderSide(
                          color: AppColors.primary.withOpacity(0.4), width: 1))
                  : null,
            ),
          ),
          if (template.subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniLogo(FormTemplate template) {
    return Container(
      width: 15,
      height: 15,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.3),
        shape: template.logoShape == 'round'
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius:
            template.logoShape == 'round' ? null : BorderRadius.circular(2),
      ),
    );
  }

  CrossAxisAlignment _getMiniAlign(String align) {
    switch (align) {
      case 'left':
        return CrossAxisAlignment.start;
      case 'right':
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.center;
    }
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(24),
      ));

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + gap),
          paint,
        );
        distance += gap * 2;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


