import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pocketbase_service.dart';
import '../providers/lead_provider.dart';
import '../models/auth_status.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthStatus>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<AuthStatus> {
  PocketBaseService get _pbService => ref.read(pbServiceProvider);

  @override
  FutureOr<AuthStatus> build() async {
    // Initialize the persistent store
    await _pbService.init();

    if (!_pbService.pb.authStore.isValid) return AuthStatus.unauthenticated;

    final forceChange =
        _pbService.pb.authStore.record?.data['force_password_change'] == true;
    return forceChange
        ? AuthStatus.needsPasswordChange
        : AuthStatus.authenticated;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final success = await _pbService.login(email, password);
      if (!success) {
        throw Exception('Login fehlgeschlagen. Bitte prüfen Sie Ihre Daten.');
      }

      final forceChange =
          _pbService.pb.authStore.record?.data['force_password_change'] == true;
      return forceChange
          ? AuthStatus.needsPasswordChange
          : AuthStatus.authenticated;
    });
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    // We don't use AsyncValue.guard here because we want to stay in
    // AuthStatus.needsPasswordChange if the update fails.
    final currentState = state;
    state = const AsyncValue.loading();
    try {
      await _pbService.updatePassword(oldPassword, newPassword);
      state = const AsyncValue.data(AuthStatus.authenticated);
    } catch (e) {
      state = currentState;
      rethrow;
    }
  }

  void logout() {
    _pbService.logout();
    state = const AsyncValue.data(AuthStatus.unauthenticated);
  }

  String? get currentUserId => _pbService.pb.authStore.record?.id;
}
