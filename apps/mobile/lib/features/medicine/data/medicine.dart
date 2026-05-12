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
    return Medicine(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      brand: (json['brand'] ?? 'MedBill').toString(),
      category: (json['category'] ?? 'General').toString(),
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
      imageUrl: (json['imageUrl'] ??
              _imageForId((json['id'] ?? json['_id'] ?? '').toString()))
          .toString(),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }

  static String _imageForId(String id) {
    final seed = id.isEmpty ? 'medicine' : id;
    return 'https://picsum.photos/seed/$seed/480/480';
  }
}
