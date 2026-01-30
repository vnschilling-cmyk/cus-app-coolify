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

  Future<void> createGuest(Guest guest) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _pbService.createGuest(guest);
      return _fetchGuests();
    });
  }

  Future<void> updateGuest(Guest guest) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _pbService.updateGuest(guest);
      return _fetchGuests();
    });
  }

  Future<void> deleteGuest(String id) async {
    // Optimistic update
    final previousState = state;
    if (previousState.hasValue) {
      state = AsyncValue.data(
        previousState.value!.where((g) => g.id != id).toList(),
      );
    }

    // Perform actual delete
    final result = await AsyncValue.guard(() async {
      await _pbService.deleteGuest(id);
      return _fetchGuests();
    });

    // Only update state if fetch was successful or if we need to revert
    if (!result.hasError) {
      state = result;
    } else {
      // Revert optimization on error (optional, or just show error)
      // For now, we accept the result to show the error
      state = result;
    }
  }
}
