// lib/data/providers/notification_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_restaurante/data/services/websocket_service.dart';

class NotificationProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();

  List<Map<String, dynamic>> _notifications = [];
  bool _isConnected = false;
  String _connectionStatus = 'disconnected';

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;

  NotificationProvider() {
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    _webSocketService.onOrderReady = _handleOrderReady;
    _webSocketService.onOrderStatusUpdate = _handleOrderStatusUpdate;
    _webSocketService.onConnectionStatusChanged =
        _handleConnectionStatusChanged;

    connectWebSocket();
  }

  Future<void> connectWebSocket() async {
    try {
      await _webSocketService.connect();
    } catch (e) {
      print('Error en connectWebSocket: $e');
    }
  }

  void _handleOrderReady(Map<String, dynamic> data) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'type': 'order_ready',
      'title': '¡Tu orden está lista! 🎉',
      'message': data['message'] ?? 'Tu orden está lista para recoger',
      'orderId': data['order_id'],
      'timestamp': DateTime.now(),
      'read': false,
    };

    _addNotification(notification);
    _showLocalNotification(notification);
  }

  void _handleOrderStatusUpdate(Map<String, dynamic> data) {
    final statusMessages = {
      'en_preparacion': 'Tu orden está en preparación 👨‍🍳',
      'listo': '¡Tu orden está lista! 🎉',
      'entregado': 'Tu orden ha sido entregada 📦',
      'completado': 'Orden completada ✅',
    };

    final message =
        statusMessages[data['new_status']] ??
        'Estado actualizado: ${data['new_status']}';

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'type': 'order_status_update',
      'title': 'Actualización de Orden',
      'message': message,
      'orderId': data['order_id'],
      'newStatus': data['new_status'],
      'timestamp': DateTime.now(),
      'read': false,
    };

    _addNotification(notification);
    if (['listo', 'entregado', 'en_preparacion'].contains(data['new_status'])) {
      _showLocalNotification(notification);
    }
  }

  void _handleConnectionStatusChanged(String status) {
    _connectionStatus = status;
    _isConnected = status == 'connected';
    notifyListeners();
  }

  void _addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAsRead(int notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['read'] = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['read'] = true;
    }
    notifyListeners();
  }

  void removeNotification(int notificationId) {
    _notifications.removeWhere((n) => n['id'] == notificationId);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  int get unreadCount {
    return _notifications.where((n) => n['read'] == false).length;
  }

  void _showLocalNotification(Map<String, dynamic> notification) {
    _showSnackBar(notification['title'], notification['message']);
  }

  void _showSnackBar(String title, String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            _navigateToNotifications();
          },
        ),
      ),
    );
  }

  void _navigateToNotifications() {}

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }
}
