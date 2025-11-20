import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/shared_prefs_provider.dart';
import '../../cart/domain/entities/cart_item.dart';
import '../data/datasources/orders_local_data_source.dart';
import '../data/repositories/orders_repository_impl.dart';
import '../domain/entities/order.dart';
import '../domain/repositories/orders_repository.dart';

final ordersControllerProvider =
    AsyncNotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);

class OrdersNotifier extends AsyncNotifier<List<Order>> {
  OrdersRepository? _repository;
  final _uuid = const Uuid();

  Future<OrdersRepository> _ensureRepository() async {
    if (_repository != null) return _repository!;
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    _repository = OrdersRepositoryImpl(OrdersLocalDataSource(prefs));
    return _repository!;
  }

  @override
  Future<List<Order>> build() async {
    final repository = await _ensureRepository();
    return repository.loadOrders();
  }

  Future<Order> createOrderFromCart(List<CartItem> items) async {
    final total = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    final order = Order(
      id: _uuid.v4(),
      items: items,
      total: total,
      createdAt: DateTime.now(),
    );
    await addOrder(order);
    return order;
  }

  Future<void> addOrder(Order order) async {
    final current = state.valueOrNull ?? await future;
    final updated = [order, ...current];
    final repository = await _ensureRepository();
    await repository.saveOrders(updated);
    state = AsyncData(updated);
  }
}
