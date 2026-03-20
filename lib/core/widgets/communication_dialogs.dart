import 'package:classmyte/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunicationDialogs {
  static void showNumberSelectionDialog({
    required BuildContext context,
    required String title,
    required String primaryNumber,
    required String? altNumber,
    required Function(String) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              _buildSelectionTile(
                context,
                icon: Icons.phone_outlined,
                title: 'Primary Number',
                subtitle: primaryNumber,
                onTap: () {
                  Navigator.pop(context);
                  onSelected(primaryNumber);
                },
              ),
              if (altNumber != null && altNumber.isNotEmpty && altNumber != '0') ...[
                const SizedBox(height: 12),
                _buildSelectionTile(
                  context,
                  icon: Icons.phone_android_outlined,
                  title: 'Alternate Number',
                  subtitle: altNumber,
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(altNumber);
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showMessageOptionDialog({
    required BuildContext context,
    required String phoneNumber,
    required VoidCallback onSMS,
    required VoidCallback onWhatsApp,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to send message?',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                phoneNumber,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              _buildSelectionTile(
                context,
                icon: Icons.sms_outlined,
                title: 'Text Message (SMS)',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  onSMS();
                },
              ),
              const SizedBox(height: 12),
              _buildSelectionTile(
                context,
                icon: Icons.chat_bubble_outline,
                title: 'WhatsApp',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  onWhatsApp();
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSelectionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color color = AppColors.primary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
