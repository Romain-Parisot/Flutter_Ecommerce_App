import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_model.dart';

class OrdersLocalDataSource {
  const OrdersLocalDataSource(this._prefs);

  final SharedPreferences _prefs;
  static const _ordersKey = 'orders_history';

  Future<List<OrderModel>> loadOrders() async {
    final jsonString = _prefs.getString(_ordersKey);
    if (jsonString == null) return [];
    final decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map(
          (item) => OrderModel.fromJson(
            Map<String, dynamic>.from(item as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  Future<void> saveOrders(List<OrderModel> orders) async {
    final jsonString = json.encode(
      orders.map((order) => order.toJson()).toList(),
    );
    await _prefs.setString(_ordersKey, jsonString);
  }
}
