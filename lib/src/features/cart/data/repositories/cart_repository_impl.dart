import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._dataSource);

  final CartLocalDataSource _dataSource;

  @override
  Future<List<CartItem>> loadCart() async {
    return _dataSource.loadCart();
  }

  @override
  Future<void> saveCart(List<CartItem> items) {
    final models = items.map(CartItemModel.fromCartItem).toList();
    return _dataSource.saveCart(models);
  }

  @override
  Future<void> clearCart() {
    return _dataSource.clearCart();
  }
}
