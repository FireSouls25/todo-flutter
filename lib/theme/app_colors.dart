import 'package:flutter/material.dart';

class AppColors {
  // Brand - Green palette from the design
  static const Color primary = Color(0xFF2DC78B); // Main green
  static const Color primaryLight = Color(0xFF4DD9A0); // Lighter green
  static const Color primaryExtraLight = Color(0xFFE8F8F2); // Very light green bg
  static const Color primaryDark = Color(0xFF1DAF78); // Darker green for pressed

  // Backgrounds
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color scaffoldBg = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textLight = Colors.white;
  static const Color textHint = Color(0xFFBDBDBD);

  // Task time badge colors
  static const Color timeBadgeOrange = Color(0xFFFFF3E0);
  static const Color timeBadgeOrangeText = Color(0xFFFF9800);
  static const Color timeBadgeGreen = Color(0xFFE8F8F2);
  static const Color timeBadgeGreenText = Color(0xFF2DC78B);

  // States & Borders
  static const Color border = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFF0F0F0);
  static const Color checkboxBorder = Color(0xFFE0E0E0);

  // Category chip
  static const Color chipSelected = Color(0xFF2DC78B);
  static const Color chipUnselected = Colors.white;
  static const Color chipUnselectedText = Color(0xFF555555);

  // Progress
  static const Color progressTrack = Color(0xFFE8F8F2);

  // Analytics
  static const Color analyticsBar = Color(0xFF2DC78B);
  static const Color analyticsBarLight = Color(0xFFE8F8F2);

  // Red for overdue
  static const Color danger = Color(0xFFE53935);
  static const Color dangerLight = Color(0xFFFFEBEE);
}
