import 'package:dio/dio.dart';
import 'package:flutter_restaurante/config/environment.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';

class AuthService {
  final TokenStorage _tokenStorage = TokenStorage();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  AuthService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenStorage.deleteToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: FormData.fromMap({'username': email, 'password': password}),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final data = response.data;

      if (data != null && data['access_token'] != null) {
        await _tokenStorage.saveToken(data['access_token']);
      }

      return data;
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String fullName,
    String role = 'usuario',
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          "email": email,
          "password": password,
          "full_name": fullName,
          "role": role,
        },
      );

      final data = response.data;

      if (data != null && data['access_token'] != null) {
        await _tokenStorage.saveToken(data['access_token']);
      }

      return data;
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google',
        data: {'id_token': idToken},
      );

      final data = response.data;

      if (data != null && data['access_token'] != null) {
        await _tokenStorage.saveToken(data['access_token']);
      }

      return data;
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<Map<String, dynamic>> linkGoogleAccount(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google/link',
        data: {'id_token': idToken},
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

  Future<bool> isAuthenticated() async {
    final token = await _tokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  String _handleAuthError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      switch (statusCode) {
        case 400:
          return data['detail'] ?? 'Datos inválidos';
        case 401:
          return 'Credenciales incorrectas';
        case 403:
          return 'No tienes permisos para esta acción';
        case 404:
          return 'Recurso no encontrado';
        case 409:
          return 'El usuario ya existe';
        case 422:
          return 'Datos de entrada inválidos';
        case 503:
          return 'Servicio de autenticación no disponible';
        default:
          return data['detail'] ?? 'Error del servidor';
      }
    } else {
      return 'Error de conexión: ${e.message}';
    }
  }
}
