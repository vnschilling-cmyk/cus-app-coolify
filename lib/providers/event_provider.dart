import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';

final eventProvider = Provider<List<Event>>((ref) {
  return const [
    Event(id: 'chillventa', name: 'Chillventa', type: 'Messe'),
    Event(id: 'atmosphere', name: 'Atmosphere', type: 'Messe'),
    Event(id: 'akt', name: 'AKT', type: 'Hausmesse'),
  ];
});
