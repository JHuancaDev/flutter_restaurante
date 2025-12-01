import 'package:dio/dio.dart';
import 'package:flutter_restaurante/data/models/order.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/config/environment.dart';

class OrderService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final TokenStorage _tokenStorage = TokenStorage();

  Future<List<Order>> getMyOrders({int skip = 0, int limit = 100}) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.get(
        '/orders/my-orders',
        queryParameters: {'skip': skip, 'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al obtener órdenes: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Order> getOrderById(int orderId) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.get(
        '/orders/$orderId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Order.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else if (e.response?.statusCode == 403) {
        throw Exception('No tienes permisos para ver esta orden');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Orden no encontrada');
      } else {
        throw Exception('Error al obtener orden: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Order> createOrder(Order order) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.post(
        '/orders/',
        data: order.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Order.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        final errorMessage = errorData is Map && errorData['detail'] != null
            ? errorData['detail'].toString()
            : 'Error al crear la orden';
        throw Exception(errorMessage);
      } else {
        throw Exception('Error al crear orden: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
