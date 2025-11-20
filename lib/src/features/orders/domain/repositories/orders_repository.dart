import '../entities/order.dart';

abstract class OrdersRepository {
  Future<List<Order>> loadOrders();
  Future<void> saveOrders(List<Order> orders);
}
