import 'package:flutter/material.dart';
import 'package:app/views/theme/app_colors.dart';
import 'package:app/views/theme/app_text_styles.dart';

/// Modern gradient button with loading state and icon support
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool enabled;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final double? width;
  final double height;
  final EdgeInsets padding;
  
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.enabled = true,
    this.backgroundColor,
    this.gradient,
    this.width,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = !enabled || isLoading || onPressed == null;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: !isDisabled
            ? (gradient ?? AppColors.getPrimaryGradient(isDark))
            : null,
        color: isDisabled ? Colors.grey.shade300 : backgroundColor,
        boxShadow: !isDisabled
            ? [
                BoxShadow(
                  color: (gradient != null || backgroundColor != null)
                      ? (backgroundColor ?? AppColors.primaryBase).withValues(alpha: 0.3)
                      : AppColors.primaryBase.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            style: AppTextStyles.button(color: Colors.white),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
