import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/core/data/edit_contacts.dart';
import 'package:classmyte/core/widgets/custom_dialog.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/features/classes/widgets/edit_class_sheet.dart';
import 'package:classmyte/features/classes/providers/class_providers.dart';
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
    final filteredClasses = ref.watch(filteredClassesProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremiumUser;
    final adManager = ref.read(adManagerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomHeader(
            title: 'Categories',
            rightActions: [
              _buildCircleAction(
                icon: Icons.add,
                onTap: () => AddContactSheet.show(
                    context, () => ref.invalidate(studentDataProvider)),
              ),
            ],
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  gradient: AppColors.backgroundGradient),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomTextField(
                      labelText: 'Search Category',
                      hintText: 'Search by category name...',
                      prefixIcon: Icons.search,
                      onChanged: (v) => ref.read(classSearchQueryProvider.notifier).state = v,
                    ),
                  ),
                  studentDataAsync.when(
                    data: (allStudents) {
                      return Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  _buildBadge(
                                      'Total Categories: ${allStudents.map((s) => s['class'] ?? '').toSet().where((c) => c.isNotEmpty).length}', AppColors.primary),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: filteredClasses.isEmpty
                                  ? Center(child: Text('No categories found', style: GoogleFonts.outfit(color: AppColors.textSecondary)))
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      itemCount: filteredClasses.length,
                                      itemBuilder: (context, index) {
                                        final className = filteredClasses[index];
                                        final studentCount = allStudents
                                            .where((s) => s['class'] == className)
                                            .length;
                                        return _buildClassCard(context, ref, className,
                                            studentCount, filteredClasses, allStudents);
                                      },
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
                    error: (e, s) => Expanded(child: Center(child: Text('Error: $e'))),
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
    return GestureDetector(
      onTap: () => EditClassSheet.show(
        context,
        classes: allClasses,
        existingClass: className,
        allStudents: allStudents,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.folder_outlined, color: AppColors.primary, size: 28),
          ),
          title: Text(className,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('$count Students',
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 24),
                onPressed: () => EditClassSheet.show(
                  context,
                  classes: allClasses,
                  existingClass: className,
                  allStudents: allStudents,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
                onPressed: () {
                  final confirmController = TextEditingController();
                  CustomDialog.show(
                    context: context,
                    title: 'Delete Category',
                    subtitle: "Type '$className' below to confirm. All students in this category will be removed.",
                    confirmText: 'Delete Now',
                    confirmColor: Colors.redAccent,
                    controller: confirmController,
                    inputLabel: 'Category Name',
                    inputHint: 'Enter name precisely',
                    onConfirm: () async {
                      if (confirmController.text.trim() != className) {
                        Navigator.pop(context);
                        CustomSnackBar.showError(context, 'Failed to delete: Name does not match');
                        return;
                      }

                      try {
                        await EditContactService.deleteClassAndStudents(className);
                        ref.invalidate(studentDataProvider);
                        if (context.mounted) {
                          Navigator.pop(context);
                          CustomSnackBar.showSuccess(context, 'Category deleted successfully');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          CustomSnackBar.showError(context, 'Error deleting category');
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
