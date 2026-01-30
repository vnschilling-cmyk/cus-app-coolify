import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lead.dart';

class StorageService {
  static const String _keyLeads = 'cached_leads';

  Future<void> cacheLead(Lead lead) async {
    final prefs = await SharedPreferences.getInstance();
    final leads = await getCachedLeads();
    leads.add(lead);
    await prefs.setString(
      _keyLeads,
      jsonEncode(leads.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<Lead>> getCachedLeads() async {
    final prefs = await SharedPreferences.getInstance();
    final leadsJson = prefs.getString(_keyLeads);
    if (leadsJson == null) return [];

    final List<dynamic> list = jsonDecode(leadsJson);
    return list.map((e) => Lead.fromJson(e)).toList();
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLeads);
  }
}
