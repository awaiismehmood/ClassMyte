import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/features/sms/data/sms_service.dart';
import 'package:classmyte/features/sms/providers/sms_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class MessageReportScreen extends ConsumerWidget {
  const MessageReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(smsProgressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            CustomHeader(
              title: 'Message Report', 
              showBackButton: false,
              leftAction: InkWell(
                onTap: () => context.go('/home'),
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.chevron_left, color: AppColors.primary, size: 24),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.dynamicBackgroundGradient(isDark),
                ),
                child: progress.status == 'idle' 
                  ? _buildEmptyState(context)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildStatusCard(context, progress, isDark),
                          const SizedBox(height: 24),
                          _buildStatsGrid(context, progress),
                          const SizedBox(height: 24),
                          if (progress.status == 'sending') _buildCurrentAction(context, progress),
                          if (progress.status == 'completed' && progress.failedList.isNotEmpty) 
                            _buildFailureList(context, progress),
                          const SizedBox(height: 32),
                          _buildActionButtons(context, ref, progress),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.campaign_outlined,
                size: 80,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Messages Sending',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no messages currently being sent.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: onSurface.withOpacity(0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Send New Message',
                onPressed: () {
                  context.push('/sms');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, SmsProgressState progress, bool isDark) {
    double percent = progress.total > 0 ? (progress.currentIndex / progress.total) : 0;
    String statusText = _getStatusText(progress);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(statusText, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: _getStatusColor(progress))),
              Text('${(percent * 100).toInt()}%', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 12,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${progress.currentIndex} of ${progress.total} recipients processed',
            style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, SmsProgressState progress) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatItem(context, 'Sent', '${progress.sent}', Colors.green),
        _buildStatItem(context, 'Failed', '${progress.failed}', Colors.redAccent),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: GoogleFonts.outfit(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildCurrentAction(BuildContext context, SmsProgressState progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Currently sending to:', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.primary)),
                Text(
                  '${progress.currentName} (${progress.currentNumber})',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureList(BuildContext context, SmsProgressState progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Failed Contacts', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...progress.failedList.map((f) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f['name'] ?? 'Unknown', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    Text(f['number'] ?? '', style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              Text(f['error'] ?? 'Failed', style: GoogleFonts.outfit(fontSize: 10, color: Colors.redAccent)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, SmsProgressState progress) {
    if (progress.status == 'sending') {
      return CustomButton(
        text: 'Stop Processing',
        color: Colors.redAccent,
        onPressed: () => MessageSender.cancelMessageSending(),
      );
    }
    
    if (progress.status == 'completed' || progress.status == 'cancelled') {
      return Column(
        children: [
          if (progress.failedList.isNotEmpty) ...[
            CustomButton(
              text: 'Retry Failed (${progress.failedList.length})',
              color: Colors.orange,
              onPressed: () {
                final failedPhones = progress.failedList.map((f) => f['number']!).toList();
                final failedNames = progress.failedList.map((f) => f['name']!).toList();
                final lastMsg = progress.lastMessage;
                
                if (lastMsg.isNotEmpty) {
                  // Reset state before retry
                  ref.read(smsProgressProvider.notifier).reset();
                  ref.read(smsProgressProvider.notifier).setLastMessage(lastMsg);
                  
                  MessageSender.sendMessages(
                    phoneNumbers: failedPhones,
                    names: failedNames,
                    messages: List.generate(failedPhones.length, (_) => lastMsg),
                    delay: 15, // Default delay for retry
                  );
                }
              },
            ),
            const SizedBox(height: 12),
          ],
          CustomButton(
            text: 'Finish & Exit',
            onPressed: () {
              ref.read(smsProgressProvider.notifier).reset();
              context.pushReplacement('/home');
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  String _getStatusText(SmsProgressState progress) {
    switch (progress.status) {
      case 'sending': return 'Processing...';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return 'Idle';
    }
  }

  Color _getStatusColor(SmsProgressState progress) {
    switch (progress.status) {
      case 'sending': return AppColors.primary;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
