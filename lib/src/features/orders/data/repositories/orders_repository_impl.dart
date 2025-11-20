import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_local_data_source.dart';
import '../models/order_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._dataSource);

  final OrdersLocalDataSource _dataSource;

  @override
  Future<List<Order>> loadOrders() async {
    return _dataSource.loadOrders();
  }

  @override
  Future<void> saveOrders(List<Order> orders) {
    final models = orders.map((order) {
      if (order is OrderModel) return order;
      return OrderModel(
        id: order.id,
        items: order.items,
        total: order.total,
        createdAt: order.createdAt,
        status: order.status,
      );
    }).toList();
    return _dataSource.saveOrders(models);
  }
}
