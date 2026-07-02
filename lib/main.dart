import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'viewmodels/pets_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'viewmodels/location_viewmodel.dart';
import 'viewmodels/map_viewmodel.dart';
import 'viewmodels/navigation_viewmodel.dart';
import 'firebase_options.dart';
import 'views/theme/app_theme.dart';
import 'views/theme/app_colors.dart';
import 'views/screens/map/map_screen.dart';
import 'views/screens/abandoned/abandoned_screen.dart';
import 'views/screens/inbox/inbox_screen.dart';
import 'views/screens/profile/profile_screen.dart';
import 'views/screens/settings/settings_screen.dart';
import 'views/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await EasyLocalization.ensureInitialized();

  // Add App Check Debug Provider
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug,
  //   appleProvider: AppleProvider.debug,
  // );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) {
              return PetsViewModel();
            },
          ),
          ChangeNotifierProvider(create: (_) {
            return AuthViewModel();
          }),
          ChangeNotifierProvider(create: (_) => ThemeViewModel()),
          ChangeNotifierProvider(create: (_) => ChatViewModel()),
          ChangeNotifierProvider(create: (_) {
            return LocationViewModel();
          }),
          ChangeNotifierProvider(create: (_) {
            return MapViewModel();
          }),
          ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeVM, child) {
        return MaterialApp(
          title: 'PetSOS',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeVM.themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
          routes: {'/settings': (_) => const SettingsScreen()},
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Check if user is logged in
    if (authViewModel.isLoggedIn) {
      return const MainShell();
    } else {
      return const LoginScreen();
    }
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  Widget build(BuildContext context) {
    final navVM = Provider.of<NavigationViewModel>(context);
    final selectedIndex = navVM.currentIndex;

    final pages = <Widget>[
      const MapScreen(),
      const AbandonedScreen(),
      const InboxScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: selectedIndex, children: pages),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => navVM.setIndex(0),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBase.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.pets, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _NavBarItem(
                    icon: Icons.map,
                    label: 'nav_maps'.tr(),
                    index: 0,
                    selected: selectedIndex == 0,
                    onTap: navVM.setIndex,
                  ),
                  _NavBarItem(
                    icon: Icons.pets,
                    label: 'nav_abandoned'.tr(),
                    index: 1,
                    selected: selectedIndex == 1,
                    onTap: navVM.setIndex,
                  ),
                ],
              ),
              Row(
                children: [
                  _NavBarItem(
                    icon: Icons.inbox,
                    label: 'nav_inbox'.tr(),
                    index: 2,
                    selected: selectedIndex == 2,
                    onTap: navVM.setIndex,
                  ),
                  _NavBarItem(
                    icon: Icons.person,
                    label: 'nav_profile'.tr(),
                    index: 3,
                    selected: selectedIndex == 3,
                    onTap: navVM.setIndex,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final ValueChanged<int> onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor =
        isDark ? AppColors.primaryStart : AppColors.primaryBase;
    final unselectedColor =
        isDark ? AppColors.darkTextTertiary : Colors.black54;

    return InkWell(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? selectedColor : unselectedColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? selectedColor : unselectedColor,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
