import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/features/data_sync/data/excel_import.dart';
import 'package:classmyte/features/premium/providers/subscription_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(paymentProcessingProvider);
    final subscriptionState = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomHeader(title: 'Import Contacts'),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.file_present_outlined, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text('Formatting Rules', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text('To successfully import, your Excel file (.xlsx) must have specific column headers in the first row:', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                                const SizedBox(height: 12),
                                _buildFormatTag('Name'),
                                _buildFormatTag('Phone Number'),
                                _buildFormatTag('Class'),
                                _buildFormatTag('Guardian/Parent Details'),
                                const SizedBox(height: 16),
                                const Divider(color: Color(0xFFE0E0E0)),
                                const SizedBox(height: 16),
                                _buildInstructionStep('1', 'Tap the Import from Excel button below.'),
                                _buildInstructionStep('2', 'Select your properly formatted .xlsx file from your device.'),
                                _buildInstructionStep('3', 'Wait securely while your contacts are synced to the cloud database.'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSyncCard(
                            context,
                            icon: Icons.cloud_upload_outlined,
                            label: 'Import from Excel',
                            description: 'Upload and sync student data from an Excel file.',
                            onTap: () async {
                              if (!subscriptionState.isPremiumUser) {
                                context.push('/subscription');
                              } else {
                                ref.read(paymentProcessingProvider.notifier).state = true;
                                await ExcelImport().importFromExcel();
                                ref.read(paymentProcessingProvider.notifier).state = false;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatTag(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Text(number, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.outfit(color: AppColors.textSecondary, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildSyncCard(BuildContext context, {required IconData icon, required String label, required String description, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, size: 32, color: AppColors.primary),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(description, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
