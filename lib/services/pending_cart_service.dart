import 'dart:convert';

import 'package:mart_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pending_cart_model.dart';

class PendingCartService {
  static const key = "pending_cart";

  Future<void> save({required int productId, required int quantity}) async {
    final prefs = await SharedPreferences.getInstance();

    List<PendingCartModel> items = await getItems();

    final index = items.indexWhere((e) => e.productId == productId);

    if (index >= 0) {
      items[index] = PendingCartModel(productId: productId, quantity: quantity);
    } else {
      items.add(PendingCartModel(productId: productId, quantity: quantity));
    }

    prefs.setString(key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<List<PendingCartModel>> getItems() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key);

    if (data == null) return [];

    final list = jsonDecode(data) as List;

    return list.map((e) => PendingCartModel.fromJson(e)).toList();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(key);
  }

  // Future<void> syncAfterLogin() async {
  //   final items = await getItems();

  //   if (items.isEmpty) return;

  //   for (final item in items) {
  //     await ApiService().addToCart(
  //       productId: item.productId,
  //       quantity: item.quantity,
  //     );
  //   }

  //   await clear();
  // }
  Future<void> syncAfterLogin() async {
    final items = await getItems();

    if (items.isEmpty) return;

    final failed = <PendingCartModel>[];

    for (final item in items) {
      try {
        await ApiService().addToCart(
          productId: item.productId,
          quantity: item.quantity,
        );
      } catch (e) {
        failed.add(item);
      }
    }

    final prefs = await SharedPreferences.getInstance();

    if (failed.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(
        key,
        jsonEncode(failed.map((e) => e.toJson()).toList()),
      );
    }
  }
}
