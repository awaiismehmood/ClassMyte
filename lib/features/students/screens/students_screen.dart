import 'package:classmyte/core/data/edit_contacts.dart';
import 'package:classmyte/core/widgets/custom_dialog.dart';
import 'package:classmyte/core/services/student_utils.dart';
import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/features/students/widgets/add_contact_dialog.dart';
import 'package:classmyte/features/students/widgets/filter_dialog.dart';
import 'package:classmyte/core/widgets/custom_text_field.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/core/services/functional.dart';
import 'package:classmyte/features/sms/data/whatsapp_service.dart';
import 'package:classmyte/core/widgets/communication_dialogs.dart';
import 'package:classmyte/features/students/widgets/student_detail_sheet.dart';
import 'package:classmyte/features/premium/providers/subscription_providers.dart';
import 'package:classmyte/features/sms/providers/sms_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentContactsScreen extends ConsumerWidget {
  const StudentContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentDataAsync = ref.watch(studentDataProvider);
    final filteredStudents = ref.watch(filteredStudentsProvider);
    final selectedIds = ref.watch(selectedStudentIdsProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremiumUser;
    final adManager = ref.read(adManagerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isSelectionMode = selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomHeader(
            title: isSelectionMode ? '${selectedIds.length} Selected' : 'Students',
            leftAction: isSelectionMode 
              ? _buildCircleAction(
                  icon: Icons.close,
                  color: Theme.of(context).colorScheme.onSurface,
                  onTap: () => ref.read(selectedStudentIdsProvider.notifier).state = {},
                )
              : null,
            rightActions: isSelectionMode
              ? [
                  GestureDetector(
                    onTap: () {
                      if (selectedIds.length == filteredStudents.length) {
                        ref.read(selectedStudentIdsProvider.notifier).state = {};
                      } else {
                        ref.read(selectedStudentIdsProvider.notifier).state =
                            filteredStudents.map((s) => s['id']!).toSet();
                      }
                    },
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        selectedIds.length == filteredStudents.length
                            ? 'Unselect All'
                            : 'Select All',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                    ),
                    child: PopupMenuButton<String>(
                      tooltip: 'More options',
                      offset: const Offset(0, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Theme.of(context).cardColor,
                      onSelected: (value) {
                        if (value == 'Active') {
                          _handleBulkStatusUpdate(context, ref, selectedIds.toList(), 'Active');
                        } else if (value == 'Inactive') {
                          _handleBulkStatusUpdate(context, ref, selectedIds.toList(), 'Inactive');
                        } else if (value == 'Delete') {
                          _handleBulkDelete(context, ref, selectedIds.toList());
                        } else if (value == 'Message') {
                          _handleSendMessageToSelected(context, ref, filteredStudents, selectedIds, isPremium);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'Active',
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                              const SizedBox(width: 12),
                              Text('Mark Active', style: GoogleFonts.outfit(fontSize: 15)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Inactive',
                          child: Row(
                            children: [
                              const Icon(Icons.remove_circle_outline, color: Colors.orange, size: 20),
                              const SizedBox(width: 12),
                              Text('Mark Inactive', style: GoogleFonts.outfit(fontSize: 15)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 12),
                              Text('Delete Selected', style: GoogleFonts.outfit(fontSize: 15, color: Colors.redAccent)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'Message',
                          child: Row(
                            children: [
                              Icon(Icons.send_outlined,
                                color: isPremium ? AppColors.primary : Colors.grey,
                                size: 20),
                              const SizedBox(width: 12),
                              Text('Send Message',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  color: isPremium ? AppColors.primary : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                )),
                              const Spacer(),
                              if (!isPremium)
                                const Icon(Icons.lock_outline, size: 14, color: Colors.amber),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.more_vert, color: AppColors.primary, size: 24),
                      ),
                    ),
                  ),
                ]
              : [
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
                                final isSelected = selectedIds.contains(student['id']);
                                return _buildRedesignedStudentCard(context, ref, student, isSelected);
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

  void _handleBulkDelete(BuildContext context, WidgetRef ref, List<String> ids) {
    CustomDialog.show(
      context: context,
      title: 'Delete Selected?',
      subtitle: 'Are you sure you want to delete ${ids.length} students? This cannot be undone.',
      confirmText: 'Delete',
      confirmColor: Colors.redAccent,
      onConfirm: () async {
        Navigator.pop(context); // Close dialog
        await EditContactService.deleteMultipleContacts(ids);
        ref.read(selectedStudentIdsProvider.notifier).state = {};
        ref.invalidate(studentDataProvider);
      },
    );
  }

  void _handleBulkStatusUpdate(BuildContext context, WidgetRef ref, List<String> ids, String status) async {
    await EditContactService.updateMultipleStatus(ids, status);
    ref.read(selectedStudentIdsProvider.notifier).state = {};
    ref.invalidate(studentDataProvider);
  }

  void _handleSendMessageToSelected(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, String>> allStudents,
    Set<String> selectedIds,
    bool isPremium,
  ) {
    if (!isPremium) {
      CustomDialog.show(
        context: context,
        title: 'Premium Feature',
        subtitle: 'Sending messages to custom-selected students is a premium feature.\n\nUpgrade to unlock this and many more powerful features!',
        confirmText: 'Go Premium',
        cancelText: 'Cancel',
        confirmColor: AppColors.primary,
        onConfirm: () {
          Navigator.pop(context);
          context.push('/subscription');
        },
      );
      return;
    }

    // Get the actual student maps for the selected IDs
    final selectedContacts = allStudents
        .where((s) => selectedIds.contains(s['id']))
        .toList();

    if (selectedContacts.isEmpty) return;

    // Set the pre-selected contacts and navigate
    ref.read(preSelectedContactsProvider.notifier).state = selectedContacts;
    ref.read(selectedStudentIdsProvider.notifier).state = {};
    context.push('/sms');
  }

  Widget _buildCircleAction({required IconData icon, required VoidCallback onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: color ?? AppColors.primary, size: 24),
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

  Widget _buildRedesignedStudentCard(BuildContext context, WidgetRef ref, Map<String, String> student, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedIds = ref.read(selectedStudentIdsProvider);
    final isSelectionMode = selectedIds.isNotEmpty;

    return GestureDetector(
      onLongPress: () {
        final current = ref.read(selectedStudentIdsProvider);
        if (current.contains(student['id'])) {
          ref.read(selectedStudentIdsProvider.notifier).state = {...current}..remove(student['id']);
        } else {
          ref.read(selectedStudentIdsProvider.notifier).state = {...current, student['id']!};
        }
      },
      onTap: () {
        if (isSelectionMode) {
          final current = ref.read(selectedStudentIdsProvider);
          if (current.contains(student['id'])) {
            ref.read(selectedStudentIdsProvider.notifier).state = {...current}..remove(student['id']);
          } else {
            ref.read(selectedStudentIdsProvider.notifier).state = {...current, student['id']!};
          }
        } else {
          StudentDetailSheet.show(context, student);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(isDark ? 0.15 : 0.05)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
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
            Stack(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (student['status'] == 'Active' ? Colors.green : Colors.redAccent).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    student['status'] ?? 'Active',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: student['status'] == 'Active' ? Colors.green : Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    student['name'] ?? 'Unknown',
                                    style: GoogleFonts.outfit(
                                      fontSize: 22, 
                                      fontWeight: FontWeight.bold, 
                                      color: Theme.of(context).colorScheme.onSurface
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (StudentUtils.isBirthdayToday(student['DOB'])) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.pink.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.cake, color: Colors.pink, size: 16),
                                  ),
                                ],
                              ],
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
                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
            // Footer Bar
            Container(
              height: 55,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.03),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: isSelectionMode ? null : () {
                        final primary = student['phoneNumber'] ?? '';
                        final alt = student['altNumber'] ?? '';
                        if (alt.isNotEmpty && alt != '0') {
                          CommunicationDialogs.showNumberSelectionDialog(
                            context: context,
                            title: 'Select Number to Call',
                            primaryNumber: primary,
                            altNumber: alt,
                            onSelected: (num) => makeCall(num),
                          );
                        } else {
                          makeCall(primary);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_outlined, size: 18, color: isSelectionMode ? Colors.grey : AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Call', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isSelectionMode ? Colors.grey : AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, height: 25, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  Expanded(
                    child: InkWell(
                      onTap: isSelectionMode ? null : () {
                        final primary = student['phoneNumber'] ?? '';
                        final alt = student['altNumber'] ?? '';
                        
                        void showOptions(String num) {
                          CommunicationDialogs.showMessageOptionDialog(
                            context: context,
                            phoneNumber: num,
                            onSMS: () => sendSMS(num),
                            onWhatsApp: () => WhatsAppMessaging().sendWhatsAppMessageIndividually(num),
                          );
                        }

                        if (alt.isNotEmpty && alt != '0') {
                          CommunicationDialogs.showNumberSelectionDialog(
                            context: context,
                            title: 'Select Number to Message',
                            primaryNumber: primary,
                            altNumber: alt,
                            onSelected: (num) => showOptions(num),
                          );
                        } else {
                          showOptions(primary);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 18, color: isSelectionMode ? Colors.grey : Colors.green),
                          const SizedBox(width: 8),
                          Text('Message', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isSelectionMode ? Colors.grey : Colors.green)),
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
