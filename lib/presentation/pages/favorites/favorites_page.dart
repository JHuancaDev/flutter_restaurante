import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/data/models/favorite_model.dart';
import 'package:flutter_restaurante/data/services/favorite_service.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteService _favoriteService = FavoriteService();
  final TokenStorage _tokenStorage = TokenStorage();
  late Future<List<Favorite>> _favoritesFuture;
  List<Favorite> _favorites = [];

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavorites();
  }

  // En el método _loadFavorites, agrega:
  Future<List<Favorite>> _loadFavorites() async {
    try {
      // Probar conexión primero
      await _favoriteService.testFavoritesConnection();

      final favorites = await _favoriteService.getMyFavorites();
      _favorites = favorites;
      return favorites;
    } catch (e) {
      print('Error loading favorites: $e');
      throw e;
    }
  }

  Future<void> _removeFavorite(Favorite favorite) async {
    try {
      await _favoriteService.removeFavorite(favorite.productId);

      setState(() {
        _favorites.removeWhere((f) => f.id == favorite.id);
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.product.name} eliminado de favoritos'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showRemoveDialog(Favorite favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar de favoritos'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${favorite.product.name}" de tus favoritos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFavorite(favorite);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bottonSecundary,
              foregroundColor: AppColors.blanco,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _handleSessionExpired() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        ),
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

  Widget _buildFavoriteItem(Favorite favorite) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            favorite.product.imageUrl.isNotEmpty
                ? favorite.product.imageUrl
                : 'https://via.placeholder.com/80x80?text=No+Image',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: AppColors.fondoSecondary,
                child: const Icon(
                  Icons.fastfood,
                  color: AppColors.bottonPrimary,
                ),
              );
            },
          ),
        ),
        title: Text(
          favorite.product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              favorite.product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'S/. ${favorite.product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.bottonPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Agregado: ${_formatDate(favorite.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: AppColors.bottonSecundary),
          onPressed: () => _showRemoveDialog(favorite),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        backgroundColor: AppColors.bottonPrimary,
        foregroundColor: AppColors.blanco,
      ),
      body: FutureBuilder<List<Favorite>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar favoritos',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.red),
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
                          _favoritesFuture = _loadFavorites();
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

          final favorites = snapshot.data!;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes favoritos',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Agrega productos a tus favoritos para verlos aquí',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navegar a la página de productos
                      // Navigator.push(...);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bottonPrimary,
                      foregroundColor: AppColors.blanco,
                    ),
                    child: const Text('Explorar Productos'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _favoritesFuture = _loadFavorites();
              });
            },
            child: ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return _buildFavoriteItem(favorite);
              },
            ),
          );
        },
      ),
    );
  }
}
