import 'package:classmyte/core/theme/app_colors.dart';
import 'package:classmyte/features/students/models/student_model.dart';
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

  static void show(
      BuildContext context, List<Student> allStudents) {
    final allClasses = allStudents
        .map((s) => s.className)
        .toSet()
        .where((c) => c.isNotEmpty)
        .toList();
    final allAdmissionYears = allStudents
        .map((s) => StudentUtils.extractYear(s.admissionDate))
        .toSet()
        .where((y) => y != 0)
        .toList()
      ..sort((a, b) => b.compareTo(a));
    final allAges = allStudents
        .map((s) => StudentUtils.calculateAge(s.dob))
        .toSet()
        .where((a) => a != 0)
        .toList()
      ..sort();

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
  late bool tempShowBirthdaysOnly;
  late String tempSelectedStatus;

  @override
  void initState() {
    super.initState();
    tempSelectedClasses = List.from(ref.read(selectedClassesProvider));
    tempSelectedYear = ref.read(selectedAdmissionYearProvider);
    tempSelectedAge = ref.read(selectedAgeProvider);
    tempShowBirthdaysOnly = ref.read(showBirthdaysOnlyProvider);
    tempSelectedStatus = ref.read(selectedStatusFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final chipBg = onSurface.withOpacity(0.05);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Filter by Class'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          children: widget.allClasses.map((classValue) {
            final isSelected = tempSelectedClasses.contains(classValue);
            return FilterChip(
              label: Text(classValue,
                  style: GoogleFonts.outfit(
                      color: isSelected
                          ? Colors.white
                          : onSurface.withOpacity(0.7),
                      fontSize: 13)),
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
              backgroundColor: chipBg,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : onSurface.withOpacity(0.05))),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'Admission Year'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text('All',
                    style: GoogleFonts.outfit(
                        color: tempSelectedYear == 0
                            ? Colors.white
                            : onSurface.withOpacity(0.7))),
                selected: tempSelectedYear == 0,
                onSelected: (selected) => setState(() => tempSelectedYear = 0),
                selectedColor: AppColors.primary,
                backgroundColor: chipBg,
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: tempSelectedYear == 0
                            ? Colors.transparent
                            : onSurface.withOpacity(0.05))),
              ),
              const SizedBox(width: 8),
              ...widget.allAdmissionYears.map((year) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$year',
                          style: GoogleFonts.outfit(
                              color: tempSelectedYear == year
                                  ? Colors.white
                                  : onSurface.withOpacity(0.7))),
                      selected: tempSelectedYear == year,
                      onSelected: (selected) => setState(
                          () => tempSelectedYear = selected ? year : 0),
                      selectedColor: AppColors.primary,
                      backgroundColor: chipBg,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: tempSelectedYear == year
                                  ? Colors.transparent
                                  : onSurface.withOpacity(0.05))),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'Age'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text('All',
                    style: GoogleFonts.outfit(
                        color: tempSelectedAge == 0
                            ? Colors.white
                            : onSurface.withOpacity(0.7))),
                selected: tempSelectedAge == 0,
                onSelected: (selected) => setState(() => tempSelectedAge = 0),
                selectedColor: AppColors.primary,
                backgroundColor: chipBg,
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: tempSelectedAge == 0
                            ? Colors.transparent
                            : onSurface.withOpacity(0.05))),
              ),
              const SizedBox(width: 8),
              ...widget.allAges.map((age) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$age yrs',
                          style: GoogleFonts.outfit(
                              color: tempSelectedAge == age
                                  ? Colors.white
                                  : onSurface.withOpacity(0.7))),
                      selected: tempSelectedAge == age,
                      onSelected: (selected) =>
                          setState(() => tempSelectedAge = selected ? age : 0),
                      selectedColor: AppColors.primary,
                      backgroundColor: chipBg,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: tempSelectedAge == age
                                  ? Colors.transparent
                                  : onSurface.withOpacity(0.05))),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'Status'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Active', 'Inactive'].map((status) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(status, style: GoogleFonts.outfit(color: tempSelectedStatus == status ? Colors.white : onSurface.withOpacity(0.7))),
                selected: tempSelectedStatus == status,
                onSelected: (selected) => setState(() => tempSelectedStatus = status),
                selectedColor: AppColors.primary,
                backgroundColor: chipBg,
                showCheckmark: false,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: tempSelectedStatus == status ? Colors.transparent : onSurface.withOpacity(0.05))),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'Special'),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Show Birthdays Today',
              style: GoogleFonts.outfit(fontSize: 14, color: onSurface)),
          secondary: Icon(Icons.cake_outlined,
              color: tempShowBirthdaysOnly
                  ? Colors.pink
                  : onSurface.withOpacity(0.4)),
          value: tempShowBirthdaysOnly,
          activeThumbColor: Colors.pink,
          onChanged: (val) => setState(() => tempShowBirthdaysOnly = val),
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    tempSelectedClasses = [];
                    tempSelectedYear = 0;
                    tempSelectedAge = 0;
                    tempShowBirthdaysOnly = false;
                    tempSelectedStatus = 'All';
                  });
                },
                child: Text('Clear Filters',
                    style: GoogleFonts.outfit(
                        color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: 'Apply Filters',
                onPressed: () {
                  ref.read(selectedClassesProvider.notifier).state =
                      tempSelectedClasses;
                  ref.read(selectedAdmissionYearProvider.notifier).state =
                      tempSelectedYear;
                  ref.read(selectedAgeProvider.notifier).state =
                      tempSelectedAge;
                  ref.read(showBirthdaysOnlyProvider.notifier).state =
                      tempShowBirthdaysOnly;
                  ref.read(selectedStatusFilterProvider.notifier).state = tempSelectedStatus;
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(title,
        style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface));
  }
}
