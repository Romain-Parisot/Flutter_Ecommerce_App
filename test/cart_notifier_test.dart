import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_3/src/features/cart/application/cart_controller.dart';
import 'package:flutter_application_3/src/features/cart/domain/entities/cart_state.dart';
import 'package:flutter_application_3/src/features/catalog/domain/entities/product.dart';

Product _buildProduct({String id = 'firewood-1', double price = 59.9}) {
  return Product(
    id: id,
    title: 'Chêne premium',
    price: price,
    thumbnail: 'https://example.com/$id-thumb.jpg',
    images: ['https://example.com/$id.jpg'],
    description: 'Le top pour les longues flambées.',
    category: 'bois',
    steres: 1.5,
    logLengthCm: 33,
    logDiameterCm: 8,
    woodType: 'Chêne',
    dryness: '16%',
    availabilityDays: 5,
  );
}

Future<CartState> _cartState(ProviderContainer container) async {
  final current = container.read(cartControllerProvider);
  if (current.hasValue) {
    return current.requireValue;
  }
  return container.read(cartControllerProvider.future);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('addProduct accumulates quantities and totals', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(cartControllerProvider.future);

    final notifier = container.read(cartControllerProvider.notifier);
    final product = _buildProduct(price: 42);

    await notifier.addProduct(product, quantity: 2);
    await notifier.addProduct(product, quantity: 1);

    final state = await _cartState(container);
    expect(state.items, hasLength(1));
    expect(state.items.first.quantity, 3);
    expect(state.total, closeTo(126, 0.001));
  });

  test('updateQuantity removes item when set to zero', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(cartControllerProvider.future);

    final notifier = container.read(cartControllerProvider.notifier);
    final product = _buildProduct(id: 'fir');

    await notifier.addProduct(product, quantity: 1);
    await notifier.updateQuantity(product.id, 0);

    final state = await _cartState(container);
    expect(state.items, isEmpty);
    expect(state.total, 0);
  });

  test('clearCart empties storage and state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(cartControllerProvider.future);

    final notifier = container.read(cartControllerProvider.notifier);
    final product = _buildProduct(id: 'mix');
    await notifier.addProduct(product, quantity: 1);

    await notifier.clearCart();

    final state = await _cartState(container);
    expect(state.isEmpty, isTrue);
  });
}
