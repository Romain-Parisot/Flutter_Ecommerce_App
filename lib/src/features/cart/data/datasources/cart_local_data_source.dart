import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';

class CartLocalDataSource {
  const CartLocalDataSource(this._prefs);

  final SharedPreferences _prefs;
  static const _cartKey = 'cart_items';

  Future<List<CartItemModel>> loadCart() async {
    final jsonString = _prefs.getString(_cartKey);
    if (jsonString == null) return [];
    final decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map(
          (item) => CartItemModel.fromJson(
            Map<String, dynamic>.from(item as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  Future<void> saveCart(List<CartItemModel> items) async {
    final jsonString = json.encode(items.map((item) => item.toJson()).toList());
    await _prefs.setString(_cartKey, jsonString);
  }

  Future<void> clearCart() async {
    await _prefs.remove(_cartKey);
  }
}
