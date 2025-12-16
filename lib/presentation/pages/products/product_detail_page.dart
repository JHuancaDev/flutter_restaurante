import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/data/models/product.dart';
import 'package:flutter_restaurante/data/models/review.dart';
import 'package:flutter_restaurante/data/services/cart_service.dart';
import 'package:flutter_restaurante/data/services/favorite_service.dart';
import 'package:flutter_restaurante/data/services/review_service.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/presentation/pages/widgets/add_review_dialog.dart';
import 'package:flutter_restaurante/presentation/pages/widgets/rating_stars.dart';
import 'package:flutter_restaurante/presentation/pages/widgets/review_card.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final CartService _cartService = CartService();
  final FavoriteService _favoriteService = FavoriteService();
  final ReviewService _reviewService = ReviewService();
  final TokenStorage _tokenStorage = TokenStorage();

  late Product product;
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;

  // Variables para reseñas
  List<Review> _reviews = [];
  ReviewStats _stats = ReviewStats(totalReviews: 0, averageRating: 0);
  bool _isLoadingReviews = false;
  bool _hasReviewError = false;

  // Variables para IA
  bool _isLoadingSimilar = false;
  List<Product> _similarProducts = [];

  @override
  void initState() {
    super.initState();
    product = widget.product;
    _checkFavoriteStatus();
    _loadReviews();

    // Tracking de vista de producto - después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar productos similares después de un breve delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _loadSimilarProducts();
      });
    });
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      setState(() {
        _isLoadingFavorite = true;
      });

      final isFavorite = await _favoriteService.isProductInFavorites(
        product.id,
      );
      setState(() {
        _isFavorite = isFavorite;
        _isLoadingFavorite = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFavorite = false;
      });
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _loadReviews() async {
    try {
      setState(() {
        _isLoadingReviews = true;
        _hasReviewError = false;
      });

      final reviews = await _reviewService.getProductReviews(product.id);
      final stats = await _reviewService.getProductStats(product.id);

      setState(() {
        _reviews = reviews;
        _stats = stats;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReviews = false;
        _hasReviewError = true;
      });
      print('Error loading reviews: $e');
    }
  }

  Future<void> _loadSimilarProducts() async {
    try {
      setState(() {
        _isLoadingSimilar = true;
      });

      // Esperar un momento para que se actualice el provider
      await Future.delayed(const Duration(milliseconds: 100));

      setState(() {
        _isLoadingSimilar = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSimilar = false;
      });
      print('Error loading similar products: $e');
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
      print('Error toggling favorite: $e');
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
      await _cartService.addToCart(product.id, 1);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Producto agregado al carrito ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding to cart: $e');
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

  Future<void> _showAddReviewDialog() async {
    final result = await showDialog<ReviewCreate>(
      context: context,
      builder: (context) => AddReviewDialog(productId: product.id),
    );

    if (result != null && context.mounted) {
      try {
        await _reviewService.createReview(result);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reseña enviada correctamente ✅'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Recargar reseñas
        _loadReviews();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar reseña: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
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


  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Para pantallas pequeñas, usar columna en lugar de fila
          if (MediaQuery.of(context).size.width < 400)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingInfo(),
                const SizedBox(height: 12),
                _buildReviewButton(),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildRatingInfo()),
                const SizedBox(width: 12),
                _buildReviewButton(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRatingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calificación del producto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            RatingStars(rating: _stats.averageRating, size: 20),
            const SizedBox(width: 8),
            Text(
              '${_stats.averageRating.toStringAsFixed(1)}/5.0',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${_stats.totalReviews} ${_stats.totalReviews == 1 ? 'reseña' : 'reseñas'}',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildReviewButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: _showAddReviewDialog,
          icon: const Icon(Icons.rate_review, size: 16),
          label: const Text('Escribir reseña'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bottonPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    if (_isLoadingReviews) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.bottonPrimary),
        ),
      );
    }

    if (_hasReviewError) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              'Error al cargar reseñas',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadReviews,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.reviews, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              'Aún no hay reseñas',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            const Text(
              'Sé el primero en opinar sobre este producto',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.reviews, color: AppColors.bottonPrimary),
              const SizedBox(width: 8),
              Text(
                'Reseñas (${_reviews.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _reviews.length,
          itemBuilder: (context, index) {
            return ReviewCard(
              review: _reviews[index],
              onDelete: () async {
                try {
                  await _reviewService.deleteReview(_reviews[index].id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reseña eliminada correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  _loadReviews();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al eliminar reseña: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          },
        ),
      ],
    );
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
                    color: _isFavorite
                        ? AppColors.bottonSecundary
                        : AppColors.blanco,
                  ),
            onPressed: _isLoadingFavorite ? null : _toggleFavorite,
            tooltip: _isFavorite
                ? 'Quitar de favoritos'
                : 'Agregar a favoritos',
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
              child: Stack(
                children: [
                  Image.network(
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
                ],
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          side: const BorderSide(
                            color: AppColors.bottonSecundary,
                          ),
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
                                    AppColors.bottonSecundary,
                                  ),
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

            // Sección de reseñas
            _buildRatingSection(),
            _buildReviewsList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
