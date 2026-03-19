import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/features/home/home_widgets.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomHeader(
            title: 'ClassMyte',
            showBackButton: false,
            leftAction: _buildCircleAction(
              icon: Icons.person_outline,
              onTap: () {
                // Profile logic
              },
            ),
            rightActions: [
              _buildCircleAction(
                icon: Icons.settings_outlined,
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: buildHomeScreen(context),
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
}
