// lib/presentation/pages/notifications/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_restaurante/data/providers/notification_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: AppColors.fondoPrimary,
        foregroundColor: AppColors.blanco,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return TextButton(
                  onPressed: provider.markAllAsRead,
                  child: const Text(
                    'Marcar todas como leídas',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Estado de conexión
              _buildConnectionStatus(provider),
              
              // Lista de notificaciones
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Recargar si es necesario
                  },
                  child: ListView.builder(
                    itemCount: provider.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = provider.notifications[index];
                      return _buildNotificationCard(notification, provider);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatus(NotificationProvider provider) {
    Color statusColor;
    String statusText;

    switch (provider.connectionStatus) {
      case 'connected':
        statusColor = Colors.green;
        statusText = 'Conectado ✓';
        break;
      case 'connecting':
        statusColor = Colors.orange;
        statusText = 'Conectando...';
        break;
      case 'error':
        statusColor = Colors.red;
        statusText = 'Error de conexión';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconectado';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: statusColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            color: statusColor,
            size: 12,
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (!provider.isConnected)
            TextButton(
              onPressed: () => provider.connectWebSocket(),
              child: const Text('Reconectar'),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    NotificationProvider provider,
  ) {
    final isRead = notification['read'] ?? false;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isRead ? Colors.white : Colors.blue[50],
      child: ListTile(
        leading: _getNotificationIcon(notification['type']),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message']),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification['timestamp']),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRead)
              Icon(
                Icons.brightness_1,
                color: AppColors.bottonSecundary,
                size: 12,
              ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                provider.removeNotification(notification['id']);
              },
            ),
          ],
        ),
        onTap: () {
          provider.markAsRead(notification['id']);
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'order_ready':
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.restaurant, color: Colors.white, size: 20),
        );
      case 'order_status_update':
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.update, color: Colors.white, size: 20),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.notifications, color: Colors.white, size: 20),
        );
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final orderId = notification['orderId'];
    if (orderId != null) {
      // Navegar a la página de detalles de la orden
      Navigator.pushNamed(
        context, 
        '/my-order',
        // Puedes pasar arguments si necesitas
      );
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} h';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay notificaciones',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Las notificaciones de tus pedidos aparecerán aquí',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (!provider.isConnected) {
                return ElevatedButton(
                  onPressed: () => provider.connectWebSocket(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bottonPrimary,
                    foregroundColor: AppColors.blanco,
                  ),
                  child: const Text('Conectar Notificaciones'),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}