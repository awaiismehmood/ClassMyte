import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:classmyte/core/widgets/custom_bottom_sheet.dart';
import 'package:classmyte/features/sms/providers/template_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTemplateSheet extends ConsumerStatefulWidget {
  final TemplateModel? existingTemplate;
  const AddTemplateSheet({super.key, this.existingTemplate});

  static void show(BuildContext context, {TemplateModel? template}) {
    CustomBottomSheet.show(context, title: template == null ? 'New Template' : 'Edit Template', child: AddTemplateSheet(existingTemplate: template));
  }

  @override
  ConsumerState<AddTemplateSheet> createState() => _AddTemplateSheetState();
}

class _AddTemplateSheetState extends ConsumerState<AddTemplateSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingTemplate?.title ?? '');
    _textController = TextEditingController(text: widget.existingTemplate?.text ?? '');
  }

  void _save() async {
    if (_titleController.text.trim().isEmpty || _textController.text.trim().isEmpty) return;

    final newTemplate = TemplateModel(
      id: widget.existingTemplate?.id ?? '', // TemplateService handles generation for new ones inside set()
      title: _titleController.text.trim(),
      text: _textController.text.trim(),
      category: 'Custom', // User templates no longer use categories
    );

    if (widget.existingTemplate != null) {
      await TemplateService.updateTemplate(newTemplate);
    } else {
      await TemplateService.addTemplate(newTemplate);
    }
    
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          labelText: 'Title',
          hintText: 'e.g. Special Offer',
          controller: _titleController,
          prefixIcon: Icons.title,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: 'Message Body',
          hintText: 'Enter your message template here...',
          controller: _textController,
          maxLines: 5,
        ),
        const SizedBox(height: 24),
        CustomButton(text: 'Save Template', onPressed: _save),
      ],
    );
  }
}
