class Order {
  final int id;
  final int userId;
  final String orderType;
  final int? tableId;
  final String status;
  final String? specialInstructions;
  final String? deliveryAddress;
  final double totalAmount;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
  final int? tableNumber;
  final int? tableCapacity;
  final String userName;

  Order({
    required this.id,
    required this.userId,
    required this.orderType,
    this.tableId,
    required this.status,
    this.specialInstructions,
    this.deliveryAddress,
    required this.totalAmount,
    required this.isPaid,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.tableNumber,
    this.tableCapacity,
    required this.userName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      orderType: json['order_type'] ?? 'dine_in',
      tableId: json['table_id'],
      status: json['status'] ?? 'recibido',
      specialInstructions: json['special_instructions'],
      deliveryAddress: json['delivery_address'],
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      isPaid: json['is_paid'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      tableNumber: json['table_number'],
      tableCapacity: json['table_capacity'],
      userName: json['user_name'] ?? 'Usuario',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_type': orderType,
      'table_id': tableId,
      'delivery_address': deliveryAddress,
      'special_instructions': specialInstructions,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final int id;
  final int productId;
  final int quantity;
  final String? specialInstructions;
  final double unitPrice;
  final double subtotal;
  final String productName;
  final String? productImage;

  OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    this.specialInstructions,
    required this.unitPrice,
    required this.subtotal,
    required this.productName,
    this.productImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      specialInstructions: json['special_instructions'],
      unitPrice: (json['unit_price'] ?? 0.0).toDouble(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      productName: json['product_name'] ?? 'Producto',
      productImage: json['product_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'special_instructions': specialInstructions,
    };
  }
}
