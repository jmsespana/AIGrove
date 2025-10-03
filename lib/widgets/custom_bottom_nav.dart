// ignore_for_file: deprecated_member_use

import 'dart:ui'; // I-import para sa ImageFilter
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isDark;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Gamiton ang theme colors para sa glassmorphism effect
    final barBackgroundColor = AppTheme.getBottomNavBackgroundColor(isDark);
    final selectedColor = AppTheme.getBottomNavSelectedColor(isDark);
    final unselectedColor = AppTheme.getBottomNavUnselectedColor(isDark);

    return Container(
      // Gamiton ang margin gikan sa AppTheme
      margin: AppTheme.bottomNavMargin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.bottomNavBorderRadius),
        boxShadow: AppTheme.getBottomNavShadow(isDark: isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.bottomNavBorderRadius),
        child: BackdropFilter(
          // I-apply ang blur effect para sa glass look
          filter: ImageFilter.blur(
            sigmaX: AppTheme.bottomNavBlurAmount,
            sigmaY: AppTheme.bottomNavBlurAmount,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: barBackgroundColor, // Semi-transparent na color
              borderRadius: BorderRadius.circular(
                AppTheme.bottomNavBorderRadius,
              ),
              border: AppTheme.getBottomNavBorder(
                isDark: isDark,
              ), // Subtle border para sa glass effect
            ),
            child: Padding(
              // Gamiton ang padding gikan sa AppTheme
              padding: AppTheme.bottomNavPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: FontAwesomeIcons.house,
                    activeIcon: FontAwesomeIcons.houseChimney,
                    label: "Home",
                    index: 0,
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                  _buildNavItem(
                    icon: FontAwesomeIcons.camera,
                    activeIcon: FontAwesomeIcons.cameraRetro,
                    label: "Scan",
                    index: 1,
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                  _buildNavItem(
                    icon: FontAwesomeIcons.locationDot,
                    activeIcon: FontAwesomeIcons.mapLocationDot,
                    label: "Map",
                    index: 2,
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                  _buildNavItem(
                    icon: FontAwesomeIcons.trophy,
                    activeIcon: FontAwesomeIcons.star,
                    label: "Challenge",
                    index: 3,
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final isSelected = currentIndex == index;
    final itemColor = isSelected ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // Horizontal layout - icon ug text side by side kung selected
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.0 : 12.0,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          // Rounded background para sa selected item
          color: isSelected
              ? selectedColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            FaIcon(isSelected ? activeIcon : icon, color: itemColor, size: 22),
            // Show label beside icon kung selected (similar sa image)
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
