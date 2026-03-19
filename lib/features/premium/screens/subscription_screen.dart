import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/features/premium/data/payment_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classmyte/features/premium/providers/subscription_providers.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final ValueNotifier<int> _selectedTab = ValueNotifier(0); // 0: Free, 1: Pro

  @override
  void dispose() {
    _selectedTab.dispose();
    super.dispose();
  }

  Future<void> _subscribe(String plan) async {
    ref.read(paymentProcessingProvider.notifier).state = true;
    final productId = plan == 'Month' ? 'monthly_plan' : plan == 'Year' ? 'yearly_plan' : 'lifetime_plan';
    final success = await PaymentLogic.purchasePlan(productId);
    ref.read(paymentProcessingProvider.notifier).state = false;

    if (success) {
      final expiryDate = plan == 'Month'
          ? DateTime.now().add(const Duration(days: 30))
          : plan == 'Year'
              ? DateTime.now().add(const Duration(days: 365))
              : DateTime(9999); // Lifetime
      await ref.read(subscriptionProvider.notifier).updateSubscription(plan, expiryDate);
    } else {
      _showErrorDialog('Payment Failed', 'Could not process your payment. Please try again.');
    }
  }

  void _showErrorDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(msg, style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final selectedPlan = ref.watch(selectedPlanProvider);
    final isProcessing = ref.watch(paymentProcessingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 40, left: 24, right: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple gradient from screenshot
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Get Premium',
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.restore, color: Colors.white), // Restore icon from screenshot
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.workspace_premium, color: Color(0xFFFFB300), size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose a Subscription Plan',
                            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select the plan that best suits your needs.',
                            style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withOpacity(0.85)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subscription Cards
          Transform.translate(
            offset: const Offset(0, -30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildPlanCard('Month', 'PKR 1,000', 'Monthly Subscription'),
                  const SizedBox(width: 12),
                  _buildPlanCard('Year', 'PKR 10,000', 'Yearly Subscription'),
                  const SizedBox(width: 12),
                  _buildPlanCard('Lifetime', 'PKR 25,000', 'Life Time Subscription'),
                ],
              ),
            ),
          ),

          // Features Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(32)),
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedTab,
                builder: (context, val, _) => Row(
                  children: [
                    _buildTab(0, 'Free Features', const Icon(Icons.workspace_premium_outlined, size: 18, color: Color(0xFFFFB300))),
                    _buildTab(1, 'Pro Features', const Icon(Icons.workspace_premium, size: 18, color: Color(0xFFFFB300))),
                  ],
                ),
              ),
            ),
          ),

          // Features List
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _selectedTab,
              builder: (context, val, _) => ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                children: val == 0 ? _buildFreeFeatures() : _buildProFeatures(),
              ),
            ),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: CustomButton(
              text: isProcessing ? 'Processing...' : 'Continue',
              isLoading: isProcessing,
              onPressed: () => _subscribe(selectedPlan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String plan, String price, String label) {
    final curSelected = ref.watch(selectedPlanProvider);
    final isSelected = curSelected == plan;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(selectedPlanProvider.notifier).state = plan,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isSelected ? Colors.green : Colors.transparent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? Colors.green : Colors.grey.shade300, size: 24),
              ),
              const SizedBox(height: 8),
              Text(price, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, Widget icon) {
    final isSelected = _selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectedTab.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFreeFeatures() {
    return [
      _buildFeatureItem('Ads included', true),
      _buildFeatureItem('Limited WP non-contact', true),
      _buildFeatureItem('No. of campaign - 01', true),
      _buildFeatureItem('Maximum contact allowed - 10', true),
      _buildFeatureItem('Add manual contacts - 10', true),
      _buildFeatureItem('Personalize message - 10', true),
      _buildFeatureItem('Basic Unsubscribe', true),
      _buildFeatureItem('Standard WP Call Block', true),
    ];
  }

  List<Widget> _buildProFeatures() {
    return [
      _buildFeatureItem('Remove All Ads', true),
      _buildFeatureItem('Unlimited WP non-contact', true),
      _buildFeatureItem('Unlimited campaigns', true),
      _buildFeatureItem('Unlimited contacts allowed', true),
      _buildFeatureItem('No limits on manual contacts', true),
      _buildFeatureItem('Unlimited personalize messages', true),
      _buildFeatureItem('Full Unsubscribe management', true),
      _buildFeatureItem('Advanced WP Call Block', true),
      _buildFeatureItem('Export to Excel', true),
      _buildFeatureItem('Priority Support', true),
    ];
  }

  Widget _buildFeatureItem(String text, bool included) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.teal, size: 20),
          const SizedBox(width: 16),
          Text(text, style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
