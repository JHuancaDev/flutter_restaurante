import 'package:flutter/material.dart';
import 'package:flutter_restaurante/data/models/review.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/presentation/pages/widgets/rating_stars.dart';

class ReviewCard extends StatefulWidget {
  final Review review;
  final VoidCallback onDelete;

  const ReviewCard({super.key, required this.review, required this.onDelete});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  final TokenStorage _tokenStorage = TokenStorage();
  bool _isUsersReview = false;

  @override
  void initState() {
    super.initState();
    _checkIfUsersReview();
  }

  Future<void> _checkIfUsersReview() async {
    // En una implementación real, compararías con el ID del usuario actual
    // Por ahora, asumimos que no es del usuario actual
    setState(() {
      _isUsersReview = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RatingStars(rating: widget.review.rating, size: 16),
                    ],
                  ),
                ),
                if (_isUsersReview)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar reseña'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteDialog();
                      }
                    },
                  ),
              ],
            ),
            if (widget.review.comment != null &&
                widget.review.comment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.review.comment!,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              _formatDate(widget.review.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reseña'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta reseña?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy a las ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Ayer a las ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
