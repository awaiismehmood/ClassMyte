import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/features/classes/widgets/deletion_dialog.dart';
import 'package:classmyte/features/classes/widgets/promotion_dialog.dart';
import 'package:classmyte/features/premium/providers/subscription_providers.dart';

import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:classmyte/features/students/widgets/add_contact_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassScreen extends ConsumerWidget {
  const ClassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentDataAsync = ref.watch(studentDataProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremiumUser;
    final adManager = ref.read(adManagerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomHeader(
            title: 'Classes',
            rightActions: [
              _buildCircleAction(
                icon: Icons.add,
                onTap: () => showAddContactDialog(
                    context, () => ref.invalidate(studentDataProvider)),
              ),
            ],
          ),
          Expanded(
            child: studentDataAsync.when(
              data: (allStudents) {
                final allClasses =
                    allStudents.map((s) => s['class'] ?? '').toSet().toList();
                return Container(
                  decoration: const BoxDecoration(
                      gradient: AppColors.backgroundGradient),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildBadge(
                            'Total Classes: ${allClasses.length}', Colors.red),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: allClasses.length,
                          itemBuilder: (context, index) {
                            final className = allClasses[index];
                            final studentCount = allStudents
                                .where((s) => s['class'] == className)
                                .length;
                            return _buildClassCard(context, ref, className,
                                studentCount, allClasses, allStudents);
                          },
                        ),
                      ),
                      if (!isPremium) adManager.displayBannerAd(),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(text,
          style: GoogleFonts.outfit(
              fontSize: 14, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildClassCard(
      BuildContext context,
      WidgetRef ref,
      String className,
      int count,
      List<String> allClasses,
      List<Map<String, String>> allStudents) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text('Class $className',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primary)),
        subtitle: Text('Total students: $count',
            style: GoogleFonts.outfit(color: AppColors.textSecondary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: () => showDialog(
                context: context,
                builder: (cx) => UpdateClassDialog(
                  classes: allClasses,
                  existingClass: className,
                  allStudents: allStudents,
                  onUpdate: () => ref.invalidate(studentDataProvider),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => showDeleteClassDialog(context, className,
                  () => ref.invalidate(studentDataProvider)),
            ),
          ],
        ),
      ),
    );
  }
}
