import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:app/views/theme/app_colors.dart';
import 'package:app/views/theme/app_text_styles.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/theme_viewmodel.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final user = authVM.user;
    final appUser = authVM.appUser;

    if (user != null) {
      _nameController.text = user.displayName ?? appUser?.displayName ?? '';
      _emailController.text = user.email ?? appUser?.email ?? '';
      _phoneController.text = appUser?.phone ?? user.phoneNumber ?? '';
      _usernameController.text = appUser?.username ?? '';
      // If we have a stored displayName in Firestore (appUser), prefer it.
    }
  }

  Future<void> _toggleEdit() async {
    if (_isEditing) {
      // Save changes
      setState(() => _isLoading = true);
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final success = await authVM.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        username: _usernameController.text.trim(),
        // Username and email are typically read-only or handled separately
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('profile_updated'.tr())),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('error_title'.tr())), // Generic error
          );
        }
      }
    } else {
      // Enter edit mode
      setState(() => _isEditing = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authViewModel = Provider.of<AuthViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    // Reload data if not editing and external change occurred
    if (!_isEditing &&
        authViewModel.user?.displayName != null &&
        authViewModel.user?.displayName != _nameController.text &&
        _nameController.text.isEmpty) {
      _loadUserData();
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title:
            Text('nav_profile'.tr(), style: AppTextStyles.h5(isDark: isDark)),
        centerTitle: true,
        actions: [
          // Edit/Save Button
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _isLoading ? null : _toggleEdit,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
                image: authViewModel.user?.photoURL != null
                    ? DecorationImage(
                        image: NetworkImage(authViewModel.user!.photoURL!),
                        fit: BoxFit.cover,
                      )
                    : null,
                border: Border.all(
                  color:
                      isDark ? AppColors.primaryStart : AppColors.primaryBase,
                  width: 3,
                ),
              ),
              child: authViewModel.user?.photoURL == null
                  ? Icon(Icons.person, size: 60, color: Colors.grey.shade600)
                  : null,
            ),
            const SizedBox(height: 32),

            CustomTextField(
              controller: _nameController,
              label: 'display_name'.tr(),
              prefixIcon: Icons.person,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),

            // Username (Always Read-only)
            CustomTextField(
              controller: _usernameController,
              label: 'username'.tr(),
              prefixIcon: Icons.alternate_email,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),

            // Email (Always Read-only)
            CustomTextField(
              controller: _emailController,
              label: 'email'.tr(),
              prefixIcon: Icons.email,
              enabled: false,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              label: 'phone_number'.tr(),
              prefixIcon: Icons.phone,
              enabled: _isEditing,
            ),
            const SizedBox(height: 32),

            // Theme Toggle
            ListTile(
              title: Text('dark_mode'.tr(),
                  style: AppTextStyles.bodyMediumBold(isDark: isDark)),
              trailing: Switch(
                value: themeViewModel.isDarkMode,
                onChanged: (value) => themeViewModel.toggleTheme(value),
                activeTrackColor: AppColors.primaryBase,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
            ),
            const SizedBox(height: 24),

            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: PrimaryButton(
                  text: 'save_changes'.tr(), // Needs key or generic 'confirm'
                  onPressed: _isLoading ? null : _toggleEdit,
                ),
              ),

            PrimaryButton(
              text: 'sign_out'.tr(),
              icon: Icons.logout,
              backgroundColor: AppColors.error,
              onPressed: () async {
                await authViewModel.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
