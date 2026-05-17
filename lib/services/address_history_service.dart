import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AddressHistoryEntry {
  final String phone;
  final String address;
  final double? lat;
  final double? lng;
  final DateTime savedAt;

  const AddressHistoryEntry({
    required this.phone,
    required this.address,
    required this.savedAt,
    this.lat,
    this.lng,
  });

  factory AddressHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AddressHistoryEntry(
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? ''),
      lng: double.tryParse(json['lng']?.toString() ?? ''),
      savedAt:
          DateTime.tryParse(json['saved_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'address': address,
    'lat': lat,
    'lng': lng,
    'saved_at': savedAt.toIso8601String(),
  };
}

class AddressHistoryService {
  static const String _key = 'address_history';
  static const int _maxEntries = 30;

  Future<List<AddressHistoryEntry>> loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                AddressHistoryEntry.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((entry) => entry.address.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAddress({
    required String phone,
    required String address,
    required double lat,
    required double lng,
  }) async {
    final current = await loadAddresses();
    final normalizedAddress = address.trim().toLowerCase();
    final normalizedPhone = phone.trim().toLowerCase();

    current.removeWhere(
      (entry) =>
          entry.address.trim().toLowerCase() == normalizedAddress &&
          entry.phone.trim().toLowerCase() == normalizedPhone,
    );

    current.insert(
      0,
      AddressHistoryEntry(
        phone: phone.trim(),
        address: address.trim(),
        lat: lat,
        lng: lng,
        savedAt: DateTime.now(),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(current.take(_maxEntries).map((e) => e.toJson()).toList()),
    );
  }

  Future<int> count() async => (await loadAddresses()).length;
}
