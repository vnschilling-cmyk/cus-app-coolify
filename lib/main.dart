import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/theme.dart';
import 'ui/pages/dashboard_page.dart';

import 'ui/pages/login_page.dart';
import 'ui/pages/change_password_page.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'models/auth_status.dart';

void main() {
  runApp(const ProviderScope(child: LeadManagementApp()));
}

class LeadManagementApp extends ConsumerWidget {
  const LeadManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Messe Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.when(
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
