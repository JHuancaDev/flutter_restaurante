import 'package:dio/dio.dart';
import 'package:flutter_restaurante/data/models/favorite_model.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/config/environment.dart';

class FavoriteService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
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
      
      // Debug: Imprimir la respuesta para ver la estructura
      print('Favorites response: $data');
      
      return data.map((json) => Favorite.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Error getting favorites: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else if (e.response?.statusCode == 404) {
        // Si no hay favoritos, retornar lista vacía
        return [];
      } else {
        throw Exception('Error al obtener favoritos: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error getting favorites: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Favorite> addFavorite(int productId) async {
    try {
      final token = await _tokenStorage.getToken();
      
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      // Obtener el user_id del usuario actual
      final userResponse = await _dio.get(
        '/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      final userId = userResponse.data['id'];

      // Preparar los datos para enviar
      final requestData = {
        'user_id': userId,
        'product_id': productId,
      };

      print('Adding favorite with data: $requestData');

      final response = await _dio.post(
        '/favorites/',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('Favorite added successfully: ${response.data}');
      
      return Favorite.fromJson(response.data);
    } on DioException catch (e) {
      print('Error adding favorite: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        final errorMessage = errorData is Map && errorData['detail'] != null
            ? errorData['detail'].toString()
            : 'Datos inválidos. Verifica la información.';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 422) {
        throw Exception('El producto ya está en favoritos o no existe');
      } else {
        throw Exception('Error al agregar a favoritos: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error adding favorite: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> removeFavorite(int productId) async {
    try {
      final token = await _tokenStorage.getToken();
      
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      // Obtener el user_id del usuario actual
      final userResponse = await _dio.get(
        '/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      final userId = userResponse.data['id'];

      print('Removing favorite: user_id=$userId, product_id=$productId');

      await _dio.delete(
        '/favorites/$userId/$productId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      print('Favorite removed successfully');
    } on DioException catch (e) {
      print('Error removing favorite: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else if (e.response?.statusCode == 404) {
        // El favorito ya no existe, considerar como éxito
        print('Favorite already removed');
        return;
      } else {
        throw Exception('Error al eliminar de favoritos: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error removing favorite: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> isProductInFavorites(int productId) async {
    try {
      final favorites = await getMyFavorites();
      return favorites.any((favorite) => favorite.productId == productId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
    // Método temporal para debug
  Future<void> testFavoritesConnection() async {
    try {
      final token = await _tokenStorage.getToken();
      print('Token: $token');
      
      if (token == null) {
        print('No token available');
        return;
      }

      // Probar el endpoint de favoritos
      final response = await _dio.get(
        '/favorites/me/favorites',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      print('Favorites test response: ${response.statusCode}');
      print('Favorites test data: ${response.data}');
    } catch (e) {
      print('Favorites test error: $e');
    }
  }
}