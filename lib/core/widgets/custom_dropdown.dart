import 'package:classmyte/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? textColor;

  const CustomDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.textColor,
  });
}

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<CustomDropdownItem<T>> items;
  final void Function(T?)? onChanged;
  final String? hintText;
  final Widget? prefixIcon;
  final Color? fillColor;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.prefixIcon,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: const Color(0xFFFCFCFC),
      borderRadius: BorderRadius.circular(20),
      elevation: 8,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: fillColor ?? Colors.white,
        prefixIcon: prefixIcon,
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
      hint: hintText != null ? Text(hintText!, style: GoogleFonts.outfit(color: AppColors.textLight)) : null,
      selectedItemBuilder: (BuildContext context) {
        return items.map<Widget>((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          );
        }).toList();
      },
      items: items.map((item) {
        final isLast = items.indexOf(item) == items.length - 1;
        return DropdownMenuItem<T>(
          value: item.value,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.outfit(
                    color: item.textColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                if (item.icon != null)
                  Icon(
                    item.icon,
                    color: item.textColor ?? AppColors.textPrimary,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
