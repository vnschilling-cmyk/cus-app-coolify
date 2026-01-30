import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lead.dart';
import '../services/pocketbase_service.dart';

final pbServiceProvider = Provider((ref) => PocketBaseService());

final leadListProvider = AsyncNotifierProvider<LeadListNotifier, List<Lead>>(
  () {
    return LeadListNotifier();
  },
);

class LeadListNotifier extends AsyncNotifier<List<Lead>> {
  PocketBaseService get _pbService => ref.read(pbServiceProvider);

  @override
  FutureOr<List<Lead>> build() async {
    return _fetchLeads();
  }

  Future<List<Lead>> _fetchLeads() async {
    return await _pbService.fetchLeads();
  }

  Future<void> refreshLeads() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLeads());
  }

  Future<void> addLead(Lead lead) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _pbService.saveLead(lead);
      return _fetchLeads();
    });
  }

  Future<void> updateLead(Lead lead) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _pbService.updateLead(lead);
      return _fetchLeads();
    });
  }
}
