
import 'package:flutter_restaurante/data/models/sale_item.dart';

class Sale {
  final int id;
  final int userId;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final String notes;
  final DateTime createdAt;
  final List<SaleItem> items;

  Sale({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.notes,
    required this.createdAt,
    required this.items,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'cash',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      items: (json['items'] as List? ?? [])
          .map((item) => SaleItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_method': paymentMethod,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}