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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      stock: json['stock'],
      categoryId: json['category_id'],
      isAvailable: json['is_available'],
    );
  }
}
