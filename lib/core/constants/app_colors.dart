import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Healthcare Palette Colors
  static const Color primaryBlue = Color(0xFF0284C7);      // Clinical Blue
  static const Color secondaryEmerald = Color(0xFF10B981);  // Emerald Green
  static const Color tertiarySlate = Color(0xFF0F172A);     // Slate Gray
  static const Color alertCoral = Color(0xFFEF4444);        // Error Coral

  // Light Theme Colors
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
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
    primaryContainer: Color(0xFFE0F2FE),
    onPrimaryContainer: Color(0xFF0369A1),
    secondary: secondaryEmerald,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD1FAE5),
    onSecondaryContainer: Color(0xFF047857),
    tertiary: Color(0xFF0F172A),
    onTertiary: Colors.white,
    error: alertCoral,
    onError: Colors.white,
    surface: lightSurface,
    onSurface: lightTextPrimary,
    outline: lightBorder,
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF38BDF8),
    onPrimary: Color(0xFF0369A1),
    primaryContainer: Color(0xFF0C4A6E),
    onPrimaryContainer: Color(0xFFE0F2FE),
    secondary: Color(0xFF34D399),
    onSecondary: Color(0xFF047857),
    secondaryContainer: Color(0xFF064E3B),
    onSecondaryContainer: Color(0xFFD1FAE5),
    tertiary: Color(0xFFE2E8F0),
    onTertiary: Color(0xFF0F172A),
    error: Color(0xFFF87171),
    onError: Color(0xFF7F1D1D),
    surface: darkSurface,
    onSurface: darkTextPrimary,
    outline: darkBorder,
  );
}
