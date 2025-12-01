import 'package:dio/dio.dart';
import 'package:flutter_restaurante/data/models/product.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/config/environment.dart';

class ProductService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final TokenStorage _tokenStorage = TokenStorage();

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.get(
        '/products/',
        queryParameters: {'category_id': categoryId, 'available_only': true},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else if (e.response?.statusCode == 404) {
        throw Exception('Categoría no encontrada');
      } else {
        throw Exception('Error al obtener productos: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final token = await _tokenStorage.getToken();
      final response = await _dio.get(
        '/products/',
        queryParameters: {'available_only': true},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al obtener productos: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Product> getProductById(int productId) async {
    try {
      final token = await _tokenStorage.getToken();
      final response = await _dio.get(
        '/products/$productId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Product.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al obtener producto: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Product>> searchProducts({
    required String query,
    int? categoryId,
    bool availableOnly = true,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final token = await _tokenStorage.getToken();
      final response = await _dio.get(
        '/products/search',
        queryParameters: {
          'q': query,
          if (categoryId != null) 'category_id': categoryId,
          'available_only': availableOnly,
          'skip': skip,
          'limit': limit,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al buscar productos: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
