import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:petsos/views/theme/app_colors.dart';
import 'package:petsos/views/theme/app_text_styles.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/custom_text_field.dart';
import '../../../utils/app_validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'create_account'.tr(),
                  style: AppTextStyles.h2(isDark: isDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'join_community'.tr(),
                  style: AppTextStyles.bodyMedium(
                    isDark: isDark,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                CustomTextField(
                  controller: _nameController,
                  label: 'full_name'.tr(),
                  prefixIcon: Icons.person,
                  validator: AppValidators.validateName,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _usernameController,
                  label: 'username'.tr(),
                  prefixIcon: Icons.alternate_email,
                  validator: AppValidators.validateUsername,
                ),
                const SizedBox(height: 16), // Added spacing

                CustomTextField(
                  controller: _emailController,
                  label: 'email'.tr(),
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.validateEmail,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _phoneController,
                  label: 'phone_number'.tr(),
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.validatePhone,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  label: 'password'.tr(),
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'confirm_password'.tr(),
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => AppValidators.validateConfirmPassword(
                      v, _passwordController.text),
                ),

                const SizedBox(height: 32),

                PrimaryButton(
                  text: 'sign_up'.tr(),
                  onPressed: () async {
                    // Uses the GlobalKey<FormState> to validate all text fields at once
                    // based on the logic defined in AppValidators.
                    if (!_formKey.currentState!.validate()) return;

                    setState(() => _isLoading = true);

                    final authVM =
                        Provider.of<AuthViewModel>(context, listen: false);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    try {
                      final error = await authVM.signUpWithEmail(
                        _emailController.text.trim(),
                        _passwordController.text,
                        _nameController.text.trim(),
                        _usernameController.text.trim(),
                        _phoneController.text.trim(),
                      );

                      if (!mounted) return;

                      if (error == null) {
                        navigator.pop(); // Go back or auto-login
                      } else {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      // Use captured messenger if possible, but context is safer in catch block with mounted check usually.
                      // However, linter complained about context across async gap.
                      // Since we defined scaffoldMessenger BEFORE try, we can use it!
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
