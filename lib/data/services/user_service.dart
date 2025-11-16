import 'package:dio/dio.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/config/environment.dart';

class UserService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await _tokenStorage.getToken();
      
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await _dio.get(
        '/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      print('User data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('Error getting user: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener datos del usuario: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error getting user: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> updateCurrentUser({
    String? email,
    String? fullName,
    String? password,
  }) async {
    try {
      final token = await _tokenStorage.getToken();
      
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final Map<String, dynamic> data = {};
      if (email != null) data['email'] = email;
      if (fullName != null) data['full_name'] = fullName;
      if (password != null && password.isNotEmpty) data['password'] = password;

      print('Updating user with data: $data');

      final response = await _dio.put(
        '/users/me',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('User updated successfully: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('Error updating user: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        final errorMessage = errorData is Map && errorData['detail'] != null
            ? errorData['detail'].toString()
            : 'Datos inválidos. Verifica la información.';
        throw Exception(errorMessage);
      } else {
        throw Exception('Error al actualizar usuario: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error updating user: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}