// lib/models/review_model.dart

class ReviewModel {
  final int id;
  final int rating;
  final String reviewText;
  final String clientName;
  final String workerName;
  final String taskTitle;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.reviewText,
    required this.clientName,
    required this.workerName,
    required this.taskTitle,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int,
      rating: json['rating'] as int,
      reviewText: json['review_text'] as String? ?? '',
      clientName: json['client_name'] as String? ?? 'Unknown',
      workerName: json['worker_name'] as String? ?? 'Unknown',
      taskTitle: json['task_title'] as String? ?? 'Unknown Task',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'review_text': reviewText,
      'client_name': clientName,
      'worker_name': workerName,
      'task_title': taskTitle,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating, client: $clientName)';
  }
}

class ReviewStatisticsModel {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> ratingBreakdown;
  final Map<String, double>? ratingPercentages;

  ReviewStatisticsModel({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
    this.ratingPercentages,
  });

  factory ReviewStatisticsModel.fromJson(Map<String, dynamic> json) {
    return ReviewStatisticsModel(
      averageRating: double.parse(json['average_rating'].toString()),
      totalReviews: json['total_reviews'] as int,
      ratingBreakdown: Map<String, int>.from(json['rating_breakdown'] as Map),
      ratingPercentages: json['rating_percentages'] != null
          ? Map<String, double>.from(
              (json['rating_percentages'] as Map).map(
                (key, value) =>
                    MapEntry(key.toString(), double.parse(value.toString())),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'rating_breakdown': ratingBreakdown,
      'rating_percentages': ratingPercentages,
    };
  }

  int getRatingCount(int rating) {
    return ratingBreakdown[rating.toString()] ?? 0;
  }

  double getRatingPercentage(int rating) {
    if (ratingPercentages != null) {
      return ratingPercentages![rating.toString()] ?? 0.0;
    }
    if (totalReviews == 0) return 0.0;
    final count = getRatingCount(rating);
    return (count / totalReviews) * 100;
  }

  @override
  String toString() {
    return 'ReviewStatisticsModel(avg: $averageRating, total: $totalReviews)';
  }
}

class ReviewsResponseModel {
  final int count;
  final int limit;
  final int offset;
  final ReviewStatisticsModel statistics;
  final List<ReviewModel> reviews;

  ReviewsResponseModel({
    required this.count,
    required this.limit,
    required this.offset,
    required this.statistics,
    required this.reviews,
  });

  factory ReviewsResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewsResponseModel(
      count: json['count'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      statistics: ReviewStatisticsModel.fromJson(
          json['statistics'] as Map<String, dynamic>),
      reviews: (json['results'] as List)
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasMore => offset + reviews.length < count;

  @override
  String toString() {
    return 'ReviewsResponseModel(count: $count, reviews: ${reviews.length})';
  }
}
