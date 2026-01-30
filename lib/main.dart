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

    // Check for registration path on web (robust detection)
    final String currentUrl = Uri.base.toString().toLowerCase();
    final bool isRegisterPath = currentUrl.contains('register');

    return MaterialApp(
      title: 'Messe Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
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
