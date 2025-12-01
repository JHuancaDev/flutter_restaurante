class Table {
  final int id;
  final int number;
  final int capacity;
  final double positionX;
  final double positionY;
  final bool isAvailable;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Table({
    required this.id,
    required this.number,
    required this.capacity,
    required this.positionX,
    required this.positionY,
    required this.isAvailable,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'] ?? 0,
      number: json['number'] ?? 0,
      capacity: json['capacity'] ?? 0,
      positionX: (json['position_x'] ?? 0.0).toDouble(),
      positionY: (json['position_y'] ?? 0.0).toDouble(),
      isAvailable: json['is_available'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }
}

class TableWithStatus {
  final int id;
  final int number;
  final int capacity;
  final double positionX;
  final double positionY;
  final bool isAvailable;
  final List<Map<String, dynamic>> activeOrders;
  final int activeOrdersCount;

  TableWithStatus({
    required this.id,
    required this.number,
    required this.capacity,
    required this.positionX,
    required this.positionY,
    required this.isAvailable,
    required this.activeOrders,
    required this.activeOrdersCount,
  });

  factory TableWithStatus.fromJson(Map<String, dynamic> json) {
    return TableWithStatus(
      id: json['id'] ?? 0,
      number: json['number'] ?? 0,
      capacity: json['capacity'] ?? 0,
      positionX: (json['position_x'] ?? 0.0).toDouble(),
      positionY: (json['position_y'] ?? 0.0).toDouble(),
      isAvailable: json['is_available'] ?? false,
      activeOrders: List<Map<String, dynamic>>.from(json['active_orders'] ?? []),
      activeOrdersCount: json['active_orders_count'] ?? 0,
    );
  }
}