import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';

class CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? BrandColors.caramel : BrandColors.latteFoam,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? BrandColors.caramel : BrandColors.steamedMilk,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: BrandColors.caramel.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : BrandColors.mediumRoast,
          ),
        ),
      ),
    );
  }
}
