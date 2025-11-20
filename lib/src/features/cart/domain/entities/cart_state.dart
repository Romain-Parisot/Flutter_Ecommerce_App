import 'cart_item.dart';

class CartState {
  CartState({required List<CartItem> items}) : items = List.unmodifiable(items);

  final List<CartItem> items;

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);

  static final empty = CartState(items: const <CartItem>[]);
}
