import 'package:dio/dio.dart';
import 'package:flutter_restaurante/config/environment.dart';
import 'package:flutter_restaurante/data/models/product.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';

class AIRecommendationService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final TokenStorage _tokenStorage = TokenStorage();

  Future<List<Product>> getAIRecommendations({
    Map<String, dynamic> preferences = const {},
    int maxResults = 10,
  }) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.post(
        '/ai/recommendations',
        queryParameters: {'max_results': maxResults},
        data: preferences,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener recomendaciones: $e');
    }
  }

  Future<List<Product>> getPersonalizedRecommendations({
    int maxResults = 10,
  }) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.get(
        '/ai/personalized',
        queryParameters: {'max_results': maxResults},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener recomendaciones personalizadas: $e');
    }
  }

  Future<List<Product>> getNewUserRecommendations({int maxResults = 10}) async {
    try {
      final response = await _dio.get(
        '/ai/for-new-user',
        queryParameters: {'max_results': maxResults},
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener recomendaciones: $e');
    }
  }

  Future<List<Product>> getTrendingProducts({int limit = 5}) async {
    try {
      final response = await _dio.get(
        '/ai/trending',
        queryParameters: {'limit': limit},
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener productos populares: $e');
    }
  }
}
