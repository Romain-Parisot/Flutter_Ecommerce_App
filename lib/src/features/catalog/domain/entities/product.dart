class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.images,
    required this.description,
    required this.category,
    required this.steres,
    required this.logLengthCm,
    required this.logDiameterCm,
    required this.woodType,
    required this.dryness,
    required this.availabilityDays,
  });

  final String id;
  final String title;
  final double price;
  final String thumbnail;
  final List<String> images;
  final String description;
  final String category;
  final double steres;
  final double logLengthCm;
  final double logDiameterCm;
  final String woodType;
  final String dryness;
  final int availabilityDays;
}
