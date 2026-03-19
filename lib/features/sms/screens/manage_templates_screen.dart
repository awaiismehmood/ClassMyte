import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_header.dart';
import 'package:classmyte/features/sms/providers/template_providers.dart';
import 'package:classmyte/features/sms/widgets/add_template_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final isMyTemplatesProvider = StateProvider<bool>((ref) => false);

class ManageTemplatesScreen extends ConsumerWidget {
  const ManageTemplatesScreen({super.key});

  final List<TemplateModel> _preMadeTemplates = const [
    TemplateModel(id: '1', title: 'Happy Anniversary!', text: 'Happy Anniversary! 🎉 Thanks for being with us for [number] years!', category: 'Anniversary'),
    TemplateModel(id: '2', title: 'Cheers to 20 years!', text: 'Cheers to 20 years! 🎉 We appreciate your support!', category: 'Anniversary'),
    TemplateModel(id: '3', title: 'Happy 15th Anniversary!', text: 'Happy 15th Anniversary! 🎉 Grateful for your loyalty!', category: 'Anniversary'),
    TemplateModel(id: '4', title: 'For better, for worse', text: 'For better, for worse, for the long haul—congrats, you two a Happy Anniversary.', category: 'Anniversary'),
    TemplateModel(id: '5', title: 'Happy Birthday!', text: 'Wishing you a very Happy Birthday! 🎂 May all your dreams come true!', category: 'Birthday'),
    TemplateModel(id: '6', title: 'Big Sale Event!', text: 'Huge discounts up to 50% off on all items! 🛍️ Don\'t miss out!', category: 'Sales'),
    TemplateModel(id: '7', title: 'Happy Festival!', text: 'May your celebrations be filled with happiness and health.', category: 'Festivals'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMyTemplates = ref.watch(isMyTemplatesProvider);
    final userTemplates = ref.watch(userTemplatesProvider);
    final selectedCategory = ref.watch(templateCategoryProvider);

    final currentTemplates = isMyTemplates
        ? userTemplates.where((t) => t.category == selectedCategory).toList()
        : _preMadeTemplates.where((t) => t.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomHeader(title: 'Manage Templates'),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroSection(context, ref, isMyTemplates),
                        const SizedBox(height: 24),
                        _buildCategoryChips(ref, selectedCategory),
                        const SizedBox(height: 16),
                        ...currentTemplates.map((t) => _buildTemplateCard(context, ref, t, isMyTemplates)),
                        const SizedBox(height: 100), // padding for FAB
                      ],
                    ),
                  ),
                ),
                if (isMyTemplates)
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6), // Purple button color matches screenshot
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 6,
                        shadowColor: Colors.purple.withOpacity(0.4),
                      ),
                      onPressed: () => AddTemplateSheet.show(context),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text('New Template', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, WidgetRef ref, bool isMyTemplates) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.receipt_long, color: Color(0xFF8B5CF6), size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Templates', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Create Template\nand send messages', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.2)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isMyTemplates ? Colors.white : const Color(0xFFF59E0B), // Amber color
              foregroundColor: isMyTemplates ? const Color(0xFF8B5CF6) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
            onPressed: () => ref.read(isMyTemplatesProvider.notifier).state = !isMyTemplates,
            child: Text(
              isMyTemplates ? 'Pre-Made' : 'My Template',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(WidgetRef ref, String selectedCategory) {
    final categories = ['Anniversary', 'Birthday', 'Sales', 'Festivals'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => ref.read(templateCategoryProvider.notifier).state = cat,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, WidgetRef ref, TemplateModel template, bool isMyTemplates) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMyTemplates)
                  Text(template.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                if (isMyTemplates) const SizedBox(height: 8),
                Text(template.text, style: GoogleFonts.outfit(color: isMyTemplates ? AppColors.textSecondary : AppColors.textPrimary, fontWeight: isMyTemplates ? null : FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.image_outlined, size: 16, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 6),
                    Text('Includes media', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isMyTemplates)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                  onSelected: (v) {
                    if (v == 'delete') {
                      ref.read(userTemplatesProvider.notifier).removeTemplate(template.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'delete', child: Text('Delete Template', style: GoogleFonts.outfit(color: Colors.redAccent))),
                  ],
                )
               else
                 const SizedBox(height: 24),
              const SizedBox(height: 16),
              const Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary, size: 20),
            ],
          )
        ],
      ),
    );
  }
}
