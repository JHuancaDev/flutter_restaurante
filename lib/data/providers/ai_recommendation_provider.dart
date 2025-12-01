import 'package:flutter/material.dart';
import 'package:flutter_restaurante/data/models/product.dart';
import 'package:flutter_restaurante/data/services/ai_recommendation_service.dart';
import 'package:flutter_restaurante/data/services/user_behavior_service.dart';

class AIRecommendationProvider with ChangeNotifier {
  final AIRecommendationService _aiService = AIRecommendationService();
  final UserBehaviorService _behaviorService = UserBehaviorService();

  List<Product> _personalizedRecommendations = [];
  List<Product> _trendingProducts = [];
  List<Product> _newUserRecommendations = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<Product> get personalizedRecommendations => _personalizedRecommendations;
  List<Product> get trendingProducts => _trendingProducts;
  List<Product> get newUserRecommendations => _newUserRecommendations;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadPersonalizedRecommendations({int maxResults = 10}) async {
    try {
      _setLoading(true);
      final recommendations = await _aiService.getPersonalizedRecommendations(
        maxResults: maxResults,
      );
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _personalizedRecommendations = recommendations;
        _error = '';
        _setLoading(false);
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _error = 'Error cargando recomendaciones: $e';
        _personalizedRecommendations = [];
        _setLoading(false);
      });
    }
  }

  Future<void> loadTrendingProducts({int limit = 5}) async {
    try {
      final trending = await _aiService.getTrendingProducts(limit: limit);
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _trendingProducts = trending;
        notifyListeners();
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _trendingProducts = [];
        notifyListeners();
      });
    }
  }

  Future<void> loadNewUserRecommendations({int maxResults = 10}) async {
    try {
      final newUserRecs = await _aiService.getNewUserRecommendations(
        maxResults: maxResults,
      );
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _newUserRecommendations = newUserRecs;
        notifyListeners();
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _newUserRecommendations = [];
        notifyListeners();
      });
    }
  }

  void trackProductView(int productId, {int durationSeconds = 0}) {
    _behaviorService.trackProductView(productId, durationSeconds: durationSeconds);
  }

  void trackFavorite(int productId) {
    _behaviorService.trackFavorite(productId);
  }

  void trackPurchase(int productId) {
    _behaviorService.trackPurchase(productId);
  }

  void trackReview(int productId, double rating) {
    _behaviorService.trackReview(productId, rating);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void clearError() {
    _error = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}