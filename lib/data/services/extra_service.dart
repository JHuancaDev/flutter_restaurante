import 'package:dio/dio.dart';
import 'package:flutter_restaurante/data/models/extra.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/config/environment.dart';

class ExtraService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final TokenStorage _tokenStorage = TokenStorage();

  Future<List<Extra>> getExtras({
    String? category,
    bool freeOnly = false,
  }) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.get(
        '/extras/',
        queryParameters: {
          'category': category,
          'free_only': freeOnly,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Extra.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener extras: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<OrderExtra>> addExtrasToOrder(
    int orderId,
    List<Map<String, dynamic>> extras,
  ) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.post(
        '/extras/order/$orderId/extras',
        data: extras,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => OrderExtra.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data?['detail'] ?? 'Error al añadir extras');
      } else {
        throw Exception('Error al añadir extras: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<OrderExtra>> getOrderExtras(int orderId) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.get(
        '/extras/order/$orderId/extras',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => OrderExtra.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener extras de la orden: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> removeExtraFromOrder(int orderExtraId) async {
    try {
      final token = await _tokenStorage.getToken();

      await _dio.delete(
        '/extras/order-extra/$orderExtraId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al eliminar extra: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}