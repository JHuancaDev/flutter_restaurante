import 'package:dio/dio.dart';
import 'package:flutter_restaurante/data/models/favorite_model.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/config/environment.dart';

class FavoriteService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final TokenStorage _tokenStorage = TokenStorage();

  Future<List<Favorite>> getMyFavorites() async {
    try {
      final token = await _tokenStorage.getToken();

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await _dio.get(
        '/favorites/me/favorites',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;

      return data.map((json) => Favorite.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else if (e.response?.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener favoritos: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Favorite> addFavorite(int productId) async {
    try {
      final token = await _tokenStorage.getToken();

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final userResponse = await _dio.get(
        '/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final userId = userResponse.data['id'];

      final response = await _dio.post(
        '/favorites/',
        data: {'user_id': userId, 'product_id': productId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return Favorite.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception('Sesión expirada');
      } else if (e.response?.statusCode == 400) {
        throw Exception('El producto ya está en favoritos');
      } else {
        throw Exception('Error al agregar favorito: ${e.message}');
      }
    }
  }

  Future<void> removeFavorite(int productId) async {
    try {
      final token = await _tokenStorage.getToken();

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final userResponse = await _dio.get(
        '/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final userId = userResponse.data['id'];

      await _dio.delete(
        '/favorites/$userId/$productId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else if (e.response?.statusCode == 404) {
        return;
      } else {
        throw Exception('Error al eliminar de favoritos: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> isProductInFavorites(int productId) async {
    try {
      final favorites = await getMyFavorites();
      return favorites.any((favorite) => favorite.productId == productId);
    } catch (e) {
      return false;
    }
  }

  Future<void> testFavoritesConnection() async {
    try {
      final token = await _tokenStorage.getToken();

      if (token == null) {
        return;
      }

      final response = await _dio.get(
        '/favorites/me/favorites',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {}
  }
}
