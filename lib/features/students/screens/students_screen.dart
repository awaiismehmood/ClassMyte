import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/features/students/widgets/add_contact_dialog.dart';
import 'package:classmyte/features/students/widgets/filter_dialog.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/core/services/functional.dart';
import 'package:classmyte/features/sms/data/whatsapp_service.dart';
import 'package:classmyte/features/students/widgets/student_detail_sheet.dart';
import 'package:classmyte/features/premium/providers/subscription_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentContactsScreen extends ConsumerWidget {
  const StudentContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentDataAsync = ref.watch(studentDataProvider);
    final filteredStudents = ref.watch(filteredStudentsProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremiumUser;
    final adManager = ref.read(adManagerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomHeader(
            title: 'Students',
            rightActions: [
              studentDataAsync.when(
                data: (allStudents) => _buildCircleAction(
                  icon: Icons.filter_list,
                  onTap: () => FilterSheet.show(context, allStudents),
                ),
                error: (_, __) => const SizedBox(),
                loading: () => const SizedBox(),
              ),
              const SizedBox(width: 8),
              _buildCircleAction(
                icon: Icons.add,
                onTap: () => AddContactSheet.show(context, () => ref.invalidate(studentDataProvider)),
              ),
            ],
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.dynamicBackgroundGradient(isDark),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomTextField(
                      labelText: 'Search',
                      hintText: 'Search by name or phone...',
                      prefixIcon: Icons.search,
                      onChanged: (v) => ref.read(studentSearchQueryProvider.notifier).state = v,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _buildBadge(context, 'Total: ${studentDataAsync.value?.length ?? 0}', AppColors.primary),
                        const SizedBox(width: 8),
                        _buildBadge(context, 'Filtered: ${filteredStudents.length}', isDark ? AppColors.textLightDark : Colors.black54),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: studentDataAsync.when(
                      data: (_) => filteredStudents.isEmpty
                          ? Center(
                              child: Text(
                                'No students found', 
                                style: GoogleFonts.outfit(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                )
                              )
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                return _buildRedesignedStudentCard(context, ref, student);
                              },
                            ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('Error: $e')),
                    ),
                  ),
                  if (!isPremium) adManager.displayBannerAd(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction({required IconData icon, required VoidCallback onTap}) {
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

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(text, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildRedesignedStudentCard(BuildContext context, WidgetRef ref, Map<String, String> student) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => StudentDetailSheet.show(context, student),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Large Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 4),
                    ),
                    child: Center(
                      child: Text(
                        student['name']?[0].toUpperCase() ?? '?',
                        style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Student Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (student['class'] ?? 'General').toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 11, 
                            fontWeight: FontWeight.w900, 
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), 
                            letterSpacing: 1.2
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student['name'] ?? 'Unknown',
                          style: GoogleFonts.outfit(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold, 
                            color: Theme.of(context).colorScheme.onSurface
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                            const SizedBox(width: 6),
                            Text(
                              student['phoneNumber'] ?? 'No contact',
                              style: GoogleFonts.outfit(
                                fontSize: 14, 
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Footer Bar
            Container(
              height: 55,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.03),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => makeCall(student['phoneNumber']!),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone_outlined, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Call', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, height: 25, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  Expanded(
                    child: InkWell(
                      onTap: () => WhatsAppMessaging().sendWhatsAppMessageIndividually(student['phoneNumber']!),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.green),
                          const SizedBox(width: 8),
                          Text('Message', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
