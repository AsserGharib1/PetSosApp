import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petsos/views/theme/app_colors.dart';
import 'package:petsos/views/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../../screens/chat/chat_screen.dart';
import '../../screens/inbox/inbox_screen.dart';
import '../../screens/admin/admin_dashboard.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'settings_title'.tr(),
          style: AppTextStyles.h5(isDark: isDark),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('settings_general'.tr(), isDark),
          _buildSettingItem(
            context,
            'settings_notifications'.tr(),
            Icons.notifications,
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
              activeThumbColor: AppColors.primaryBase,
            ),
            onTap: () => _toggleNotifications(!_notificationsEnabled),
          ),
          _buildSettingItem(
            context,
            'settings_language'.tr(),
            Icons.language,
            onTap: () => _showLanguageDialog(context),
          ),
          _buildSettingItem(
            context,
            'settings_privacy'.tr(),
            Icons.lock,
            onTap: () => _showPrivacyPolicyDialog(context),
          ),
          if (!authVM.isAdmin)
            _buildSettingItem(
              context,
              'settings_admin_access'.tr(),
              Icons.security,
              onTap: () {
                _showAdminKeyDialog(context, authVM);
              },
            ),
          if (authVM.isAdmin) ...[
            _buildSectionHeader('settings_admin_section'.tr(), isDark),
            _buildSettingItem(
              context,
              'settings_admin_dashboard'.tr(),
              Icons.admin_panel_settings,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                );
              },
            ),
            _buildSettingItem(
              context,
              'admin_messages'.tr(),
              Icons.mail_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InboxScreen(forcedUserId: 'admin'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          _buildSectionHeader('settings_support'.tr(), isDark),
          _buildSettingItem(
            context,
            'settings_help'.tr(),
            Icons.help,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    otherUserId: 'admin',
                    otherUserName: 'admin_support'.tr(),
                  ),
                ),
              );
            },
          ),
          _buildSettingItem(
            context,
            'settings_contact'.tr(),
            Icons.email,
            onTap: () => _showContactDialog(context),
          ),
          _buildSettingItem(
            context,
            'settings_about'.tr(),
            Icons.info,
            onTap: () => _showAboutAppDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.label(
          isDark: isDark,
          color: isDark ? AppColors.primaryStart : AppColors.primaryBase,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        title: Text(title, style: AppTextStyles.bodyMedium(isDark: isDark)),
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color:
                  isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showAdminKeyDialog(BuildContext context, AuthViewModel authVM) {
    final TextEditingController keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('admin_access_title'.tr()),
        content: TextField(
          controller: keyController,
          decoration: InputDecoration(
            hintText: 'enter_admin_key'.tr(),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await authVM.promoteToAdmin(
                keyController.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        success ? 'welcome_admin'.tr() : 'invalid_key'.tr()),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: Text('verify'.tr()),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings_privacy'.tr()),
        content: SingleChildScrollView(
          child: Text(
            'privacy_policy_content'.tr(),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings_contact'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContactOption(
              context,
              'contact_collab'.tr(),
              'Petsos@gmail.com',
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              context,
              'contact_donate'.tr(),
              'PetsosSupport@gmail.com',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(BuildContext context, String title, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: email));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('email_copied'.tr())),
            );
          },
          child: Row(
            children: [
              Icon(Icons.copy, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  email,
                  style: const TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.pets, color: AppColors.primaryBase),
            const SizedBox(width: 10),
            const Text('PetSOS'),
          ],
        ),
        content: Text(
          'about_creative_text'.tr(),
          style: const TextStyle(fontSize: 15, height: 1.4),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('change_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              trailing: context.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              leading: const Text('🇪🇬', style: TextStyle(fontSize: 24)),
              trailing: context.locale.languageCode == 'ar'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                context.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
