import 'package:flutter/material.dart';

/// Modern color palette for Abandoned Pets app
/// Features vibrant gradients, semantic colors, and full dark mode support

class AppColors {
  // Primary gradient (Teal to Emerald)
  static const Color primaryStart = Color(0xFF2DD4BF); // Bright teal
  static const Color primaryEnd = Color(0xFF10B981); // Emerald green
  static const Color primaryBase = Color(0xFF14B8A6); // Main teal color
  
  // Secondary gradient (Amber to Orange)
  static const Color secondaryStart = Color(0xFFFBBF24); // Bright amber
  static const Color secondaryEnd = Color(0xFFF97316); // Orange
  static const Color secondaryBase = Color(0xFFF59E0B); // Main amber
  
  // Accent colors
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentBlue = Color(0xFF3B82F6);
  
  // Pet status colors
  static const Color lostPetColor = Color(0xFFEF4444); // Red
  static const Color foundPetColor = Color(0xFF10B981); // Green
  static const Color adoptionColor = Color(0xFF8B5CF6); // Violet
  
  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Neutral colors (Light mode)
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color onBackground = Color(0xFF111827);
  static const Color onSurface = Color(0xFF1F2937);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);
  
  // Dark mode colors
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700
  static const Color darkOnBackground = Color(0xFFF1F5F9);
  static const Color darkOnSurface = Color(0xFFE2E8F0);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);
  static const Color darkDivider = Color(0xFF475569);
  static const Color darkBorder = Color(0xFF334155);
  
  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryStart, secondaryEnd],
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFFA726), Color(0xFFFFD93D)],
  );
  
  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );
  
  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
  );
  
  // Glassmorphic overlay colors
  static Color glassLight = primaryBase.withValues(alpha: 0.1);
  static Color glassDark = Colors.black.withValues(alpha: 0.2);
  
  // Shadow colors
  static Color shadowLight = Colors.black.withValues(alpha: 0.08);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.12);
  static Color shadowHeavy = Colors.black.withValues(alpha: 0.20);
  
  // Map marker colors
  static const Color userLocationMarker = Color(0xFF3B82F6); // Blue
  static const Color lostMarker = Color(0xFFEF4444); // Red
  static const Color foundMarker = Color(0xFF10B981); // Green
  
  // Badge colors
  static Color getBadgeColor(String status) {
    switch (status.toLowerCase()) {
      case 'lost':
        return lostPetColor;
      case 'found':
        return foundPetColor;
      case 'adopted':
        return adoptionColor;
      default:
        return textSecondary;
    }
  }
  
  // Helper to get gradient by theme
  static LinearGradient getPrimaryGradient(bool isDark) {
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF14B8A6), Color(0xFF059669)],
      );
    }
    return primaryGradient;
  }
}
