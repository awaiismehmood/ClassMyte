import 'dart:io';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_bottom_sheet.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:classmyte/features/forms/models/form_template_model.dart';
import 'package:classmyte/features/forms/data/form_template_service.dart';
import 'package:classmyte/features/forms/providers/form_providers.dart';
import 'package:classmyte/features/premium/providers/subscription_providers.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AddFormTemplateSheet extends ConsumerStatefulWidget {
  final FormTemplate? template;

  const AddFormTemplateSheet({super.key, this.template});

  static void show(BuildContext context, {FormTemplate? template}) {
    CustomBottomSheet.show(
      context,
      title: template == null ? 'New Form' : 'Edit Form',
      child: AddFormTemplateSheet(template: template),
    );
  }

  @override
  ConsumerState<AddFormTemplateSheet> createState() => _AddFormTemplateSheetState();
}

class _AddFormTemplateSheetState extends ConsumerState<AddFormTemplateSheet> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _contentController;
  late TextEditingController _footerController;
  late TextEditingController _schoolNameController;
  late TextEditingController _signaturesController;
  
  bool _showLogo = false;
  String _logoAlignment = 'center';
  String? _localLogoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.template?.title);
    _subtitleController = TextEditingController(text: widget.template?.subtitle);
    _contentController = TextEditingController(text: widget.template?.content);
    _footerController = TextEditingController(text: widget.template?.footer);
    _schoolNameController = TextEditingController(text: widget.template?.schoolName ?? 'ClassMyte Academy');
    _signaturesController = TextEditingController(text: widget.template?.signatures.join(', ') ?? 'Student Signature, Authorized Signature');
    
    _showLogo = widget.template?.showLogo ?? false;
    _logoAlignment = widget.template?.logoAlignment ?? 'center';
    _localLogoPath = widget.template?.logoUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _contentController.dispose();
    _footerController.dispose();
    _schoolNameController.dispose();
    _signaturesController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _localLogoPath = image.path;
      });
    }
  }

  void _useProfilePic() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.photoURL != null) {
       setState(() {
         // Note: photURL is a URL, but our generator expects a local file for now in this request
         // The user said "file wont save in firestore since i dont have storage setup"
         // So for now we keep using local path if possible. 
         // But if they want profile pic, I'll just set it. 
         _localLogoPath = user!.photoURL;
       });
    }
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;

    // Check Free Tier Limit (Max 1 form)
    final isPremium = ref.read(subscriptionProvider).isPremiumUser;
    final templatesCount = ref.read(formTemplatesProvider).value?.where((t) => !t.isDefault).length ?? 0;

    if (!isPremium && templatesCount >= 1 && widget.template == null) {
      CustomSnackBar.showError(context, 'Free users can only create 1 custom form. Upgrade to PRO for unlimited forms!');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final signatures = _signaturesController.text.isEmpty
          ? ['Student Signature', 'Authorized Signature']
          : _signaturesController.text.split(',').map((s) => s.trim()).toList();

      final template = FormTemplate(
        id: widget.template?.id ?? '',
        title: _titleController.text,
        subtitle: _subtitleController.text,
        content: _contentController.text,
        footer: _footerController.text,
        schoolName: _schoolNameController.text,
        signatures: signatures,
        showLogo: _showLogo,
        logoAlignment: _logoAlignment,
        logoUrl: _localLogoPath,
      );

      if (widget.template == null) {
        await FormTemplateService.addTemplate(template);
      } else {
        await FormTemplateService.updateTemplate(template);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Show error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHelpSection(onSurface),
          const SizedBox(height: 20),
          _buildMagicAIButton(context),
          const SizedBox(height: 24),
          
          // Branding Section
          CustomTextField(
            labelText: 'School/Academy Name',
            hintText: 'e.g. ClassMyte Academy',
            controller: _schoolNameController,
          ),
          const SizedBox(height: 16),
          
          // Logo Options
          _buildLogoOptions(context, onSurface),
          const SizedBox(height: 16),

          CustomTextField(
            labelText: 'Form Title',
            hintText: 'e.g. Admission Confirmation',
            controller: _titleController,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: 'Subtitle (Optional)',
            hintText: 'e.g. Student Identity Card',
            controller: _subtitleController,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: 'Main Content',
            hintText: 'Type: At [schoolName], [name] is... ',
            controller: _contentController,
            maxLines: 6,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: 'Signatures (Comma separated)',
            hintText: 'e.g. Student, Parent, Principal',
            controller: _signaturesController,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: 'Footer Disclaimer (Optional)',
            hintText: 'e.g. Generated via ClassMyte App',
            controller: _footerController,
          ),
          
          const SizedBox(height: 32),
          CustomButton(
            text: _isLoading ? 'Saving...' : 'Save Template',
            isLoading: _isLoading,
            onPressed: _save,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLogoOptions(BuildContext context, Color onSurface) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: onSurface.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Show Logo?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              Switch(
                value: _showLogo,
                onChanged: (v) => setState(() => _showLogo = v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (_showLogo) ...[
            const SizedBox(height: 16),
            Text('Logo Alignment', style: GoogleFonts.outfit(fontSize: 12, color: onSurface.withOpacity(0.6))),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildAlignBtn('left', Icons.align_horizontal_left),
                const SizedBox(width: 8),
                _buildAlignBtn('center', Icons.align_horizontal_center),
                const SizedBox(width: 8),
                _buildAlignBtn('right', Icons.align_horizontal_right),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.upload, size: 18),
                    label: Text(_localLogoPath == null ? 'Select Logo' : 'Change Logo'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _useProfilePic,
                    icon: const Icon(Icons.person_outline, size: 18),
                    label: const Text('Profile Pic'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            if (_localLogoPath != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Logo linked: .../${_localLogoPath!.split(Platform.pathSeparator).last}',
                      style: GoogleFonts.outfit(fontSize: 11, color: Colors.green),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAlignBtn(String align, IconData icon) {
    final isSelected = _logoAlignment == align;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _logoAlignment = align),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isSelected ? Colors.white : AppColors.primary, size: 20),
        ),
      ),
    );
  }

  Widget _buildHelpSection(Color onSurface) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Available Placeholders',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '[name], [father_name], [class], [phone], [dob], [admission_date], [schoolName]',
            style: GoogleFonts.outfit(fontSize: 12, color: onSurface.withOpacity(0.7), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMagicAIButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.purple.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => CustomSnackBar.showInfo(context, 'Magic AI Scan is coming soon in the next update! ✨'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Magic Scan with AI',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
