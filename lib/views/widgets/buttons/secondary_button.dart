import 'package:flutter/material.dart';
import 'package:petsos/views/theme/app_colors.dart';
import 'package:petsos/views/theme/app_text_styles.dart';

/// Secondary button with outline style
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool enabled;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double height;
  
  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.enabled = true,
    this.borderColor,
    this.textColor,
    this.width,
    this.height = 56,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = !enabled || isLoading || onPressed == null;
    final btnBorderColor = borderColor ?? (isDark ? AppColors.primaryStart : AppColors.primaryBase);
    final btnTextColor = textColor ?? (isDark ? AppColors.primaryStart : AppColors.primaryBase);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDisabled ? Colors.grey.shade300 : btnBorderColor,
          width: 2,
        ),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(btnTextColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: isDisabled ? Colors.grey : btnTextColor, size: 22),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            style: AppTextStyles.button(
                              color: isDisabled ? Colors.grey : btnTextColor,
                            ),
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
