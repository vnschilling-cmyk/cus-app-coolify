import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lead.dart';
import '../models/guest.dart';

class PocketBaseService {
  late PocketBase pb;
  static const String baseUrl =
      'https://pocketbase-cus-app-coolify.195.201.231.49.nip.io';

  PocketBaseService() {
    pb = PocketBase(baseUrl);
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final store = AsyncAuthStore(
      save: (String data) async => prefs.setString('pb_auth', data),
      initial: prefs.getString('pb_auth'),
    );
    pb = PocketBase(baseUrl, authStore: store);
  }

  Future<bool> login(String email, String password) async {
    try {
      await pb.collection('users').authWithPassword(email, password);
      return pb.authStore.isValid;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    pb.authStore.clear();
  }

  Future<List<Lead>> fetchLeads() async {
    final records = await pb.collection('leads').getFullList();
    return records.map((record) => Lead.fromJson(record.toJson())).toList();
  }

  Future<void> saveLead(Lead lead) async {
    await pb.collection('leads').create(body: lead.toJson());
  }

  Future<void> updateLead(Lead lead) async {
    await pb.collection('leads').update(lead.id, body: lead.toJson());
  }

  Future<List<Guest>> fetchGuests() async {
    final records = await pb.collection('guests').getFullList();
    return records.map((record) => Guest.fromJson(record.toJson())).toList();
  }

  Future<void> checkInGuest(String qrCode) async {
    final record =
        await pb.collection('guests').getFirstListItem('qr_code = "$qrCode"');
    await pb.collection('guests').update(record.id, body: {'attended': true});
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    final recordId = pb.authStore.record?.id;
    if (recordId == null) throw Exception('Kein Benutzer angemeldet.');

    await pb.collection('users').update(recordId, body: {
      'oldPassword': oldPassword,
      'password': newPassword,
      'passwordConfirm': newPassword,
      'force_password_change': false,
    });
  }
}
