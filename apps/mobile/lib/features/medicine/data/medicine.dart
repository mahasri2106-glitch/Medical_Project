class Medicine {
  const Medicine({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.composition,
    required this.price,
    required this.mrp,
    required this.rating,
    required this.stock,
    required this.prescriptionRequired,
    required this.uses,
    required this.sideEffects,
    required this.safetyAdvice,
    required this.manufacturer,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String brand;
  final String category;
  final String composition;
  final double price;
  final double mrp;
  final double rating;
  final int stock;
  final bool prescriptionRequired;
  final List<String> uses;
  final List<String> sideEffects;
  final String safetyAdvice;
  final String manufacturer;
  final String imageUrl;

  bool get inStock => stock > 0;

  factory Medicine.fromJson(Map<String, dynamic> json) {
    final category = (json['category'] ?? 'General').toString();

    return Medicine(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      brand: (json['brand'] ?? 'MedBill').toString(),
      category: category,
      composition: (json['composition'] ?? '').toString(),
      price: (json['price'] as num? ?? 0).toDouble(),
      mrp: (json['mrp'] as num? ?? json['price'] as num? ?? 0).toDouble(),
      rating: (json['rating'] as num? ?? 4.5).toDouble(),
      stock: (json['stock'] as num? ?? 100).toInt(),
      prescriptionRequired: json['prescriptionRequired'] == true,
      uses: _stringList(json['uses']),
      sideEffects: _stringList(json['sideEffects']),
      safetyAdvice: (json['safetyAdvice'] ?? 'Use as directed by a physician.')
          .toString(),
      manufacturer: (json['manufacturer'] ?? 'MedBill Pharmacy').toString(),
      imageUrl: (json['imageUrl'] ?? _imageForCategory(category)).toString(),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    return const [];
  }

  static String _imageForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'cold':
      case 'cold & cough':
        return 'https://images.pexels.com/photos/3683107/pexels-photo-3683107.jpeg';
      case 'fever':
      case 'pain':
      case 'fever & pain':
        return 'https://images.pexels.com/photos/139398/pexels-photo-139398.jpeg';
      case 'diabetes':
        return 'https://images.pexels.com/photos/208512/pexels-photo-208512.jpeg';
      case 'vitamins':
        return 'https://images.pexels.com/photos/7615460/pexels-photo-7615460.jpeg';
      case 'acidity':
      case 'digestion':
        return 'https://images.pexels.com/photos/4021779/pexels-photo-4021779.jpeg';
      default:
        return 'https://images.pexels.com/photos/593451/pexels-photo-593451.jpeg';
    }
  }
}
