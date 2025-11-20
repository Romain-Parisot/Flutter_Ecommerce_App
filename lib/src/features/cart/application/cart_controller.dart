import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/shared_prefs_provider.dart';
import '../../catalog/domain/entities/product.dart';
import '../data/datasources/cart_local_data_source.dart';
import '../data/repositories/cart_repository_impl.dart';
import '../domain/entities/cart_item.dart';
import '../domain/entities/cart_state.dart';
import '../domain/repositories/cart_repository.dart';

final cartControllerProvider = AsyncNotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

class CartNotifier extends AsyncNotifier<CartState> {
  CartRepository? _repository;

  Future<CartRepository> _ensureRepository() async {
    if (_repository != null) return _repository!;
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    _repository = CartRepositoryImpl(CartLocalDataSource(prefs));
    return _repository!;
  }

  @override
  Future<CartState> build() async {
    final repository = await _ensureRepository();
    final items = await repository.loadCart();
    return CartState(items: items);
  }

  Future<void> addProduct(Product product, {int quantity = 1}) async {
    final current = state.valueOrNull ?? await future;
    final items = [...current.items];
    final index = items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + quantity,
      );
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }
    await _persist(items);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final current = state.valueOrNull ?? await future;
    final items = [...current.items];
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;
    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: quantity);
    }
    await _persist(items);
  }

  Future<void> removeItem(String productId) async {
    final current = state.valueOrNull ?? await future;
    final items = current.items
        .where((item) => item.product.id != productId)
        .toList();
    await _persist(items);
  }

  Future<void> clearCart() async {
    final repository = await _ensureRepository();
    await repository.clearCart();
    state = AsyncData(CartState.empty);
  }

  Future<void> _persist(List<CartItem> items) async {
    final repository = await _ensureRepository();
    await repository.saveCart(items);
    state = AsyncData(CartState(items: items));
  }
}
