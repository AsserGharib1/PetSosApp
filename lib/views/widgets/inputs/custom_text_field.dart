import 'package:flutter/material.dart';
import 'package:app/views/theme/app_colors.dart';
import 'package:app/views/theme/app_text_styles.dart';

/// Modern text field with enhanced styling
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Color? fillColor;
  final bool readOnly;
  
  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.fillColor,
    this.readOnly = false,
  });
  
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;
  bool _obscureText = true;
  
  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText && widget.obscureText,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        minLines: widget.minLines,
        enabled: widget.enabled,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
        style: AppTextStyles.bodyMedium(isDark: isDark),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          filled: true,
          fillColor: widget.fillColor ??
              (isDark ? AppColors.darkSurface : AppColors.surface),
          
          // Prefix icon
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: _isFocused
                      ? (isDark ? AppColors.primaryStart : AppColors.primaryBase)
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                )
              : null,
          
          // Suffix icon (including password toggle)
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : widget.suffixIcon,
          
          // Border styles
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? AppColors.primaryStart : AppColors.primaryBase,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.error,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          
          // Text styles
          labelStyle: AppTextStyles.label(isDark: isDark),
          hintStyle: AppTextStyles.bodyMedium(
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            isDark: isDark,
          ),
          errorStyle: AppTextStyles.bodySmall(color: AppColors.error),
          floatingLabelStyle: AppTextStyles.label(
            color: isDark ? AppColors.primaryStart : AppColors.primaryBase,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}
