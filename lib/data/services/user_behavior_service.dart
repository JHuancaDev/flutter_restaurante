// lib/data/services/user_behavior_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_restaurante/config/environment.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';

enum BehaviorType { view, purchase, favorite, review }

class UserBehaviorService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final TokenStorage _tokenStorage = TokenStorage();

  Future<void> trackUserBehavior({
    required int productId,
    required BehaviorType behaviorType,
    double? rating,
    int? durationSeconds,
  }) async {
    try {
      final token = await _tokenStorage.getToken();

      await _dio.post(
        '/ai/track-behavior',
        data: {
          'product_id': productId,
          'behavior_type': behaviorType.name,
          'rating': rating,
          'duration_seconds': durationSeconds,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {}
  }

  void trackProductView(int productId, {int durationSeconds = 0}) {
    trackUserBehavior(
      productId: productId,
      behaviorType: BehaviorType.view,
      durationSeconds: durationSeconds,
    );
  }

  void trackFavorite(int productId) {
    trackUserBehavior(
      productId: productId,
      behaviorType: BehaviorType.favorite,
    );
  }

  void trackPurchase(int productId) {
    trackUserBehavior(
      productId: productId,
      behaviorType: BehaviorType.purchase,
    );
  }

  void trackReview(int productId, double rating) {
    trackUserBehavior(
      productId: productId,
      behaviorType: BehaviorType.review,
      rating: rating,
    );
  }
}
