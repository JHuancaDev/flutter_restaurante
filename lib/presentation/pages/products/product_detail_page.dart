import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/data/models/cart_item.dart';
import 'package:flutter_restaurante/data/models/product.dart';
import 'package:flutter_restaurante/data/services/cart_service.dart';
import 'package:flutter_restaurante/data/services/favorite_service.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final CartService _cartService = CartService();
  final FavoriteService _favoriteService = FavoriteService();
  final TokenStorage _tokenStorage = TokenStorage();
  late Product product;
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    product = ModalRoute.of(context)!.settings.arguments as Product;
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      setState(() {
        _isLoadingFavorite = true;
      });
      
      final isFavorite = await _favoriteService.isProductInFavorites(product.id);
      setState(() {
        _isFavorite = isFavorite;
        _isLoadingFavorite = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      setState(() {
        _isLoadingFavorite = true;
      });

      if (_isFavorite) {
        await _favoriteService.removeFavorite(product.id);
        setState(() {
          _isFavorite = false;
        });
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} eliminado de favoritos'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await _favoriteService.addFavorite(product.id);
        setState(() {
          _isFavorite = true;
        });
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} agregado a favoritos ❤️'),
              backgroundColor: AppColors.bottonSecundary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingFavorite = false;
      });
    }
  }

  Future<void> _addToCart() async {
    try {
      await _cartService.loadCart();

      final cartItem = CartItem(
        id: product.id,
        name: product.name,
        price: product.price,
        quantity: 1,
        imageUrl: product.imageUrl,
      );

      await _cartService.addToCart(cartItem);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Producto agregado al carrito ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al agregar al carrito: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStockIndicator() {
    if (product.stock == 0) {
      return Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 4),
          Text(
            "Agotado",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (product.stock <= 5) {
      return Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
          const SizedBox(width: 4),
          Text(
            "Últimas ${product.stock} unidades",
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 4),
          Text(
            "Stock disponible: ${product.stock}",
            style: const TextStyle(color: Colors.green),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: AppColors.bottonPrimary,
        foregroundColor: AppColors.blanco,
        actions: [
          IconButton(
            icon: _isLoadingFavorite
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? AppColors.bottonSecundary : AppColors.blanco,
                  ),
            onPressed: _isLoadingFavorite ? null : _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.fondoSecondary,
                    child: const Icon(
                      Icons.fastfood,
                      size: 80,
                      color: AppColors.bottonPrimary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Información del producto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Precio
                  Text(
                    "S/. ${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: AppColors.bottonSecundary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Estado del stock
                  _buildStockIndicator(),
                  const SizedBox(height: 12),

                  // Descripción
                  const Text(
                    "Descripción:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Botón Agregar al carrito
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: product.stock > 0 ? _addToCart : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: product.stock > 0 
                            ? AppColors.bottonPrimary 
                            : Colors.grey,
                        foregroundColor: AppColors.blanco,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        product.stock > 0 
                            ? "Agregar al carrito" 
                            : "Producto agotado",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botón Favorito
                  if (!_isFavorite)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoadingFavorite ? null : _toggleFavorite,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.bottonSecundary,
                          side: const BorderSide(color: AppColors.bottonSecundary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoadingFavorite
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.bottonSecundary),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.favorite_border),
                                  SizedBox(width: 8),
                                  Text(
                                    "Agregar a favoritos",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}