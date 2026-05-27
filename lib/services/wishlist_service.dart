import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WishlistService {
  static const String _key = 'wishlist_product_ids';

  Future<List<int>> getProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((id) => int.tryParse(id.toString()))
          .whereType<int>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isFavorite(int productId) async {
    final ids = await getProductIds();
    return ids.contains(productId);
  }

  Future<bool> toggle(int productId) async {
    final ids = await getProductIds();
    final isSaved = ids.contains(productId);

    if (isSaved) {
      ids.remove(productId);
    } else {
      ids.insert(0, productId);
    }

    await _save(ids);
    return !isSaved;
  }

  Future<void> remove(int productId) async {
    final ids = await getProductIds();
    ids.remove(productId);
    await _save(ids);
  }

  Future<int> count() async => (await getProductIds()).length;

  Future<void> _save(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final uniqueIds = <int>[];
    for (final id in ids) {
      if (!uniqueIds.contains(id)) uniqueIds.add(id);
    }
    await prefs.setString(_key, jsonEncode(uniqueIds));
  }
}
