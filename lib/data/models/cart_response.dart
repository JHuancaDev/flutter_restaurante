import 'package:flutter_restaurante/data/models/cart_item.dart';

class CartResponse {
  final int id;
  final int userId;
  final double totalAmount;
  final int itemsCount;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartResponse({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.itemsCount,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      itemsCount: json['items_count'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((item) => CartItem.fromJson(item))
          .toList(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }
}