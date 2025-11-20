import '../entities/product.dart';

abstract class CatalogRepository {
  Future<List<Product>> fetchProducts();
  Future<Product> fetchProduct(String id);
}
