// lib/models/subscription_model.dart

/// Generic subscription model, prepared for future billing system.
///
/// This is intentionally flexible, so it should work with most APIs
/// that return user subscription / plan information.
class SubscriptionModel {
  final int id;
  final int userId;

  /// Subscription plan name (e.g. "Standard", "Pro", etc.)
  final String? planName;

  /// Monthly amount or subscription cost in MRU (or your chosen currency).
  final double amount;

  /// Backend status string, e.g. "active", "inactive", "cancelled", "pending".
  final String status;

  /// When the subscription started.
  final DateTime createdAt;

  /// When the subscription expires or must be renewed.
  final DateTime? validUntil;

  /// Optional human-readable description (e.g. "5 missions illimitées...").
  final String? description;

  SubscriptionModel({
    required this.id,
    required this.userId,
    this.planName,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.validUntil,
    this.description,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user'] ?? json['user_id']),
      planName: json['plan_name'] as String?,
      amount: _parseDouble(json['amount']),
      status: (json['status'] as String?) ?? 'inactive',
      createdAt: _parseDateTime(json['created_at']),
      validUntil: _tryParseDate(json['valid_until'] ?? json['expires_at']),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'plan_name': planName,
      'amount': amount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      if (validUntil != null) 'valid_until': validUntil!.toIso8601String(),
      if (description != null) 'description': description,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  bool get isActive => status.toLowerCase() == 'active';

  @override
  String toString() {
    return 'SubscriptionModel(id: $id, userId: $userId, '
        'plan: $planName, amount: $amount, status: $status, '
        'validUntil: $validUntil)';
  }
}
