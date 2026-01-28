import 'package:flutter/material.dart';

/// App Color Palette Configuration
/// Follows HR Employee App design guidelines
class AppColors {
  // Core Color Palette
  // Primary Color (Trust & Authority) - Deep Blue Gray
  static const Color primary = Color(0xFF1F2A37);
  static const Color primaryPressed = Color(0xFF111827);
  static const Color primaryDisabled = Color(0xFF9CA3AF);

  // Secondary Color (Growth & Support) - Muted Teal
  static const Color secondary = Color(0xFF2F8F83);
  static const Color secondaryHover = Color(0xFFE6F4F1);

  // Accent Color (Attention, Minimal Use) - Soft Amber
  static const Color accent = Color(0xFFF4B740);

  // Neutral System - Background
  static const Color backgroundMain = Color(0xFFF9FAFB);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color dividerBorder = Color(0xFFE5E7EB);

  // Neutral System - Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // Status Colors (HR-Critical)
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkPrimary = Color(0xFF3B82F6);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  // Light Theme ColorScheme
  static ColorScheme get lightColorScheme {
    return ColorScheme(
      brightness: Brightness.light,
      // Primary colors
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primary.withOpacity(0.1),
      onPrimaryContainer: primary,
      
      // Secondary colors
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: secondaryHover,
      onSecondaryContainer: secondary,
      
      // Tertiary/Accent colors
      tertiary: accent,
      onTertiary: textPrimary,
      tertiaryContainer: accent.withOpacity(0.1),
      onTertiaryContainer: accent,
      
      // Error colors
      error: error,
      onError: Colors.white,
      errorContainer: error.withOpacity(0.1),
      onErrorContainer: error,
      
      // Surface colors
      surface: backgroundCard,
      onSurface: textPrimary,
      surfaceContainerHighest: backgroundMain,
      onSurfaceVariant: textSecondary,
      
      // Outline colors
      outline: dividerBorder,
      outlineVariant: dividerBorder.withOpacity(0.5),
      
      // Shadow
      shadow: Colors.black.withOpacity(0.1),
      scrim: Colors.black.withOpacity(0.5),
      
      // Inverse colors
      inverseSurface: darkSurface,
      onInverseSurface: darkTextPrimary,
      inversePrimary: darkPrimary,
      
      // Surface tint
      surfaceTint: primary,
    );
  }

  // Dark Theme ColorScheme
  static ColorScheme get darkColorScheme {
    return ColorScheme(
      brightness: Brightness.dark,
      // Primary colors
      primary: darkPrimary,
      onPrimary: Colors.white,
      primaryContainer: darkPrimary.withOpacity(0.2),
      onPrimaryContainer: darkPrimary,
      
      // Secondary colors
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: secondary.withOpacity(0.2),
      onSecondaryContainer: secondary,
      
      // Tertiary/Accent colors
      tertiary: accent,
      onTertiary: darkTextPrimary,
      tertiaryContainer: accent.withOpacity(0.2),
      onTertiaryContainer: accent,
      
      // Error colors
      error: error,
      onError: Colors.white,
      errorContainer: error.withOpacity(0.2),
      onErrorContainer: error,
      
      // Surface colors
      surface: darkSurface,
      onSurface: darkTextPrimary,
      surfaceContainerHighest: darkBackground,
      onSurfaceVariant: darkTextSecondary,
      
      // Outline colors
      outline: dividerBorder.withOpacity(0.3),
      outlineVariant: dividerBorder.withOpacity(0.2),
      
      // Shadow
      shadow: Colors.black.withOpacity(0.3),
      scrim: Colors.black.withOpacity(0.7),
      
      // Inverse colors
      inverseSurface: backgroundCard,
      onInverseSurface: textPrimary,
      inversePrimary: primary,
      
      // Surface tint
      surfaceTint: darkPrimary,
    );
  }
}

