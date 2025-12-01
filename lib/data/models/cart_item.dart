class CartItem {
  final int id;
  final int productId;
  final int quantity;
  final String specialInstructions;
  final int cartId;
  final String productName;
  final double productPrice;
  final String productImage;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.specialInstructions,
    required this.cartId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'special_instructions': specialInstructions,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      specialInstructions: json['special_instructions'] ?? '',
      cartId: json['cart_id'] ?? 0,
      productName: json['product_name'] ?? 'Producto',
      productPrice: (json['product_price'] ?? 0.0).toDouble(),
      productImage: json['product_image'] ?? '',
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  String get name => productName;
  double get price => productPrice;
  String get imageUrl => productImage;

  CartItem copyWith({
    int? quantity,
    String? specialInstructions,
  }) {
    return CartItem(
      id: id,
      productId: productId,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      cartId: cartId,
      productName: productName,
      productPrice: productPrice,
      productImage: productImage,
      subtotal: productPrice * (quantity ?? this.quantity),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}