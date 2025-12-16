// lib/presentation/pages/widgets/smart_product_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/data/models/product.dart';
import 'package:flutter_restaurante/presentation/pages/products/product_detail_page.dart';

class SmartProductCard extends StatelessWidget {
  final Product product;
  final String? recommendationBadge;
  final VoidCallback? onTap;
  final bool showFavoriteButton;

  const SmartProductCard({
    super.key,
    required this.product,
    this.recommendationBadge,
    this.onTap,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          // Tracking automático de vista
    
          
          if (onTap != null) {
            onTap!();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product),
              ),
            );
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Imagen del producto
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
                        // Badge de recomendación
                        if (recommendationBadge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getBadgeColor(recommendationBadge!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              recommendationBadge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (recommendationBadge != null) 
                          const SizedBox(height: 4),
                        
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor(String badge) {
    switch (badge) {
      case '🔥 Trending':
        return Colors.orange;
      case '⭐ Para ti':
        return Colors.purple;
      case '🆕 Popular':
        return Colors.blue;
      case '💖 Recomendado':
        return Colors.pink;
      default:
        return AppColors.bottonPrimary;
    }
  }
}