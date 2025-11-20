import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/local_catalog_data_source.dart';

class LocalCatalogRepository implements CatalogRepository {
  LocalCatalogRepository(this._dataSource);

  final LocalCatalogDataSource _dataSource;
  List<Product>? _cache;

  @override
  Future<List<Product>> fetchProducts() async {
    _cache ??= await _dataSource.loadProducts();
    return _cache!;
  }

  @override
  Future<Product> fetchProduct(String id) async {
    final products = await fetchProducts();
    return products.firstWhere((product) => product.id == id);
  }
}
