import 'package:classmyte/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:classmyte/features/sms/providers/sms_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classmyte/core/widgets/custom_snackbar.dart';

Widget buildHomeScreen(BuildContext context) {
  return Consumer(
    builder: (context, ref, child) {
      final progress = ref.watch(smsProgressProvider);
      final isProcessing = progress.status == 'sending';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Card (Send Message)
          _buildHeroCard(context, isProcessing),
          const SizedBox(height: 24),

          // Top 3 Cards (Export, Import, Message Report)
          Row(
            children: [
              _buildQuickCard(
                context,
                'Export Contacts',
                Icons.cloud_upload_outlined,
                Colors.purple,
                onTap: () => context.push('/export'),
              ),
              const SizedBox(width: 12),
              _buildQuickCard(
                context,
                'Import Contacts',
                Icons.file_download_outlined,
                Colors.orange,
                onTap: () => context.push('/import'),
              ),
              const SizedBox(width: 12),
              _buildQuickCard(
                context,
                isProcessing ? 'View Progress' : 'Message Report',
                isProcessing ? Icons.sync : Icons.analytics_outlined,
                isProcessing ? AppColors.primary : Colors.blue,
                onTap: () => context.push('/message-report'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Bulk Sending Section
          _buildSectionTitle(context, 'Bulk Sending'),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              _buildDualColumnCard(
                context,
                'My contacts',
                Icons.person_add_outlined,
                Colors.blue,
                onTap: () => context.push('/students'),
              ),
              _buildDualColumnCard(
                context,
                isProcessing ? 'Sending...' : 'Quick Message',
                isProcessing ? Icons.sync : Icons.bolt_outlined,
                isProcessing ? AppColors.primary : Colors.yellow.shade800,
                onTap: () => context.push(isProcessing ? '/message-report' : '/sms'),
              ),
              _buildDualColumnCard(
                context,
                'Categories',
                Icons.groups_outlined,
                Colors.pink,
                onTap: () => context.push('/classes'),
              ),
              _buildDualColumnCard(
                context,
                'Manage Templates',
                Icons.dashboard_customize_outlined,
                Colors.teal,
                onTap: () => context.push('/manage-templates'),
              ),
              _buildDualColumnCard(
                context,
                'Personalize Msg',
                Icons.edit_note_outlined,
                Colors.purple,
                onTap: () => context.push('/personalize-message'),
              ),
              _buildDualColumnCard(
                context,
                'History',
                Icons.history_outlined,
                Colors.green,
                onTap: () => CustomSnackBar.showInfo(
                    context, 'Something cool is cooking! 🥘 Messaging history is coming soon.'),
              ),
            ],
          ),
        ],
      );
    },
  );
}

Widget _buildHeroCard(BuildContext context, bool isProcessing) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.35),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isProcessing ? 'Message Sending' : 'Send Message',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isProcessing 
                ? 'Your campaign is currently running\nin the background.'
                : 'Create campaign and send bulk\nmessages to your students',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push(isProcessing ? '/message-report' : '/sms'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isProcessing ? Colors.white : AppColors.accent,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                isProcessing ? 'View Progress' : 'Get Started',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Icon(
            isProcessing ? Icons.sync : Icons.send_rounded,
            size: 100,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ],
    ),
  );
}

Widget _buildQuickCard(
    BuildContext context, String label, IconData icon, Color color,
    {required VoidCallback onTap}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDualColumnCard(
    BuildContext context, String title, IconData icon, Color color,
    {required VoidCallback onTap}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionTitle(BuildContext context, String title) {
  return Text(
    title,
    style: GoogleFonts.outfit(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );
}
