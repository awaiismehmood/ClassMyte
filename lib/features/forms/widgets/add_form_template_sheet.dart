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
  late TextEditingController _formNameController;
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _contentController;
  late TextEditingController _footerController;
  late TextEditingController _schoolNameController;
  late TextEditingController _signaturesController;
  
  // Customization State
  bool _showLogo = false;
  String _logoAlignment = 'center';
  String _logoShape = 'round';
  String? _localLogoPath;
  
  String _titlePlacement = 'below_header';
  String _titleAlignment = 'center';
  String _bodyAlignment = 'left';
  
  // Title Styling
  bool _titleBold = true;
  bool _titleItalic = false;
  bool _titleUnderline = false;
  double _titleFontSize = 18;

  // Subtitle Styling
  bool _subtitleBold = false;
  bool _subtitleItalic = true;
  bool _subtitleUnderline = false;
  double _subtitleFontSize = 12;

  // Body Styling
  bool _bodyBold = false;
  bool _bodyItalic = false;
  bool _bodyUnderline = false;
  double _bodyFontSize = 14;

  bool _headerEnabled = true;
  bool _titleEnabled = true;
  bool _bodyEnabled = true;
  bool _footerEnabled = true;
  bool _signaturesEnabled = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formNameController = TextEditingController(text: widget.template?.formName ?? 'Untitled Form');
    _titleController = TextEditingController(text: widget.template?.title);
    _subtitleController = TextEditingController(text: widget.template?.subtitle);
    _contentController = TextEditingController(text: widget.template?.content);
    _footerController = TextEditingController(text: widget.template?.footer);
    _schoolNameController = TextEditingController(text: widget.template?.schoolName ?? 'ClassMyte Academy');
    _signaturesController = TextEditingController(text: widget.template?.signatures.join(', ') ?? 'Student Signature, Authorized Signature');
    
    _showLogo = widget.template?.showLogo ?? false;
    _logoAlignment = widget.template?.logoAlignment ?? 'center';
    _logoShape = widget.template?.logoShape ?? 'round';
    _localLogoPath = widget.template?.logoUrl;
    
    _titlePlacement = widget.template?.titlePlacement ?? 'below_header';
    _titleAlignment = widget.template?.titleAlignment ?? 'center';
    _bodyAlignment = widget.template?.bodyAlignment ?? 'left';
    
    _titleBold = widget.template?.titleBold ?? true;
    _titleItalic = widget.template?.titleItalic ?? false;
    _titleUnderline = widget.template?.titleUnderline ?? false;
    _titleFontSize = widget.template?.titleFontSize ?? 18;

    _subtitleBold = widget.template?.subtitleBold ?? false;
    _subtitleItalic = widget.template?.subtitleItalic ?? true;
    _subtitleUnderline = widget.template?.subtitleUnderline ?? false;
    _subtitleFontSize = widget.template?.subtitleFontSize ?? 12;

    _bodyBold = widget.template?.bodyBold ?? false;
    _bodyItalic = widget.template?.bodyItalic ?? false;
    _bodyUnderline = widget.template?.bodyUnderline ?? false;
    _bodyFontSize = widget.template?.bodyFontSize ?? 14;

    _headerEnabled = widget.template?.headerEnabled ?? true;
    _titleEnabled = widget.template?.titleEnabled ?? true;
    _bodyEnabled = widget.template?.bodyEnabled ?? true;
    _footerEnabled = widget.template?.footerEnabled ?? true;
    _signaturesEnabled = widget.template?.signaturesEnabled ?? true;
  }

  @override
  void dispose() {
    _formNameController.dispose();
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
         _localLogoPath = user!.photoURL;
       });
    }
  }

  Future<void> _save() async {
    if (_formNameController.text.isEmpty || _titleController.text.isEmpty || _contentController.text.isEmpty) {
      CustomSnackBar.showError(context, 'Please fill in Form Name, Title and Content');
      return;
    }

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
        formName: _formNameController.text,
        title: _titleController.text,
        subtitle: _subtitleController.text,
        content: _contentController.text,
        footer: _footerController.text,
        schoolName: _schoolNameController.text,
        signatures: signatures,
        showLogo: _showLogo,
        logoAlignment: _logoAlignment,
        logoUrl: _localLogoPath,
        logoShape: _logoShape,
        titlePlacement: _titlePlacement,
        titleAlignment: _titleAlignment,
        bodyAlignment: _bodyAlignment,
        headerEnabled: _headerEnabled,
        titleEnabled: _titleEnabled,
        bodyEnabled: _bodyEnabled,
        footerEnabled: _footerEnabled,
        signaturesEnabled: _signaturesEnabled,
        titleBold: _titleBold,
        titleItalic: _titleItalic,
        titleUnderline: _titleUnderline,
        titleFontSize: _titleFontSize,
        subtitleBold: _subtitleBold,
        subtitleItalic: _subtitleItalic,
        subtitleUnderline: _subtitleUnderline,
        subtitleFontSize: _subtitleFontSize,
        bodyBold: _bodyBold,
        bodyItalic: _bodyItalic,
        bodyUnderline: _bodyUnderline,
        bodyFontSize: _bodyFontSize,
      );

      if (widget.template == null) {
        await FormTemplateService.addTemplate(template);
      } else {
        await FormTemplateService.updateTemplate(template);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      CustomSnackBar.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelpSection(onSurface),
          const SizedBox(height: 20),
          _buildMagicAIButton(context),
          const SizedBox(height: 24),
          
          CustomTextField(
            labelText: 'Form Display Name',
            hintText: 'e.g. Admission Form V2',
            controller: _formNameController,
          ),
          const SizedBox(height: 24),

          // Header Section
          _buildToggleableSection(
            title: 'Form Header',
            icon: Icons.vertical_align_top_rounded,
            value: _headerEnabled,
            onChanged: (v) => setState(() => _headerEnabled = v),
            content: Column(
              children: [
                CustomTextField(
                  labelText: 'School/Academy Name',
                  hintText: 'e.g. ClassMyte Academy',
                  controller: _schoolNameController,
                ),
                const SizedBox(height: 16),
                _buildLogoSettings(onSurface),
              ],
            ),
          ),

          // Title Section
          _buildToggleableSection(
            title: 'Form Title',
            icon: Icons.title_rounded,
            value: _titleEnabled,
            onChanged: (v) => setState(() => _titleEnabled = v),
            content: Column(
              children: [
                CustomTextField(
                  labelText: 'Form Title',
                  hintText: 'e.g. Admission Confirmation',
                  controller: _titleController,
                ),
                _buildStyleToolbar(
                  bold: _titleBold,
                  italic: _titleItalic,
                  underline: _titleUnderline,
                  fontSize: _titleFontSize,
                  onBoldChanged: (v) => setState(() => _titleBold = v),
                  onItalicChanged: (v) => setState(() => _titleItalic = v),
                  onUnderlineChanged: (v) => setState(() => _titleUnderline = v),
                  onSizeChanged: (v) => setState(() => _titleFontSize = v),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  labelText: 'Subtitle (Optional)',
                  hintText: 'e.g. For Office Use Only',
                  controller: _subtitleController,
                ),
                _buildStyleToolbar(
                  bold: _subtitleBold,
                  italic: _subtitleItalic,
                  underline: _subtitleUnderline,
                  fontSize: _subtitleFontSize,
                  onBoldChanged: (v) => setState(() => _subtitleBold = v),
                  onItalicChanged: (v) => setState(() => _subtitleItalic = v),
                  onUnderlineChanged: (v) => setState(() => _subtitleUnderline = v),
                  onSizeChanged: (v) => setState(() => _subtitleFontSize = v),
                ),
                const SizedBox(height: 16),
                _buildTitleStyleSettings(onSurface),
              ],
            ),
          ),

          // Body Section
          _buildToggleableSection(
            title: 'Body Content',
            icon: Icons.text_fields_rounded,
            value: _bodyEnabled,
            onChanged: (v) => setState(() => _bodyEnabled = v),
            content: Column(
              children: [
                CustomTextField(
                  labelText: 'Main Content',
                  hintText: 'Type: At [schoolName], [name] is... ',
                  controller: _contentController,
                  maxLines: 6,
                ),
                _buildStyleToolbar(
                  bold: _bodyBold,
                  italic: _bodyItalic,
                  underline: _bodyUnderline,
                  fontSize: _bodyFontSize,
                  onBoldChanged: (v) => setState(() => _bodyBold = v),
                  onItalicChanged: (v) => setState(() => _bodyItalic = v),
                  onUnderlineChanged: (v) => setState(() => _bodyUnderline = v),
                  onSizeChanged: (v) => setState(() => _bodyFontSize = v),
                ),
                const SizedBox(height: 16),
                _buildBodyStyleSettings(onSurface),
              ],
            ),
          ),

          // Signatures Section
          _buildToggleableSection(
            title: 'Signatures',
            icon: Icons.history_edu_rounded,
            value: _signaturesEnabled,
            onChanged: (v) => setState(() => _signaturesEnabled = v),
            content: CustomTextField(
              labelText: 'Signatures (Comma separated)',
              hintText: 'e.g. Student, Parent, Principal',
              controller: _signaturesController,
            ),
          ),

          // Footer Section
          _buildToggleableSection(
            title: 'Footer',
            icon: Icons.vertical_align_bottom_rounded,
            value: _footerEnabled,
            onChanged: (v) => setState(() => _footerEnabled = v),
            content: CustomTextField(
              labelText: 'Footer Disclaimer (Optional)',
              hintText: 'e.g. Generated via ClassMyte App',
              controller: _footerController,
            ),
          ),
          
          const SizedBox(height: 32),
          CustomButton(
            text: _isLoading ? 'Saving...' : 'Save Template',
            isLoading: _isLoading,
            onPressed: _save,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStyleToolbar({
    required bool bold,
    required bool italic,
    required bool underline,
    required double fontSize,
    required ValueChanged<bool> onBoldChanged,
    required ValueChanged<bool> onItalicChanged,
    required ValueChanged<bool> onUnderlineChanged,
    required ValueChanged<double> onSizeChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildIconButton(Icons.format_bold, bold, () => onBoldChanged(!bold)),
          const SizedBox(width: 4),
          _buildIconButton(Icons.format_italic, italic, () => onItalicChanged(!italic)),
          const SizedBox(width: 4),
          _buildIconButton(Icons.format_underlined, underline, () => onUnderlineChanged(!underline)),
          const VerticalDivider(),
          const Icon(Icons.text_fields, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: fontSize,
              min: 8,
              max: 32,
              divisions: 24,
              label: '${fontSize.toInt()}px',
              activeColor: AppColors.primary,
              onChanged: onSizeChanged,
            ),
          ),
          Text('${fontSize.toInt()}px', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: isActive ? Colors.white : AppColors.primary),
      ),
    );
  }

  Widget _buildToggleableSection({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: value ? AppColors.primary.withOpacity(0.2) : Colors.transparent),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(icon, color: value ? AppColors.primary : Colors.grey, size: 22),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: value ? AppColors.primary : Colors.grey,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          if (value)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildLogoSettings(Color onSurface) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Show Logo?', style: GoogleFonts.outfit(fontSize: 14)),
            Switch(
              value: _showLogo,
              onChanged: (v) => setState(() => _showLogo = v),
              activeColor: AppColors.primary,
            ),
          ],
        ),
        if (_showLogo) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Logo Shape', style: GoogleFonts.outfit(fontSize: 12, color: onSurface.withOpacity(0.5))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildChoiceBtn('round', Icons.circle_outlined, _logoShape, (v) => setState(() => _logoShape = v)),
                        const SizedBox(width: 8),
                        _buildChoiceBtn('square', Icons.crop_square_rounded, _logoShape, (v) => setState(() => _logoShape = v)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alignment', style: GoogleFonts.outfit(fontSize: 12, color: onSurface.withOpacity(0.5))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildChoiceBtn('left', Icons.align_horizontal_left, _logoAlignment, (v) => setState(() => _logoAlignment = v)),
                        const SizedBox(width: 4),
                        _buildChoiceBtn('center', Icons.align_horizontal_center, _logoAlignment, (v) => setState(() => _logoAlignment = v)),
                        const SizedBox(width: 4),
                        _buildChoiceBtn('right', Icons.align_horizontal_right, _logoAlignment, (v) => setState(() => _logoAlignment = v)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickLogo,
                  icon: const Icon(Icons.upload, size: 18),
                  label: Text(_localLogoPath == null ? 'Select Logo' : 'Change Logo', style: const TextStyle(fontSize: 12)),
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
                  label: const Text('Profile Pic', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTitleStyleSettings(Color onSurface) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Placement', style: GoogleFonts.outfit(fontSize: 12, color: onSurface.withOpacity(0.5))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChoiceBtn('above_header', Icons.arrow_upward_rounded, _titlePlacement, (v) => setState(() => _titlePlacement = v)),
                      const SizedBox(width: 8),
                      _buildChoiceBtn('below_header', Icons.arrow_downward_rounded, _titlePlacement, (v) => setState(() => _titlePlacement = v)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alignment', style: GoogleFonts.outfit(fontSize: 12, color: onSurface.withOpacity(0.5))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChoiceBtn('left', Icons.align_horizontal_left, _titleAlignment, (v) => setState(() => _titleAlignment = v)),
                      const SizedBox(width: 4),
                      _buildChoiceBtn('center', Icons.align_horizontal_center, _titleAlignment, (v) => setState(() => _titleAlignment = v)),
                      const SizedBox(width: 4),
                      _buildChoiceBtn('right', Icons.align_horizontal_right, _titleAlignment, (v) => setState(() => _titleAlignment = v)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyStyleSettings(Color onSurface) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Text Alignment', style: GoogleFonts.outfit(fontSize: 12, color: onSurface.withOpacity(0.5))),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChoiceBtn('left', Icons.format_align_left_rounded, _bodyAlignment, (v) => setState(() => _bodyAlignment = v)),
            const SizedBox(width: 8),
            _buildChoiceBtn('center', Icons.format_align_center_rounded, _bodyAlignment, (v) => setState(() => _bodyAlignment = v)),
            const SizedBox(width: 8),
            _buildChoiceBtn('justify', Icons.format_align_justify_rounded, _bodyAlignment, (v) => setState(() => _bodyAlignment = v)),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceBtn(String value, IconData icon, String current, Function(String) onSelect) {
    final isSelected = current == value;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isSelected ? Colors.white : AppColors.primary, size: 18),
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
            '[name], [father_name], [class], [phone], [dob], [admission_date], [schoolName], [gender], [religion], [nationality], [address]',
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
