import '../../../cart/data/models/cart_item_model.dart';
import '../../domain/entities/order.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.items,
    required super.total,
    required super.createdAt,
    super.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => CartItemModel.fromJson(
              Map<String, dynamic>.from(item as Map<String, dynamic>),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'items': items
          .map((item) => CartItemModel.fromCartItem(item).toJson())
          .toList(),
    };
  }
}
