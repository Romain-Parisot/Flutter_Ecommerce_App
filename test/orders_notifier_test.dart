import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_3/src/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_application_3/src/features/catalog/domain/entities/product.dart';
import 'package:flutter_application_3/src/features/orders/application/orders_controller.dart';

Product _product(String id, double price) {
  return Product(
    id: id,
    title: 'Lot $id',
    price: price,
    thumbnail: 'https://example.com/$id-thumb.jpg',
    images: ['https://example.com/$id.jpg'],
    description: 'Lot $id description',
    category: 'bois',
    steres: 1,
    logLengthCm: 33,
    logDiameterCm: 8,
    woodType: 'Hêtre',
    dryness: '15%',
    availabilityDays: 7,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('createOrderFromCart persists order with computed total', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(ordersControllerProvider.future);

    final notifier = container.read(ordersControllerProvider.notifier);
    final items = [
      CartItem(product: _product('oak', 80), quantity: 2),
      CartItem(product: _product('birch', 45), quantity: 1),
    ];

    final order = await notifier.createOrderFromCart(items);
    final state = container.read(ordersControllerProvider).requireValue;

    expect(order.total, closeTo(205, 0.001));
    expect(state, isNotEmpty);
    expect(state.first.id, order.id);
    expect(state.first.items.length, 2);
  });
}
