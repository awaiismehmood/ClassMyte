import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:classmyte/features/sms/providers/template_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalizeMessageScreen extends ConsumerStatefulWidget {
  const PersonalizeMessageScreen({super.key});

  @override
  ConsumerState<PersonalizeMessageScreen> createState() => _PersonalizeMessageScreenState();
}

class _PersonalizeMessageScreenState extends ConsumerState<PersonalizeMessageScreen> {
  late TextEditingController _prefixController;
  late TextEditingController _suffixController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(personalizationProvider);
    _prefixController = TextEditingController(text: prefs['prefix']);
    _suffixController = TextEditingController(text: prefs['suffix']);
  }

  Future<void> _saveConfig() async {
    setState(() => _isLoading = true);
    await ref.read(personalizationProvider.notifier).save(
          _prefixController.text.trim(),
          _suffixController.text.trim(),
        );
    setState(() => _isLoading = false);
    if (mounted) {
      CustomSnackBar.showSuccess(context, 'Personalization settings saved');
    }
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _suffixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Map<String, String>>(personalizationProvider, (previous, next) {
      if ((previous == null || previous['prefix'] != next['prefix']) && _prefixController.text.isEmpty) {
        _prefixController.text = next['prefix'] ?? '';
      }
      if ((previous == null || previous['suffix'] != next['suffix']) && _suffixController.text.isEmpty) {
        _suffixController.text = next['suffix'] ?? '';
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const CustomHeader(title: 'Personalize Message'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set a default start and end to attach to your bulk messages automatically. This helps to make messages more personalized.',
                    style: GoogleFonts.outfit(color: onSurface.withOpacity(0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start of Message (Prefix)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: onSurface)),
                        const SizedBox(height: 12),
                        CustomTextField(
                          labelText: 'Prefix',
                          hintText: 'e.g. Hello there,',
                          controller: _prefixController,
                          prefixIcon: Icons.format_quote_outlined,
                        ),
                        const SizedBox(height: 24),
                        Text('End of Message (Suffix)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: onSurface)),
                        const SizedBox(height: 12),
                        CustomTextField(
                          labelText: 'Suffix',
                          hintText: 'e.g. Best regards, ClassMyte Team',
                          controller: _suffixController,
                          prefixIcon: Icons.format_quote_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'Save Personalization',
                    isLoading: _isLoading,
                    onPressed: _saveConfig,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
