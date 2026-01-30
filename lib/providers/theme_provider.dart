import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode { system, light, dark, teko }

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.teko);

  void setThemeMode(AppThemeMode mode) {
    state = mode;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});
