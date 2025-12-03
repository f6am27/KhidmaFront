// lib/models/task_counter_model.dart

/// Task counter / soft-lock information for the current user.
///
/// This is designed to match the `/api/payments/check-limit/`
/// and `/api/payments/my-counter/` responses.
class TaskCounterModel {
  /// Number of tasks already counted (e.g. accepted / created).
  final int tasksUsed;

  /// How many free/allowed tasks remain before subscription is required.
  final int tasksRemaining;

  /// Whether the user must subscribe to continue (soft-lock reached).
  final bool needsSubscription;

  /// Whether the user currently has an active premium subscription.
  final bool isPremium;

  TaskCounterModel({
    required this.tasksUsed,
    required this.tasksRemaining,
    required this.needsSubscription,
    required this.isPremium,
  });

  factory TaskCounterModel.fromJson(Map<String, dynamic> json) {
    return TaskCounterModel(
      tasksUsed: _parseInt(json['tasks_used'] ?? json['accepted_tasks_count']),
      tasksRemaining: _parseInt(json['tasks_remaining']),
      needsSubscription: _parseBool(json['needs_subscription']),
      isPremium: _parseBool(json['is_premium']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tasks_used': tasksUsed,
      'tasks_remaining': tasksRemaining,
      'needs_subscription': needsSubscription,
      'is_premium': isPremium,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    if (value is num) return value != 0;
    return false;
  }

  @override
  String toString() {
    return 'TaskCounterModel(used: $tasksUsed, remaining: $tasksRemaining, '
        'needsSubscription: $needsSubscription, isPremium: $isPremium)';
  }
}
