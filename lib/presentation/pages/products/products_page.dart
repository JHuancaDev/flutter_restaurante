import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/data/models/product.dart';
import 'package:flutter_restaurante/data/services/product_service.dart';
import 'package:flutter_restaurante/data/services/favorite_service.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late int categoryId;
  late String categoryName;
  final ProductService _productService = ProductService();
  final FavoriteService _favoriteService = FavoriteService();
  final TokenStorage _tokenStorage = TokenStorage();
  late Future<List<Product>> _products;
  Map<int, bool> _favoriteStatus = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    categoryId = args['categoryId'];
    categoryName = args['categoryName'];
    _products = _loadProducts();
  }

  Future<List<Product>> _loadProducts() async {
    try {
      final products = await _productService.getProductsByCategory(categoryId);
      
      // Verificar estado de favoritos para cada producto
      for (var product in products) {
        final isFavorite = await _favoriteService.isProductInFavorites(product.id);
        _favoriteStatus[product.id] = isFavorite;
      }
      
      return products;
    } catch (e) {
      throw e;
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    try {
      final isCurrentlyFavorite = _favoriteStatus[product.id] ?? false;
      
      if (isCurrentlyFavorite) {
        await _favoriteService.removeFavorite(product.id);
        setState(() {
          _favoriteStatus[product.id] = false;
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
          _favoriteStatus[product.id] = true;
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
    }
  }

  void _handleSessionExpired() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sesión expirada. Por favor, inicia sesión nuevamente.'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            _logout();
          },
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _tokenStorage.deleteToken();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildProductCard(Product product) {
    final isFavorite = _favoriteStatus[product.id] ?? false;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/product-detail',
            arguments: product,
          );
        },
        child: Stack(
          children: [
            Row(
              children: [
                // Imagen del producto
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "S/. ${product.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.bottonSecundary,
                                fontSize: 16,
                              ),
                            ),
                            if (product.stock <= 5)
                              Text(
                                "Stock: ${product.stock}",
                                style: TextStyle(
                                  color: product.stock == 0 
                                      ? Colors.red 
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Botón de favorito
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.bottonSecundary : Colors.grey,
                  size: 24,
                ),
                onPressed: () {
                  _toggleFavorite(product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Productos - $categoryName"),
        backgroundColor: AppColors.bottonPrimary,
        foregroundColor: AppColors.blanco,
      ),
      body: FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.bottonPrimary),
            );
          }

          if (snapshot.hasError) {
            final error = snapshot.error.toString();
            
            if (error.contains('Sesión expirada')) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleSessionExpired();
              });
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar productos',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _products = _loadProducts();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bottonPrimary,
                        foregroundColor: AppColors.blanco,
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fastfood,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay productos disponibles',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No encontramos productos en esta categoría',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _products = _loadProducts();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product);
              },
            ),
          );
        },
      ),
    );
  }
}