import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:classmyte/core/widgets/custom_bottom_sheet.dart';
import 'package:classmyte/features/sms/providers/template_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTemplateSheet extends ConsumerStatefulWidget {
  const AddTemplateSheet({super.key});

  static void show(BuildContext context) {
    CustomBottomSheet.show(context, title: 'New Template', child: const AddTemplateSheet());
  }

  @override
  ConsumerState<AddTemplateSheet> createState() => _AddTemplateSheetState();
}

class _AddTemplateSheetState extends ConsumerState<AddTemplateSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  String _selectedCategory = 'Anniversary';

  void _save() {
    if (_titleController.text.trim().isEmpty || _textController.text.trim().isEmpty) return;

    final newTemplate = TemplateModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      text: _textController.text.trim(),
      category: _selectedCategory,
    );

    ref.read(userTemplatesProvider.notifier).addTemplate(newTemplate);
    Navigator.pop(context);
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
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Category',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          items: ['Anniversary', 'Birthday', 'Sales', 'Festivals']
              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.outfit())))
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
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
