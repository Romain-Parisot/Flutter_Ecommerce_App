import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/product_model.dart';

class LocalCatalogDataSource {
  LocalCatalogDataSource(
    this.bundle, {
    this.assetPath = 'assets/data/firewood_catalog.json',
  });

  final AssetBundle bundle;
  final String assetPath;

  Future<List<ProductModel>> loadProducts() async {
    final raw = await bundle.loadString(assetPath);
    final decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map(
          (item) => ProductModel.fromJson(
            Map<String, dynamic>.from(item as Map<String, dynamic>),
          ),
        )
        .toList();
  }
}
