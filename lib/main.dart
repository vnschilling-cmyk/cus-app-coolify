import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/theme.dart';
import 'ui/pages/dashboard_page.dart';

import 'ui/pages/login_page.dart';
import 'ui/pages/change_password_page.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'models/auth_status.dart';
import 'ui/pages/register_page.dart';

void main() {
  runApp(const ProviderScope(child: LeadManagementApp()));
}

class LeadManagementApp extends ConsumerWidget {
  const LeadManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);

    // Check for registration path on web (Extreme Robust Detection)
    final Uri uri = Uri.base;
    final bool isRegisterPath = uri.path.toLowerCase().contains('register') ||
        uri.queryParameters.containsKey('register') ||
        uri.query.toLowerCase().contains('register') ||
        uri.fragment.toLowerCase().contains('register');

    // Convert AppThemeMode to Flutter ThemeMode and specific Themes
    ThemeMode flutterThemeMode = ThemeMode.system;
    ThemeData? customTheme;

    switch (themeMode) {
      case AppThemeMode.light:
        flutterThemeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        flutterThemeMode = ThemeMode.dark;
        break;
      case AppThemeMode.teko:
        flutterThemeMode = ThemeMode.dark; // Base on dark
        customTheme = AppTheme.tekoTheme;
        break;
      default:
        flutterThemeMode = ThemeMode.system;
    }

    return MaterialApp(
      title: 'Messe Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: customTheme ?? AppTheme.darkTheme,
      themeMode: flutterThemeMode,
      routes: {
        '/register': (context) => const RegisterPage(),
      },
      home: isRegisterPath
          ? const RegisterPage()
          : authState.when(
              data: (status) {
                switch (status) {
                  case AuthStatus.authenticated:
                    return const DashboardPage();
                  case AuthStatus.needsPasswordChange:
                    return const ChangePasswordPage();
                  case AuthStatus.unauthenticated:
                    return const LoginPage();
                }
              },
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (err, stack) => const LoginPage(),
            ),
    );
  }
}
