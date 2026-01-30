import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guest.dart';
import '../services/pocketbase_service.dart';
import 'lead_provider.dart';

final guestListProvider = AsyncNotifierProvider<GuestListNotifier, List<Guest>>(
  () {
    return GuestListNotifier();
  },
);

class GuestListNotifier extends AsyncNotifier<List<Guest>> {
  PocketBaseService get _pbService => ref.read(pbServiceProvider);

  @override
  FutureOr<List<Guest>> build() async {
    return _fetchGuests();
  }

  Future<List<Guest>> _fetchGuests() async {
    return await _pbService.fetchGuests();
  }

  Future<void> refreshGuests() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGuests());
  }

  Future<void> checkIn(String qrCode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _pbService.checkInGuest(qrCode);
      return _fetchGuests();
    });
  }
}
