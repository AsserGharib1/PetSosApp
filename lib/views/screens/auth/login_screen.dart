import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petsos/views/theme/app_colors.dart';
import 'package:petsos/views/theme/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';
import '../../widgets/inputs/custom_text_field.dart';
import '../../../utils/app_validators.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    debugPrint('🔑 LoginScreen: Attempting login for ${_emailController.text}');

    try {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final error = await authVM.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      debugPrint('🔑 LoginScreen: Login result error: $error');

      if (!mounted) return;

      if (error != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        debugPrint(
          '🔑 LoginScreen: Login successful. Waiting for AuthWrapper...',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful! Redirecting...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('🔑 LoginScreen: Exception caught: $e');
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo or Icon
                Container(
                  height: 120,
                  width: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(Icons.pets, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 32),

                Text(
                  'welcome_back'.tr(),
                  style: AppTextStyles.h2(isDark: isDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'sign_in_subtitle'.tr(),
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
                  controller: _emailController,
                  label: 'email'.tr(),
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.validateEmail,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'password'.tr(),
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: AppValidators.validatePassword,
                ),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot password logic
                    },
                    child: Text(
                      'forgot_password'.tr(),
                      style: AppTextStyles.bodySmallBold(
                        color: AppColors.primaryBase,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  text: 'login'.tr(),
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or'.tr(),
                        style: AppTextStyles.label(isDark: isDark),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SecondaryButton(
                  text: 'sign_in_google'.tr(),
                  icon: Icons.g_mobiledata, // Use custom asset in real app
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    try {
                      final authVM = Provider.of<AuthViewModel>(
                        context,
                        listen: false,
                      );
                      final error = await authVM.signInWithGoogle(
                        context.locale.languageCode,
                      );

                      if (!mounted) return;

                      if (error != null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                        }
                      }
                      // Navigation is handled by AuthWrapper in main.dart
                    } catch (e) {
                      if (mounted) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${'no_account'.tr()} ',
                      style: AppTextStyles.bodyMedium(isDark: isDark),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'sign_up'.tr(),
                        style: AppTextStyles.bodyMediumBold(
                          color: AppColors.primaryBase,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
