import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/cart_item.dart';

class CartService {
  static const String _fileName = "cart.json";
  List<CartItem> _cartItems = [];

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/$_fileName");
  }

  Future<void> loadCart() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final data = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(data);
        _cartItems = jsonList.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (_) {
      _cartItems = [];
    }
  }

  Future<void> saveCart() async {
    final file = await _getLocalFile();
    final jsonList = _cartItems.map((item) => item.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  List<CartItem> getCartItems() => _cartItems;

  Future<void> addToCart(CartItem item) async {
    final index = _cartItems.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _cartItems[index].quantity += item.quantity;
    } else {
      _cartItems.add(item);
    }
    await saveCart();
  }

  Future<void> removeFromCart(int productId) async {
    _cartItems.removeWhere((item) => item.id == productId);
    await saveCart();
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    await saveCart();
  }
}
