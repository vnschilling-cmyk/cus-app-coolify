import 'dart:math';
import '../models/lead.dart';
import '../providers/lead_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestDataService {
  final Ref ref;
  TestDataService(this.ref);

  Future<void> generateTenYearsOfData() async {
    final List<Lead> testLeads = [];
    final Random random = Random();
    final currentYear = DateTime.now().year;

    final clientTypes = [
      'Betreiber/Endkunde',
      'Selbständige Kaufleute',
      'KAB',
      'Planer/Berater',
      'Hersteller/OEM',
      'Lieferant',
      'Wettbewerber',
      'Sonstige',
    ];

    final countries = [
      'Deutschland',
      'Österreich',
      'Schweiz',
      'Italien',
      'Frankreich'
    ];
    final priorities = [
      'Sehr wichtig',
      'Wichtig',
      'Weniger wichtig',
      'Keine Priorität'
    ];

    for (int i = 0; i < 10; i++) {
      int year = currentYear - i;

      // Events for this year
      List<String> eventsThisYear = ['atmosphere']; // Atmosphere is annual

      if (year % 2 == 0) {
        eventsThisYear.add('chillventa');
      } else {
        eventsThisYear.add('akt');
      }

      for (var eventId in eventsThisYear) {
        // Generate 5-15 leads per event per year
        int leadCount = 5 + random.nextInt(11);
        for (int l = 0; l < leadCount; l++) {
          testLeads.add(Lead(
            id: 'test_${year}_${eventId}_$l',
            name: 'Test Person $l',
            company: 'Test Company ${random.nextInt(100)}',
            country: countries[random.nextInt(countries.length)],
            clientType: clientTypes[random.nextInt(clientTypes.length)],
            energyEfficiencyPriority:
                priorities[random.nextInt(priorities.length)],
            projectChance: '${random.nextInt(100)}%',
            eventId: eventId,
            year: year,
            responsible: 'system',
          ));
        }
      }
    }

    // This is a bit of a hack to add multiple leads at once if the provider supports it,
    // or just loop through them. Since we want to save them to PocketBase ideally,
    // but for local testing/dashboard demo we might just want to inject them into the state.

    // For now, let's assume we want to push them to the provider's state or the backend.
    final notifier = ref.read(leadListProvider.notifier);
    for (var lead in testLeads) {
      // In a real app we'd batch this or have a bulk create
      await notifier.addLead(lead);
    }
  }

  Future<void> seedInitialUsers() async {
    final pbService = ref.read(pbServiceProvider);
    final users = [
      {'name': 'Marion Billasch', 'email': 'm.billasch@teko-gmbh.com'},
      {'name': 'Kristin Eberhardt', 'email': 'k.eberhardt@teko-gmbh.com'},
      {'name': 'Sarah Schröter', 'email': 's.schroeter@teko-gmbh.com'},
      {
        'name': 'Viktor Schilling',
        'email': 'v.schilling@teko-gmbh.com',
        'role': 'admin'
      },
    ];
    const initialPassword = 'Marketing2026!#';

    for (final user in users) {
      try {
        await pbService.pb.collection('users').create(body: {
          'email': user['email'],
          'password': initialPassword,
          'passwordConfirm': initialPassword,
          'name': user['name'],
          'force_password_change': true,
          'role': user['role'] ?? 'user',
        });
      } catch (e) {
        // Log error or ignore if user already exists
        debugPrint('User ${user['email']} could not be created: $e');
      }
    }
  }
}

final testDataServiceProvider = Provider((ref) => TestDataService(ref));
