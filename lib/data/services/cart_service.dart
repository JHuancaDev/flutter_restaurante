import 'package:dio/dio.dart';
import 'package:flutter_restaurante/data/models/cart_response.dart';
import 'package:flutter_restaurante/data/models/order.dart';
import 'package:flutter_restaurante/data/models/sale.dart';
import 'package:flutter_restaurante/data/services/sale_service.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/config/environment.dart';
import 'package:flutter_restaurante/data/models/table.dart';

class CartService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final TokenStorage _tokenStorage = TokenStorage();
  final SaleService _saleService = SaleService();

  Future<List<dynamic>> getAvailableTables({int? capacity}) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.get(
        '/tables/available',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;

      if (capacity != null) {
        final filteredTables = data.where((table) {
          final tableCapacity = table['capacity'] is int
              ? table['capacity']
              : int.tryParse(table['capacity'].toString());
          return tableCapacity != null && tableCapacity >= capacity;
        }).toList();
        return filteredTables;
      }

      return data;
    } on DioException catch (e) {
      throw Exception('Error al obtener mesas disponibles: ${e.message}');
    }
  }

  Future<List<dynamic>> getAllAvailableTables() async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.get(
        '/tables/available',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data;
    } on DioException catch (e) {
      return [];
    }
  }

  Future<List<TableWithStatus>> getTablesWithStatus() async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.get(
        '/tables/with-status',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => TableWithStatus.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error al obtener estado de mesas: ${e.message}');
    }
  }

  Future<Order> checkoutWithTable(Map<String, dynamic> orderData) async {
    try {
      final token = await _tokenStorage.getToken();
      if (orderData['table_id'] != null) {
        if (orderData['table_id'] is String) {
          orderData['table_id'] = int.tryParse(orderData['table_id']);
        } else if (orderData['table_id'] is int) {
        } else {
          orderData['table_id'] = int.tryParse(
            orderData['table_id'].toString(),
          );
        }
      }

      final response = await _dio.post(
        '/cart/checkout-with-table',
        data: orderData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return Order.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else if (e.response?.statusCode == 500) {
        throw Exception(
          'Error interno del servidor. Por favor, contacta al administrador.',
        );
      } else {
        final errorMessage = e.response?.data?['detail'] ?? e.message;
        throw Exception('Error al procesar pedido: $errorMessage');
      }
    }
  }

  Future<CartResponse> getCart() async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.get(
        '/cart/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return CartResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al obtener carrito: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<CartResponse> addToCart(
    int productId,
    int quantity, {
    String specialInstructions = '',
  }) async {
    try {
      final token = await _tokenStorage.getToken();

      final requestData = {
        'product_id': productId,
        'quantity': quantity,
        'special_instructions': specialInstructions,
      };

      final response = await _dio.post(
        '/cart/items',
        data: requestData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return CartResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else if (e.response?.statusCode == 422) {
        return await _updateExistingItem(productId, quantity);
      } else {
        throw Exception('Error al agregar al carrito: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<CartResponse> _updateExistingItem(int productId, int quantity) async {
    try {
      final cart = await getCart();
      final existingItem = cart.items.firstWhere(
        (item) => item.productId == productId,
        orElse: () => throw Exception('Producto no encontrado en carrito'),
      );

      return await updateQuantity(
        existingItem.id,
        existingItem.quantity + quantity,
      );
    } catch (e) {
      throw Exception('Error al actualizar item existente: $e');
    }
  }

  Future<CartResponse> updateQuantity(int itemId, int quantity) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.put(
        '/cart/items/$itemId',
        data: {'quantity': quantity, 'special_instructions': ''},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return CartResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al actualizar cantidad: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<CartResponse> removeFromCart(int itemId) async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.delete(
        '/cart/items/$itemId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return CartResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al eliminar del carrito: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<CartResponse> clearCart() async {
    try {
      final token = await _tokenStorage.getToken();

      final response = await _dio.delete(
        '/cart/clear',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return CartResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al vaciar carrito: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Sale> checkout({
    required String paymentMethod,
    String notes = '',
  }) async {
    try {
      final cart = await getCart();

      if (cart.items.isEmpty) {
        throw Exception('El carrito está vacío');
      }

      final saleItems = cart.items.map((item) {
        return {
          'product_id': item.productId,
          'quantity': item.quantity,
          'unit_price': item.productPrice,
        };
      }).toList();

      final sale = await _saleService.createSale(
        paymentMethod: paymentMethod,
        notes: notes,
        items: saleItems,
      );

      await clearCart();

      return sale;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al realizar checkout: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<int> getTotalItemsCount() async {
    try {
      final cart = await getCart();
      return cart.items.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> getCartSummary() async {
    try {
      final token = await _tokenStorage.getToken();
      final response = await _dio.get(
        '/cart/summary',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al obtener resumen: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> checkoutOld() async {
    try {
      final token = await _tokenStorage.getToken();
      await _dio.post(
        '/cart/checkout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception('Error al realizar checkout: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
