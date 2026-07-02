import 'package:flutter/material.dart';
import 'package:app/views/theme/app_colors.dart';
import 'package:app/views/theme/app_text_styles.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/// Custom dialog for requesting location permission
class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;
  
  const LocationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onDeny,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Icon(
                Icons.location_on,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Enable Location',
              style: AppTextStyles.h4(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              'We need your location to show nearby pets and accurately report lost or found pets on the map.',
              style: AppTextStyles.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                isDark: isDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Column(
              children: [
                PrimaryButton(
                  text: 'Allow',
                  onPressed: onAllow,
                  icon: Icons.check_circle,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  text: 'Not Now',
                  onPressed: onDeny,
                  width: double.infinity,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show the location permission dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LocationPermissionDialog(
          onAllow: () => Navigator.of(context).pop(true),
          onDeny: () => Navigator.of(context).pop(false),
        );
      },
    );
  }
}
