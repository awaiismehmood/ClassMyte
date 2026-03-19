import 'package:classmyte/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

Widget buildHomeScreen(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Hero Card (Send Message)
      _buildHeroCard(context),
      const SizedBox(height: 24),

      // Top 3 Cards (Backup, Reports, Classes)
      Row(
        children: [
          _buildQuickCard(
            context,
            'Backup in cloud',
            Icons.cloud_upload_outlined,
            Colors.purple,
            onTap: () => context.push('/data-management'),
          ),
          const SizedBox(width: 12),
          _buildQuickCard(
            context,
            'Message Report',
            Icons.description_outlined,
            Colors.orange,
            onTap: () => context.push('/classes'),
          ),
          const SizedBox(width: 12),
          _buildQuickCard(
            context,
            'Campaign Status',
            Icons.campaign_outlined,
            Colors.blue,
            onTap: () => context.push('/data-management'),
          ),
        ],
      ),
      const SizedBox(height: 32),

      // Bulk Sending Section
      _buildSectionTitle('Bulk Sending'),
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
            'WP Non-Contact',
            Icons.person_add_disabled_outlined,
            Colors.blue,
            onTap: () => context.push('/students'),
          ),
          _buildDualColumnCard(
            context,
            'Quick Message',
            Icons.bolt_outlined,
            Colors.yellow.shade800,
            onTap: () => context.push('/sms'),
          ),
          _buildDualColumnCard(
            context,
            'Group Sender',
            Icons.groups_outlined,
            Colors.pink,
            onTap: () => context.push('/classes'),
          ),
          _buildDualColumnCard(
              context,
              'Grab Unsaved',
              Icons.contact_phone_outlined,
              Colors.green,
              onTap: () => context.push('/students')),
          _buildDualColumnCard(
            context,
            'Manage Templates',
            Icons.dashboard_customize_outlined,
            Colors.teal,
            onTap: () {
              // Template placeholder
            },
          ),
          _buildDualColumnCard(
            context,
            'Personalize Msg',
            Icons.edit_note_outlined,
            Colors.purple,
            onTap: () => context.push('/sms'),
          ),
        ],
      ),
      const SizedBox(height: 32),

      // Features Section
      _buildSectionTitle('Features'),
      const SizedBox(height: 16),
      Row(
        children: [
          _buildQuickCard(
            context,
            'Chat Reports',
            Icons.insert_chart_outlined,
            Colors.blue,
            onTap: () => context.push('/data-management'),
          ),
          const SizedBox(width: 12),
          _buildQuickCard(
            context,
            'WP Call Block',
            Icons.phone_disabled_outlined,
            Colors.purple,
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(width: 12),
          _buildQuickCard(
            context,
            'Unsubscriber List',
            Icons.person_off_outlined,
            Colors.red,
            onTap: () => context.push('/students'),
          ),
        ],
      ),
    ],
  );
}

Widget _buildHeroCard(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple/Indigo gradient
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.purple.withOpacity(0.35),
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
              'Send Message',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create campaign and send bulk\nmessages to your students',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/sms'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300), // Amber button
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Icon(
            Icons.send_rounded,
            size: 100,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ],
    ),
  );
}

Widget _buildQuickCard(BuildContext context, String label, IconData icon, Color color, {required VoidCallback onTap}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDualColumnCard(BuildContext context, String title, IconData icon, Color color, {required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: GoogleFonts.outfit(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
  );
}
