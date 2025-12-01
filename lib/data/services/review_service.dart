import 'package:dio/dio.dart';
import 'package:flutter_restaurante/data/models/review.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/config/environment.dart';

class ReviewService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final TokenStorage _tokenStorage = TokenStorage();

  Future<List<Review>> getProductReviews(int productId) async {
    try {
      final token = await _tokenStorage.getToken();
      final response = await _dio.get(
        '/reviews/',
        queryParameters: {'product_id': productId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Review.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al obtener reseñas: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<ReviewStats> getProductStats(int productId) async {
    try {
      final token = await _tokenStorage.getToken();
      final response = await _dio.get(
        '/reviews/product/$productId/stats',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return ReviewStats.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al obtener estadísticas: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Review> createReview(ReviewCreate review) async {
    try {
      final token = await _tokenStorage.getToken();
      final response = await _dio.post(
        '/reviews/',
        data: review.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Review.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Error al crear reseña');
      } else {
        throw Exception('Error al crear reseña: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Review>> getMyReviews() async {
    try {
      final token = await _tokenStorage.getToken();
      final response = await _dio.get(
        '/reviews/user/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Review.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al obtener mis reseñas: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Review> updateReview(int reviewId, ReviewUpdate review) async {
    try {
      final token = await _tokenStorage.getToken();
      final response = await _dio.put(
        '/reviews/$reviewId',
        data: review.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Review.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else if (e.response?.statusCode == 403) {
        throw Exception('No tienes permisos para editar esta reseña');
      } else {
        throw Exception('Error al actualizar reseña: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      final token = await _tokenStorage.getToken();
      await _dio.delete(
        '/reviews/$reviewId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else if (e.response?.statusCode == 403) {
        throw Exception('No tienes permisos para eliminar esta reseña');
      } else {
        throw Exception('Error al eliminar reseña: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
