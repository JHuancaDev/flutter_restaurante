// lib/data/services/websocket_service.dart - VERSIÓN CORREGIDA
import 'dart:convert';
import 'dart:async';
import 'package:flutter_restaurante/data/services/user_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final TokenStorage _tokenStorage = TokenStorage();
  final UserService _userService = UserService();
  bool _isConnected = false;
  final List<Function(Map<String, dynamic>)> _listeners = [];
  Timer? _pingTimer;

  Function(Map<String, dynamic>)? onOrderReady;
  Function(Map<String, dynamic>)? onOrderStatusUpdate;
  Function(String)? onConnectionStatusChanged;

  Future<void> connect() async {
    try {
      if (_isConnected) {
        return;
      }

      final token = await _tokenStorage.getToken();
      if (token == null) {
        _updateConnectionStatus('error');
        return;
      }

      final userId = await _getUserId();
      if (userId == null) {
        _updateConnectionStatus('error');
        return;
      }

      final wsUrl =
          'ws://192.168.101.12:8000/ws/client?user_id=$userId&token=$token';

      _updateConnectionStatus('connecting');

      try {
        _channel = IOWebSocketChannel.connect(wsUrl);

        _channel!.stream.listen(
          _handleMessage,
          onError: _handleError,
          onDone: _handleDisconnect,
          cancelOnError: false,
        );

        _isConnected = true;
        _updateConnectionStatus('connected');
        _startPingTimer();
      } catch (e) {
        _handleError(e);
      }
    } catch (e) {
      _isConnected = false;
      _updateConnectionStatus('error');
      _scheduleReconnect();
    }
  }

  Future<int?> _getUserId() async {
    try {
      final userData = await _userService.getCurrentUser();
      final userId = userData['id'] as int?;

      if (userId != null) {
        return userId;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void _handleMessage(dynamic message) {
    try {
      if (message is String) {
        if (message == 'pong') {
          return;
        }

        try {
          final Map<String, dynamic> data = json.decode(message);
          final String type = data['type'];

          switch (type) {
            case 'connection_established':
              break;

            case 'order_ready':
              onOrderReady?.call(data);
              _notifyListeners(data);
              break;

            case 'order_status_update':
              onOrderStatusUpdate?.call(data);
              _notifyListeners(data);
              break;

            default:
          }
        } catch (e) {}
      }
    } catch (e) {}
  }

  void _handleError(dynamic error) {
    _isConnected = false;
    _updateConnectionStatus('error');
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    _isConnected = false;
    _updateConnectionStatus('disconnected');
    _stopPingTimer();

    _scheduleReconnect();
  }

  void _updateConnectionStatus(String status) {
    _isConnected = status == 'connected';
    onConnectionStatusChanged?.call(status);
  }

  void _scheduleReconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  void _startPingTimer() {
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        sendPing();
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void sendPing() {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(json.encode({'type': 'ping'}));
      } catch (e) {
        _handleError(e);
      }
    }
  }

  void addListener(Function(Map<String, dynamic>) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(Map<String, dynamic>) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners(Map<String, dynamic> data) {
    for (final listener in _listeners) {
      try {
        listener(data);
      } catch (e) {}
    }
  }

  Future<void> disconnect() async {
    try {
      _stopPingTimer();
      await _channel?.sink.close();
      _isConnected = false;
      _updateConnectionStatus('disconnected');
    } catch (e) {}
  }

  bool get isConnected => _isConnected;
}
