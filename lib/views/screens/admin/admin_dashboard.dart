import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'package:app/views/theme/app_colors.dart';
import 'package:app/views/theme/app_text_styles.dart';
import 'tabs/users_tab.dart';
import 'tabs/pets_tab.dart';

import 'package:easy_localization/easy_localization.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Security check (double check)
    if (!authVM.isAdmin) {
      return Scaffold(
        body: Center(
          child: Text('Access Denied', style: AppTextStyles.h4(isDark: isDark)),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          title: Text(
            'admin_dashboard'.tr(),
            style: AppTextStyles.h5(isDark: isDark),
          ),
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.people), text: 'manage_users'.tr()),
              Tab(icon: const Icon(Icons.pets), text: 'manage_pets'.tr()),
            ],
          ),
        ),
        body: const TabBarView(children: [UsersTab(), PetsTab()]),
      ),
    );
  }
}
