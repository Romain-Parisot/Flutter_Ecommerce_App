import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/local_catalog_data_source.dart';
import '../data/repositories/local_catalog_repository.dart';
import '../domain/entities/product.dart';
import '../domain/repositories/catalog_repository.dart';

final assetBundleProvider = Provider<AssetBundle>((ref) => rootBundle);

final localCatalogDataSourceProvider = Provider<LocalCatalogDataSource>((ref) {
  return LocalCatalogDataSource(ref.watch(assetBundleProvider));
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return LocalCatalogRepository(ref.watch(localCatalogDataSourceProvider));
});

final catalogSearchQueryProvider = StateProvider<String>((ref) => '');
final catalogWoodTypeFilterProvider = StateProvider<String?>((ref) => null);
final catalogMaxPriceFilterProvider = StateProvider<double?>((ref) => null);

final catalogListProvider =
    AsyncNotifierProvider<CatalogNotifier, List<Product>>(CatalogNotifier.new);

class CatalogNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() {
    final repository = ref.watch(catalogRepositoryProvider);
    return repository.fetchProducts();
  }
}

final productByIdProvider = FutureProvider.family<Product, String>((
  ref,
  id,
) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.fetchProduct(id);
});
