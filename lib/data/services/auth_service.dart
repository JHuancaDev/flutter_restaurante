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
    // Interceptor para incluir token automáticamente
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  // 🔐 LOGIN
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: FormData.fromMap({
          'username': email, // FastAPI usa "username"
          'password': password,
        }),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final data = response.data;

      // Guarda el token si existe
      if (data != null && data['access_token'] != null) {
        await _tokenStorage.saveToken(data['access_token']);
      }

      return data;
    } on DioException catch (e) {
      print('Error en login: ${e.response?.data}');
      return null;
    }
  }

  // 🧾 REGISTER
  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
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

      // Si la API devuelve token al registrarse, se guarda también
      if (data != null && data['access_token'] != null) {
        await _tokenStorage.saveToken(data['access_token']);
      }

      return data;
    } on DioException catch (e) {
      print("Error en register: ${e.response?.data ?? e.message}");
      return null;
    }
  }

  // 🔁 RESET PASSWORD
  Future<bool> resetPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error en reset password: ${e.response?.data}');
      return false;
    }
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

    // 🔐 LOGIN CON GOOGLE
  Future<Map<String, dynamic>?> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google',
        data: {
          'id_token': idToken,
        },
      );

      final data = response.data;

      // Guarda el token si existe
      if (data != null && data['access_token'] != null) {
        await _tokenStorage.saveToken(data['access_token']);
      }

      return data;
    } on DioException catch (e) {
      print('Error en login con Google: ${e.response?.data}');
      return null;
    }
  }

  // 🔗 VINCULAR CUENTA CON GOOGLE
  Future<String?> linkGoogleAccount(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google/link',
        data: {
          'id_token': idToken,
        },
      );

      return response.data;
    } on DioException catch (e) {
      print('Error al vincular cuenta Google: ${e.response?.data}');
      return null;
    }
  }

}
