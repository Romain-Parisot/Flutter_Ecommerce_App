import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_3/src/features/catalog/data/models/product_model.dart';
import 'package:flutter_application_3/src/features/catalog/data/repositories/local_catalog_repository.dart';
import 'package:flutter_application_3/src/features/catalog/data/datasources/local_catalog_data_source.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    return ByteData(0);
  }
}

class _SpyCatalogDataSource extends LocalCatalogDataSource {
  _SpyCatalogDataSource(this._products)
    : super(_FakeAssetBundle(), assetPath: 'unused');

  final List<ProductModel> _products;
  int loadCount = 0;

  @override
  Future<List<ProductModel>> loadProducts() async {
    loadCount++;
    return _products;
  }
}

ProductModel _model(String id) {
  return ProductModel(
    id: id,
    title: 'Produit $id',
    price: 50,
    thumbnail: 'thumb-$id',
    images: const ['img'],
    description: 'Desc',
    category: 'bois',
    steres: 1,
    logLengthCm: 33,
    logDiameterCm: 8,
    woodType: 'Chêne',
    dryness: '15%',
    availabilityDays: 3,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LocalCatalogRepository caches data after first load', () async {
    final dataSource = _SpyCatalogDataSource([_model('p1'), _model('p2')]);
    final repository = LocalCatalogRepository(dataSource);

    final first = await repository.fetchProducts();
    final product = await repository.fetchProduct('p2');

    expect(first, hasLength(2));
    expect(product.id, 'p2');
    expect(dataSource.loadCount, 1, reason: 'should reuse cached products');
  });
}
