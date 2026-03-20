import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/features/premium/data/payment_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classmyte/features/premium/providers/subscription_providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:classmyte/core/widgets/custom_dialog.dart';
import 'package:classmyte/core/widgets/custom_snackbar.dart';

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
    CustomDialog.show(
      context: context,
      title: title,
      subtitle: msg,
      confirmText: 'OK',
      onConfirm: () => Navigator.pop(context),
    );
  }

  Future<void> _cancelSubscription() async {
    final passwordController = TextEditingController();
    
    CustomDialog.show(
      context: context,
      title: 'Cancel Subscription',
      subtitle: 'Please enter your password to confirm cancellation:',
      confirmText: 'Cancel Plan',
      confirmColor: AppColors.error,
      controller: passwordController,
      inputLabel: 'Password',
      inputHint: 'Enter password',
      isPassword: true,
      onConfirm: () async {
        if (passwordController.text.trim().isEmpty) {
          CustomSnackBar.showError(context, 'Please enter your password');
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email != null) {
          try {
            AuthCredential credential = EmailAuthProvider.credential(
              email: user.email!, 
              password: passwordController.text.trim()
            );
            await user.reauthenticateWithCredential(credential);
            await ref.read(subscriptionProvider.notifier).updateSubscription('Free', null);
            
            if (mounted) {
              Navigator.pop(context); // Close dialog
              CustomSnackBar.showSuccess(context, 'Subscription cancelled successfully');
            }
          } catch (e) {
            if (mounted) {
              CustomSnackBar.showError(context, 'Verification Failed: Incorrect password.');
            }
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final selectedPlan = ref.watch(selectedPlanProvider);
    final isProcessing = ref.watch(paymentProcessingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (subscriptionState.isPremiumUser) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
                  ],
                ),
                child: const Icon(Icons.workspace_premium, size: 100, color: AppColors.accent),
              ),
              const SizedBox(height: 48),
              Text(
                'You are already\nsubscribed',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enjoy our all premium features.',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 64),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home, color: AppColors.primary),
                  label: Text('Go to Home', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _cancelSubscription,
                child: Text('Cancel Subscription', style: GoogleFonts.outfit(color: Colors.white70, decoration: TextDecoration.underline, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 40, left: 24, right: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], 
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
                      icon: const Icon(Icons.restore, color: Colors.white),
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
                  _buildPlanCard('Month', 'PKR 299', 'Monthly Subscription'),
                  const SizedBox(width: 12),
                  _buildPlanCard('Year', 'PKR 2,999', 'Yearly (2 Months Free)'),
                  const SizedBox(width: 12),
                  _buildPlanCard('Lifetime', 'PKR 7,999', 'One-time Payment'),
                ],
              ),
            ),
          ),

          // Features Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF3E5F5), 
                borderRadius: BorderRadius.circular(32)
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedTab,
                builder: (context, val, _) => Row(
                  children: [
                    _buildTab(context, 0, 'Free Features', const Icon(Icons.workspace_premium_outlined, size: 18, color: Color(0xFFFFB300))),
                    _buildTab(context, 1, 'Pro Features', const Icon(Icons.workspace_premium, size: 18, color: Color(0xFFFFB300))),
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
                children: val == 0 ? _buildFreeFeatures(context) : _buildProFeatures(context),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(selectedPlanProvider.notifier).state = plan,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isSelected ? Colors.green : Colors.transparent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? Colors.green : (isDark ? Colors.white24 : Colors.grey.shade300), size: 24),
              ),
              const SizedBox(height: 8),
              Text(price, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String label, Widget icon) {
    final isSelected = _selectedTab.value == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectedTab.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? Colors.white10 : Colors.white) : Colors.transparent,
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
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold, 
                  fontSize: 13, 
                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFreeFeatures(BuildContext context) {
    return [
      _buildFeatureItem(context, 'Bulk Messaging (30s Fixed Delay)', true),
      _buildFeatureItem(context, 'Save up to 50 Contacts', true),
      _buildFeatureItem(context, 'Standard Personalization (Prefix/Suffix)', true),
      _buildFeatureItem(context, 'Manual Contact Entry', true),
      _buildFeatureItem(context, 'View Pre-made Templates', true),
      _buildFeatureItem(context, 'Ad-Supported Experience', true),
    ];
  }

  List<Widget> _buildProFeatures(BuildContext context) {
    return [
      _buildFeatureItem(context, 'Remove All Ads (Instant Processing)', true),
      _buildFeatureItem(context, 'Unlimited Contact Storage', true),
      _buildFeatureItem(context, 'Custom Message Delays (0-60s)', true),
      _buildFeatureItem(context, 'Exclude Inactive Student Filter', true),
      _buildFeatureItem(context, 'Create & Manage Custom Templates', true),
      _buildFeatureItem(context, 'Excel/CSV Data Import & Export', true),
      _buildFeatureItem(context, 'Advanced Data Synchronization', true),
      _buildFeatureItem(context, 'Priority Updates & Support', true),
    ];
  }

  Widget _buildFeatureItem(BuildContext context, String text, bool included) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.teal, size: 20),
          const SizedBox(width: 16),
          Text(text, style: GoogleFonts.outfit(fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
