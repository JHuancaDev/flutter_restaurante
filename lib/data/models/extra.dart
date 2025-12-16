class Extra {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final bool isAvailable;
  final bool isFree;
  final int stock;
  final String? imageUrl;
  final DateTime createdAt;

  Extra({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    required this.isFree,
    required this.stock,
    this.imageUrl,
    required this.createdAt,
  });

  factory Extra.fromJson(Map<String, dynamic> json) {
    return Extra(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? 'condimento',
      isAvailable: json['is_available'] ?? true,
      isFree: json['is_free'] ?? false,
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'is_available': isAvailable,
      'is_free': isFree,
      'stock': stock,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Extra copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? category,
    bool? isAvailable,
    bool? isFree,
    int? stock,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Extra(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      isFree: isFree ?? this.isFree,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class OrderExtra {
  final int id;
  final int orderId;
  final int extraId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String extraName;
  final DateTime createdAt;

  OrderExtra({
    required this.id,
    required this.orderId,
    required this.extraId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.extraName,
    required this.createdAt,
  });

  factory OrderExtra.fromJson(Map<String, dynamic> json) {
    return OrderExtra(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      extraId: json['extra_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0.0).toDouble(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      extraName: json['extra_name'] ?? 'Extra',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extra_id': extraId,
      'quantity': quantity,
    };
  }
}