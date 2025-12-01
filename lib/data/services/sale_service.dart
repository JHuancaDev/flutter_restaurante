import 'package:dio/dio.dart';
import 'package:flutter_restaurante/data/models/sale.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/config/environment.dart';

class SaleService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Sale> createSale({
    required String paymentMethod,
    required String notes,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.post(
        '/sales/',
        data: {'payment_method': paymentMethod, 'notes': notes, 'items': items},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Sale.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al crear venta: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Sale>> getMySales({int skip = 0, int limit = 100}) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.get(
        '/sales/my-sales',
        queryParameters: {'skip': skip, 'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Sale.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al obtener ventas: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Sale> getSaleById(int saleId) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.get(
        '/sales/$saleId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Sale.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al obtener venta: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Sale> updateSaleStatus(int saleId, String status) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.put(
        '/sales/$saleId/status',
        queryParameters: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Sale.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al actualizar estado: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
