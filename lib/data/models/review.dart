class Review {
  final int id;
  final int productId;
  final int userId;
  final double rating;
  final String? comment;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userName;
  final String productName;
  final String? productImage;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.isApproved,
    required this.createdAt,
    this.updatedAt,
    required this.userName,
    required this.productName,
    this.productImage,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'],
      isApproved: json['is_approved'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      userName: json['user_name'] ?? 'Usuario',
      productName: json['product_name'] ?? '',
      productImage: json['product_image'],
    );
  }
}

class ReviewStats {
  final int totalReviews;
  final double averageRating;

  ReviewStats({
    required this.totalReviews,
    required this.averageRating,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      totalReviews: json['total_reviews'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
    );
  }
}

class ReviewCreate {
  final int productId;
  final double rating;
  final String? comment;

  ReviewCreate({
    required this.productId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'rating': rating,
      'comment': comment,
    };
  }
}

class ReviewUpdate {
  final double? rating;
  final String? comment;

  ReviewUpdate({
    this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (rating != null) data['rating'] = rating;
    if (comment != null) data['comment'] = comment;
    return data;
  }
}