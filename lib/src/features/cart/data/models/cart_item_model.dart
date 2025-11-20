import '../../../catalog/data/models/product_model.dart';
import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  CartItemModel({required super.product, required super.quantity});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(
        Map<String, dynamic>.from(json['product'] as Map<String, dynamic>),
      ),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': (product as ProductModel).toJson(),
      'quantity': quantity,
    };
  }

  static CartItemModel fromCartItem(CartItem item) {
    final product = item.product;
    if (product is ProductModel) {
      return CartItemModel(product: product, quantity: item.quantity);
    }
    return CartItemModel(
      product: ProductModel(
        id: product.id,
        title: product.title,
        price: product.price,
        thumbnail: product.thumbnail,
        images: product.images,
        description: product.description,
        category: product.category,
        steres: product.steres,
        logLengthCm: product.logLengthCm,
        logDiameterCm: product.logDiameterCm,
        woodType: product.woodType,
        dryness: product.dryness,
        availabilityDays: product.availabilityDays,
      ),
      quantity: item.quantity,
    );
  }
}
