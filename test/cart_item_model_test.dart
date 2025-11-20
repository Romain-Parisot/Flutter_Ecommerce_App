import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_3/src/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_application_3/src/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_application_3/src/features/catalog/data/models/product_model.dart';
import 'package:flutter_application_3/src/features/catalog/domain/entities/product.dart';

Product _product({String id = 'prod'}) {
  return Product(
    id: id,
    title: 'Produit $id',
    price: 70,
    thumbnail: 'thumb-$id',
    images: ['img-$id'],
    description: 'Desc',
    category: 'bois',
    steres: 1.2,
    logLengthCm: 33,
    logDiameterCm: 9,
    woodType: 'Frêne',
    dryness: '14%',
    availabilityDays: 4,
  );
}

ProductModel _productModel(String id) {
  return ProductModel(
    id: id,
    title: 'Modèle $id',
    price: 42,
    thumbnail: 'thumb',
    images: const ['img'],
    description: 'Desc',
    category: 'bois',
    steres: 1,
    logLengthCm: 33,
    logDiameterCm: 8,
    woodType: 'Bouleau',
    dryness: '13%',
    availabilityDays: 3,
  );
}

void main() {
  test('CartItemModel round-trips through json', () {
    final model = CartItemModel(product: _productModel('a'), quantity: 2);

    final json = model.toJson();
    final restored = CartItemModel.fromJson(json);

    expect(restored.product.title, 'Modèle a');
    expect(restored.quantity, 2);
  });

  test('CartItemModel.fromCartItem adapts plain Product', () {
    final cartItem = CartItemModel.fromCartItem(
      CartItem(product: _product(id: 'plain'), quantity: 3),
    );

    expect(cartItem.product, isA<ProductModel>());
    expect(cartItem.product.id, 'plain');
    expect(cartItem.quantity, 3);
  });
}
