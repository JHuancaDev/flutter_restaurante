import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/data/models/product.dart';
import 'package:flutter_restaurante/data/providers/ai_recommendation_provider.dart';
import 'package:flutter_restaurante/presentation/pages/products/product_detail_page.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecommendations();
    });
  }

  void _loadRecommendations() {
    final provider = context.read<AIRecommendationProvider>();
    provider.loadPersonalizedRecommendations();
    provider.loadTrendingProducts();
    provider.loadNewUserRecommendations();
  }

  void _onProductTap(Product product) {
    context.read<AIRecommendationProvider>().trackProductView(product.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () => _onProductTap(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: AppColors.fondoSecondary,
                      child: Icon(
                        Icons.fastfood,
                        color: AppColors.bottonPrimary,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                    const SizedBox(height: 8),
                    Text(
                      "S/. ${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.bottonSecundary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationSection({
    required String title,
    required String subtitle,
    required List<Product> products,
    required IconData icon,
    required Color color,
  }) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...products.map((product) => _buildProductCard(product)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTabContent(List<Product> products, String emptyMessage) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        _buildRecommendationSection(
          title: 'Recomendaciones',
          subtitle: 'Basado en tus preferencias',
          products: products,
          icon: Icons.auto_awesome,
          color: Colors.purple,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendaciones para ti'),
        backgroundColor: AppColors.fondoPrimary,
        foregroundColor: AppColors.blanco,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Para ti', icon: Icon(Icons.person)),
            Tab(text: 'Trending', icon: Icon(Icons.trending_up)),
            Tab(text: 'Nuevos', icon: Icon(Icons.new_releases)),
          ],
        ),
      ),
      body: Consumer<AIRecommendationProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () =>
                          provider.loadPersonalizedRecommendations(),
                      child: _buildTabContent(
                        provider.personalizedRecommendations,
                        'No hay recomendaciones personalizadas\nSigue explorando productos para mejorar tus recomendaciones',
                      ),
                    ),
              RefreshIndicator(
                onRefresh: () => provider.loadTrendingProducts(),
                child: _buildTabContent(
                  provider.trendingProducts,
                  'No hay productos trending en este momento',
                ),
              ),
              RefreshIndicator(
                onRefresh: () => provider.loadNewUserRecommendations(),
                child: _buildTabContent(
                  provider.newUserRecommendations,
                  'No hay recomendaciones disponibles',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
