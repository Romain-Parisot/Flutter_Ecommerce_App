import '../../../cart/domain/entities/cart_item.dart';

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
    this.status = 'Préparation',
  });

  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  final String status;
}
