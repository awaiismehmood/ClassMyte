import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/core/widgets/custom_bottom_sheet.dart';
import 'package:classmyte/core/widgets/custom_button.dart';
import 'package:classmyte/core/services/student_utils.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterSheet extends ConsumerStatefulWidget {
  final List<String> allClasses;
  final List<int> allAdmissionYears;
  final List<int> allAges;

  const FilterSheet({
    super.key,
    required this.allClasses,
    required this.allAdmissionYears,
    required this.allAges,
  });

  static void show(BuildContext context, List<Map<String, String>> allStudents) {
    final allClasses = allStudents.map((s) => s['class'] ?? '').toSet().where((c) => c.isNotEmpty).toList();
    final allAdmissionYears = allStudents.map((s) => StudentUtils.extractYear(s['Admission Date'])).toSet().where((y) => y != 0).toList()..sort((a, b) => b.compareTo(a));
    final allAges = allStudents.map((s) => StudentUtils.calculateAge(s['DOB'])).toSet().where((a) => a != 0).toList()..sort();

    CustomBottomSheet.show(
      context,
      title: 'Filter Students',
      child: FilterSheet(
        allClasses: allClasses,
        allAdmissionYears: allAdmissionYears,
        allAges: allAges,
      ),
    );
  }

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late List<String> tempSelectedClasses;
  late int tempSelectedYear;
  late int tempSelectedAge;

  @override
  void initState() {
    super.initState();
    tempSelectedClasses = List.from(ref.read(selectedClassesProvider));
    tempSelectedYear = ref.read(selectedAdmissionYearProvider);
    tempSelectedAge = ref.read(selectedAgeProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Filter by Class'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          children: widget.allClasses.map((classValue) {
            final isSelected = tempSelectedClasses.contains(classValue);
            return FilterChip(
              label: Text(classValue, style: GoogleFonts.outfit(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 13)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    tempSelectedClasses.add(classValue);
                  } else {
                    tempSelectedClasses.remove(classValue);
                  }
                });
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.primary.withOpacity(0.05),
              showCheckmark: false,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Admission Year'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text('All', style: GoogleFonts.outfit(color: tempSelectedYear == 0 ? Colors.white : AppColors.textSecondary)),
                selected: tempSelectedYear == 0,
                onSelected: (selected) => setState(() => tempSelectedYear = 0),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.05),
                showCheckmark: false,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(width: 8),
              ...widget.allAdmissionYears.map((year) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$year', style: GoogleFonts.outfit(color: tempSelectedYear == year ? Colors.white : AppColors.textSecondary)),
                  selected: tempSelectedYear == year,
                  onSelected: (selected) => setState(() => tempSelectedYear = selected ? year : 0),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.primary.withOpacity(0.05),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Age'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text('All', style: GoogleFonts.outfit(color: tempSelectedAge == 0 ? Colors.white : AppColors.textSecondary)),
                selected: tempSelectedAge == 0,
                onSelected: (selected) => setState(() => tempSelectedAge = 0),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.05),
                showCheckmark: false,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(width: 8),
              ...widget.allAges.map((age) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$age yrs', style: GoogleFonts.outfit(color: tempSelectedAge == age ? Colors.white : AppColors.textSecondary)),
                  selected: tempSelectedAge == age,
                  onSelected: (selected) => setState(() => tempSelectedAge = selected ? age : 0),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.primary.withOpacity(0.05),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    tempSelectedClasses = [];
                    tempSelectedYear = 0;
                    tempSelectedAge = 0;
                  });
                },
                child: Text('Clear Filters', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: 'Apply Filters',
                onPressed: () {
                  ref.read(selectedClassesProvider.notifier).state = tempSelectedClasses;
                  ref.read(selectedAdmissionYearProvider.notifier).state = tempSelectedYear;
                  ref.read(selectedAgeProvider.notifier).state = tempSelectedAge;
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }
}
