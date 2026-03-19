import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/features/premium/payment_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classmyte/core/providers/providers.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  Future<void> _cancelSubscription(WidgetRef ref) async {
    await ref.read(subscriptionProvider.notifier).updateSubscription('Free', null);
  }

  void _showCancelConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('This will cancel your current subscription. Do you want to proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelSubscription(ref);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _subscribe(WidgetRef ref, BuildContext context, String plan) async {
    ref.read(paymentProcessingProvider.notifier).state = true;
    final productId = plan == 'Month' ? 'monthly_plan' : 'yearly_plan';
    final success = await PaymentLogic.purchasePlan(productId);
    ref.read(paymentProcessingProvider.notifier).state = false;

    if (success) {
      final expiryDate = plan == 'Month'
          ? DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 365));
      await ref.read(subscriptionProvider.notifier).updateSubscription(plan, expiryDate);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Failed'),
          content: const Text('Could not process your payment. Please try again.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomHeader(title: 'Premium Plans'),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
              child: subscriptionState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : subscriptionState.isPremiumUser
                      ? _buildPremiumUserView(ref, context, subscriptionState)
                      : _buildSubscriptionOptionsView(ref, context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumUserView(WidgetRef ref, BuildContext context, SubscriptionState state) {
    final formattedDate = state.expiryDate?.toLocal().toString().split(' ')[0] ?? 'No active subscription';
    final remainingDays = state.expiryDate?.difference(DateTime.now()).inDays ?? 0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.workspace_premium, size: 100, color: Colors.amber),
          const SizedBox(height: 24),
          Text('You are currently a', style: GoogleFonts.outfit(fontSize: 18, color: AppColors.textSecondary)),
          Text('${state.subscribedPackage} Member', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              children: [
                _buildInfoRow('Expiry Date', formattedDate),
                const Divider(height: 32),
                _buildInfoRow('Days Remaining', '$remainingDays Days'),
              ],
            ),
          ),
          const SizedBox(height: 48),
          CustomButton(
            text: 'Cancel Subscription',
            isSecondary: true,
            onPressed: () => _showCancelConfirmationDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textSecondary)),
        Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildSubscriptionOptionsView(WidgetRef ref, BuildContext context) {
    final selectedPlan = ref.watch(selectedPlanProvider);
    final isProcessing = ref.watch(paymentProcessingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Icon(Icons.star, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('Upgrade to Premium', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Unlock all features and remove all ads', style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          _buildSubscriptionOption(ref, 'Free', 'PKR 0', 'Ads included, Limited features and storage'),
          _buildSubscriptionOption(ref, 'Month', 'PKR 1,000', 'No ads, No limitations, All features'),
          _buildSubscriptionOption(ref, 'Year', 'PKR 10,000', 'No ads, All features, save 20%'),
          const SizedBox(height: 40),
          CustomButton(
            text: isProcessing ? 'Processing...' : 'Subscribe Now',
            isLoading: isProcessing,
            onPressed: selectedPlan == 'Free' ? null : () => _subscribe(ref, context, selectedPlan),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOption(WidgetRef ref, String planName, String price, String description) {
    final selectedPlan = ref.watch(selectedPlanProvider);
    final isSelected = selectedPlan == planName;

    return GestureDetector(
      onTap: () => ref.read(selectedPlanProvider.notifier).state = planName,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1), width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(planName, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(description, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(price, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
