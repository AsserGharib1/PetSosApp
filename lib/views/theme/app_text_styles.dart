import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for Abandoned Pets app
/// Uses Inter font family for clean, modern appearance

class AppTextStyles {
  
  // Heading styles
  static TextStyle h1({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      height: 1.2,
    );
  }
  
  static TextStyle h2({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      height: 1.3,
    );
  }
  
  static TextStyle h3({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      height: 1.3,
    );
  }
  
  static TextStyle h4({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      height: 1.4,
    );
  }
  
  static TextStyle h5({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      height: 1.4,
    );
  }
  
  static TextStyle h6({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      height: 1.4,
    );
  }
  
  // Body text styles
  static TextStyle bodyLarge({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      height: 1.5,
    );
  }
  
  static TextStyle bodyMedium({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      height: 1.5,
    );
  }
  
  static TextStyle bodySmall({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
      height: 1.5,
    );
  }
  
  // Body text bold variants
  static TextStyle bodyLargeBold({Color? color, bool isDark = false}) {
    return bodyLarge(color: color, isDark: isDark).copyWith(fontWeight: FontWeight.w600);
  }
  
  static TextStyle bodyMediumBold({Color? color, bool isDark = false}) {
    return bodyMedium(color: color, isDark: isDark).copyWith(fontWeight: FontWeight.w600);
  }
  
  static TextStyle bodySmallBold({Color? color, bool isDark = false}) {
    return bodySmall(color: color, isDark: isDark).copyWith(fontWeight: FontWeight.w600);
  }
  
  // Caption and label styles
  static TextStyle caption({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
      height: 1.4,
    );
  }
  
  static TextStyle label({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: color ?? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
      height: 1.4,
    );
  }
  
  static TextStyle labelSmall({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: color ?? (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
      height: 1.4,
    );
  }
  
  // Button text styles
  static TextStyle button({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: color ?? Colors.white,
      height: 1.2,
    );
  }
  
  static TextStyle buttonSmall({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: color ?? Colors.white,
      height: 1.2,
    );
  }
  
  // Specialty styles
  static TextStyle link({bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.primaryStart : AppColors.primaryBase,
      decoration: TextDecoration.underline,
      height: 1.4,
    );
  }
  
  static TextStyle badge({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: color ?? Colors.white,
      height: 1.2,
    );
  }
  
  static TextStyle overline({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: color ?? (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
      height: 1.4,
    );
  }
}
