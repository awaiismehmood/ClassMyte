import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final TextEditingController? controller;
  final String? inputLabel;
  final String? inputHint;
  final bool isPassword;
  final bool isLoading;
  final Widget? content;

  const CustomDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor = AppColors.primary,
    required this.onConfirm,
    this.onCancel,
    this.controller,
    this.inputLabel,
    this.inputHint,
    this.isPassword = false,
    this.isLoading = false,
    this.content,
  });

  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = AppColors.primary,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    TextEditingController? controller,
    String? inputLabel,
    String? inputHint,
    bool isPassword = false,
    bool isLoading = false,
    Widget? content,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) => CustomDialog(
        title: title,
        subtitle: subtitle,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
        onCancel: onCancel,
        controller: controller,
        inputLabel: inputLabel,
        inputHint: inputHint,
        isPassword: isPassword,
        isLoading: isLoading,
        content: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 10,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning/Alert Icon for destructive actions
              if (confirmColor == Colors.redAccent)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: Colors.redAccent, size: 32),
                ),
              
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: onSurface.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),
              ],

              if (controller != null) ...[
                const SizedBox(height: 24),
                CustomTextField(
                  labelText: inputLabel ?? '',
                  hintText: inputHint ?? '',
                  prefixIcon: isPassword ? Icons.lock_outline : Icons.edit_note_outlined,
                  controller: controller!,
                  isPassword: isPassword,
                ),
              ],

              if (content != null) ...[
                const SizedBox(height: 16),
                content!,
              ],

              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (onCancel != null) {
                                onCancel!();
                              } else {
                                Navigator.pop(context);
                              }
                            },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        cancelText,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color: onSurface.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: confirmText,
                      color: confirmColor,
                      isLoading: isLoading,
                      onPressed: onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
