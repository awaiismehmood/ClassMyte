import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/features/data_sync/download.dart';
import 'package:classmyte/features/data_sync/upload.dart';
import 'package:classmyte/features/premium/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classmyte/core/providers/providers.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadDownloadScreen extends ConsumerWidget {
  const UploadDownloadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(paymentProcessingProvider);
    final subscriptionState = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Data Management', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSyncCard(
                      context,
                      icon: Icons.cloud_download_outlined,
                      label: 'Export to Excel',
                      description: 'Download your student data as an Excel file.',
                      onTap: () async {
                        if (!subscriptionState.isPremiumUser) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                        } else {
                          ref.read(paymentProcessingProvider.notifier).state = true;
                          await ExcelExport().exportToExcel();
                          ref.read(paymentProcessingProvider.notifier).state = false;
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSyncCard(
                      context,
                      icon: Icons.cloud_upload_outlined,
                      label: 'Import from Excel',
                      description: 'Upload and sync student data from an Excel file.',
                      onTap: () async {
                        if (!subscriptionState.isPremiumUser) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
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
    );
  }

  Widget _buildSyncCard(BuildContext context,
      {required IconData icon, required String label, required String description, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: AppColors.primary.withOpacity(0.05), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
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
