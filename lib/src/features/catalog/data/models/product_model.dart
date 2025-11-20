import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.thumbnail,
    required super.images,
    required super.description,
    required super.category,
    required super.steres,
    required super.logLengthCm,
    required super.logDiameterCm,
    required super.woodType,
    required super.dryness,
    required super.availabilityDays,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      thumbnail: json['thumbnail'] as String,
      images: (json['images'] as List<dynamic>).cast<String>(),
      description: json['description'] as String,
      category: json['category'] as String,
      steres: (json['steres'] as num).toDouble(),
      logLengthCm: (json['logLengthCm'] as num).toDouble(),
      logDiameterCm: (json['logDiameterCm'] as num).toDouble(),
      woodType: json['woodType'] as String,
      dryness: json['dryness'] as String,
      availabilityDays: (json['availabilityDays'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'thumbnail': thumbnail,
      'images': images,
      'description': description,
      'category': category,
      'steres': steres,
      'logLengthCm': logLengthCm,
      'logDiameterCm': logDiameterCm,
      'woodType': woodType,
      'dryness': dryness,
      'availabilityDays': availabilityDays,
    };
  }
}
