// lib/data/models/product.dart
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final int categoryId;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.categoryId,
    required this.isAvailable,

  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0 as num).toDouble(),
      imageUrl: json['image_url'] ?? '',
      stock: json['stock'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      isAvailable: json['is_available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'stock': stock,
      'category_id': categoryId,
      'is_available': isAvailable,
    };
  }

  // Método para clonar con nuevos valores
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    int? stock,
    int? categoryId,
    bool? isAvailable,
    bool? isSpicy,
    bool? isVegan,
    bool? isGlutenFree,
    int? preparationTime,
    int? calories,
    double? popularityScore,
    double? trendingScore,
    double? recommendationScore,
    List<String>? recommendationModels,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

}
