// lib/models/notification_model.dart

class NotificationModel {
  final int id;
  final String notificationType;
  final String title;
  final String message;
  final bool isRead;
  final String? readAt;
  final String createdAt;
  final String? updatedAt;

  // معلومات إضافية
  final String? timeAgo;
  final String recipientRole;

  // معلومات المهمة المرتبطة
  final String? taskTitle;
  final int? taskId;

  // معلومات إضافية للعرض (Client/Worker names, amounts)
  final String? relatedPersonName; // workerName للعميل، clientName للعامل
  final int? amount; // للعمال فقط

  NotificationModel({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.updatedAt,
    this.timeAgo,
    required this.recipientRole,
    this.taskTitle,
    this.taskId,
    this.relatedPersonName,
    this.amount,
  });

  /// Create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      notificationType: json['notification_type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      timeAgo: json['time_ago'] as String?,
      recipientRole: json['recipient_role'] as String,
      taskTitle: json['task_title'] as String?,
      taskId: json['task_id'] as int?,
      relatedPersonName: null, // سنملأها من الواجهة حسب الحاجة
      amount: null, // سنملأها من الواجهة حسب الحاجة
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_type': notificationType,
      'title': title,
      'message': message,
      'is_read': isRead,
      'read_at': readAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'time_ago': timeAgo,
      'recipient_role': recipientRole,
      'task_title': taskTitle,
      'task_id': taskId,
    };
  }

  /// Get notification type enum
  NotificationType get type {
    return NotificationTypeExtension.fromString(notificationType);
  }

  /// Copy with method for updating fields
  NotificationModel copyWith({
    int? id,
    String? notificationType,
    String? title,
    String? message,
    bool? isRead,
    String? readAt,
    String? createdAt,
    String? updatedAt,
    String? timeAgo,
    String? recipientRole,
    String? taskTitle,
    int? taskId,
    String? relatedPersonName,
    int? amount,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timeAgo: timeAgo ?? this.timeAgo,
      recipientRole: recipientRole ?? this.recipientRole,
      taskTitle: taskTitle ?? this.taskTitle,
      taskId: taskId ?? this.taskId,
      relatedPersonName: relatedPersonName ?? this.relatedPersonName,
      amount: amount ?? this.amount,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $notificationType, title: $title, isRead: $isRead)';
  }
}

/// Unified Notification Types for both Client and Worker
enum NotificationType {
  // Client notifications (7 types)
  taskPublished, // تأكيد نشر المهمة
  workerApplied, // عامل تقدم للمهمة
  taskCompleted, // العامل أنهى العمل
  paymentReceived, // تأكيد الدفع
  messageReceived, // رسالة جديدة
  serviceReminder, // تذكير بالموعد
  serviceCancelled, // إلغاء الخدمة

  // Worker notifications (5 types)
  newTaskAvailable, // مهمة جديدة متاحة
  applicationAccepted, // قبول الطلب
  applicationRejected, // رفض الطلب
  paymentSent, // استلام الدفع
  // messageReceived - مشترك مع Client

  // Unknown/Default
  unknown,
}

/// Extension for NotificationType
extension NotificationTypeExtension on NotificationType {
  /// Convert string from backend to enum
  static NotificationType fromString(String type) {
    switch (type) {
      // Client types
      case 'task_published':
        return NotificationType.taskPublished;
      case 'worker_applied':
        return NotificationType.workerApplied;
      case 'task_completed':
        return NotificationType.taskCompleted;
      case 'payment_received':
        return NotificationType.paymentReceived;
      case 'service_reminder':
        return NotificationType.serviceReminder;
      case 'service_cancelled':
        return NotificationType.serviceCancelled;

      // Worker types
      case 'new_task_available':
        return NotificationType.newTaskAvailable;
      case 'application_accepted':
        return NotificationType.applicationAccepted;
      case 'application_rejected':
        return NotificationType.applicationRejected;
      case 'payment_sent':
        return NotificationType.paymentSent;

      // Shared
      case 'message_received':
        return NotificationType.messageReceived;

      default:
        return NotificationType.unknown;
    }
  }

