import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Healthcare Palette Colors
  static const Color primaryBlue = Color(0xFF2563EB);      // New Clinical Blue (#2563EB)
  static const Color secondaryEmerald = Color(0xFF14B8A6);  // New Secondary Teal (#14B8A6)
  static const Color accentGreen = Color(0xFF10B981);       // Accent Emerald (#10B981)
  static const Color alertCoral = Color(0xFFEF4444);        // Error Coral (#EF4444)

  // Light Theme Colors
  static const Color lightBg = Color(0xFFF8FAFC);          // Background (#F8FAFC)
  static const Color lightSurface = Color(0xFFFFFFFF);     // Card/Surface (#FFFFFF)
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextHint = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Theme Colors
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextHint = Color(0xFF64748B);
  static const Color darkBorder = Color(0xFF334155);

  // Color Schemes
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDBEAFE),
    onPrimaryContainer: Color(0xFF1E40AF),
    secondary: secondaryEmerald,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFCCFBF1),
    onSecondaryContainer: Color(0xFF115E59),
    tertiary: accentGreen,
    onTertiary: Colors.white,
    error: alertCoral,
    onError: Colors.white,
    surface: lightSurface,          // Card/Dialog background (#FFFFFF)
    onSurface: lightTextPrimary,
    background: lightBg,            // Scaffold background (#F8FAFC)
    onBackground: lightTextPrimary,
    outline: lightBorder,
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF60A5FA),
    onPrimary: Color(0xFF1E3A8A),
    primaryContainer: Color(0xFF1E40AF),
    onPrimaryContainer: Color(0xFFDBEAFE),
    secondary: Color(0xFF2DD4BF),
    onSecondary: Color(0xFF0F766E),
    secondaryContainer: Color(0xFF115E59),
    onSecondaryContainer: Color(0xFFCCFBF1),
    tertiary: Color(0xFF34D399),
    onTertiary: Color(0xFF064E3B),
    error: Color(0xFFF87171),
    onError: Color(0xFF7F1D1D),
    surface: darkSurface,
    onSurface: darkTextPrimary,
    background: darkBg,
    onBackground: darkTextPrimary,
    outline: darkBorder,
  );
}