  /// Convert enum to backend string
  String toBackendString() {
    switch (this) {
      // Client types
      case NotificationType.taskPublished:
        return 'task_published';
      case NotificationType.workerApplied:
        return 'worker_applied';
      case NotificationType.taskCompleted:
        return 'task_completed';
      case NotificationType.paymentReceived:
        return 'payment_received';
      case NotificationType.serviceReminder:
        return 'service_reminder';
      case NotificationType.serviceCancelled:
        return 'service_cancelled';

      // Worker types
      case NotificationType.newTaskAvailable:
        return 'new_task_available';
      case NotificationType.applicationAccepted:
        return 'application_accepted';
      case NotificationType.applicationRejected:
        return 'application_rejected';
      case NotificationType.paymentSent:
        return 'payment_sent';

      // Shared
      case NotificationType.messageReceived:
        return 'message_received';

      default:
        return 'unknown';
    }
  }

  /// Get display name in French
  String get displayName {
    switch (this) {
      case NotificationType.taskPublished:
        return 'Tâche publiée';
      case NotificationType.workerApplied:
        return 'Prestataire candidat';
      case NotificationType.taskCompleted:
        return 'Tâche terminée';
      case NotificationType.paymentReceived:
        return 'Paiement reçu';
      case NotificationType.serviceReminder:
        return 'Rappel de service';
      case NotificationType.serviceCancelled:
        return 'Service annulé';
      case NotificationType.newTaskAvailable:
        return 'Nouvelle tâche disponible';
      case NotificationType.applicationAccepted:
        return 'Candidature acceptée';
      case NotificationType.applicationRejected:
        return 'Candidature rejetée';
      case NotificationType.paymentSent:
        return 'Paiement envoyé';
      case NotificationType.messageReceived:
        return 'Message reçu';
      default:
        return 'Notification';
    }
  }

  /// Check if notification type is for client
  bool get isClientNotification {
    return this == NotificationType.taskPublished ||
        this == NotificationType.workerApplied ||
        this == NotificationType.taskCompleted ||
        this == NotificationType.paymentReceived ||
        this == NotificationType.serviceReminder ||
        this == NotificationType.serviceCancelled;
  }

  /// Check if notification type is for worker
  bool get isWorkerNotification {
    return this == NotificationType.newTaskAvailable ||
        this == NotificationType.applicationAccepted ||
        this == NotificationType.applicationRejected ||
        this == NotificationType.paymentSent;
  }

  /// Check if notification type is shared
  bool get isSharedNotification {
    return this == NotificationType.messageReceived;
  }
}

/// Notification Statistics Model
class NotificationStatsModel {
  final int totalNotifications;
  final int unreadNotifications;
  final int readNotifications;
  final int notificationsToday;
  final int notificationsThisWeek;
  final int taskNotifications;
  final int messageNotifications;
  final int paymentNotifications;

  NotificationStatsModel({
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.readNotifications,
    required this.notificationsToday,
    required this.notificationsThisWeek,
    required this.taskNotifications,
    required this.messageNotifications,
    required this.paymentNotifications,
  });

  factory NotificationStatsModel.fromJson(Map<String, dynamic> json) {
    return NotificationStatsModel(
      totalNotifications: json['total_notifications'] as int? ?? 0,
      unreadNotifications: json['unread_notifications'] as int? ?? 0,
      readNotifications: json['read_notifications'] as int? ?? 0,
      notificationsToday: json['notifications_today'] as int? ?? 0,
      notificationsThisWeek: json['notifications_this_week'] as int? ?? 0,
      taskNotifications: json['task_notifications'] as int? ?? 0,
      messageNotifications: json['message_notifications'] as int? ?? 0,
      paymentNotifications: json['payment_notifications'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_notifications': totalNotifications,
      'unread_notifications': unreadNotifications,
      'read_notifications': readNotifications,
      'notifications_today': notificationsToday,
      'notifications_this_week': notificationsThisWeek,
      'task_notifications': taskNotifications,
      'message_notifications': messageNotifications,
      'payment_notifications': paymentNotifications,
    };
  }
}

/// Notification Settings Model
class NotificationSettingsModel {
  final bool notificationsEnabled;

  NotificationSettingsModel({
    required this.notificationsEnabled,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
    };
  }

  NotificationSettingsModel copyWith({
    bool? notificationsEnabled,
  }) {
    return NotificationSettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
