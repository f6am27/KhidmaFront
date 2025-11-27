// lib/data/models/report_model.dart

class ReportModel {
  final int? id;
  final int reportedUserId;
  final int? conversationId;
  final String reason;
  final String? description;
  final String? status;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  ReportModel({
    this.id,
    required this.reportedUserId,
    this.conversationId,
    required this.reason,
    this.description,
    this.status,
    this.createdAt,
    this.resolvedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as int?,
      reportedUserId: json['reported_user_id'] as int? ?? 0,
      conversationId: json['conversation_id'] as int?,
      reason: json['reason'] ?? '',
      description: json['description'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'reported_user_id': reportedUserId,
      if (conversationId != null) 'conversation_id': conversationId,
      'reason': reason,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

// ✅ أسباب التبليغ المحدثة
class ReportReasons {
  // ❌ تم حذف inappropriateContent
  static const String scamFraud = 'scam_fraud'; // ✅ الآن هو الأول
  static const String harassment = 'harassment';
  static const String spam = 'spam';
  static const String fakeProfile = 'fake_profile';
  static const String other = 'other';

  static String getDisplayName(String reason) {
    switch (reason) {
      case scamFraud:
        return 'Arnaque/Fraude';
      case harassment:
        return 'Harcèlement';
      case spam:
        return 'Spam';
      case fakeProfile:
        return 'Profil faux';
      case other:
        return 'Autre';
      default:
        return reason;
    }
  }

  static String getDescription(String reason) {
    switch (reason) {
      case scamFraud:
        return 'Je pense que c\'est une tentative d\'arnaque';
      case harassment:
        return 'Cette personne me harcèle ou intimide';
      case spam:
        return 'Messages répétitifs ou non sollicités';
      case fakeProfile:
        return 'Je pense que ce profil est faux';
      case other:
        return 'Autre problème';
      default:
        return '';
    }
  }

  static String getIcon(String reason) {
    switch (reason) {
      case scamFraud:
        return 'security';
      case harassment:
        return 'person_remove';
      case spam:
        return 'block';
      case fakeProfile:
        return 'verified_user';
      case other:
        return 'more_horiz';
      default:
        return 'flag';
    }
  }

  // ✅ القائمة المحدثة - scamFraud أولاً وبدون inappropriateContent
  static List<Map<String, String>> getAllReasons() {
    return [
      {
        'value': scamFraud,
        'label': getDisplayName(scamFraud),
        'description': getDescription(scamFraud),
        'icon': getIcon(scamFraud),
      },
      {
        'value': harassment,
        'label': getDisplayName(harassment),
        'description': getDescription(harassment),
        'icon': getIcon(harassment),
      },
      {
        'value': spam,
        'label': getDisplayName(spam),
        'description': getDescription(spam),
        'icon': getIcon(spam),
      },
      {
        'value': fakeProfile,
        'label': getDisplayName(fakeProfile),
        'description': getDescription(fakeProfile),
        'icon': getIcon(fakeProfile),
      },
      {
        'value': other,
        'label': getDisplayName(other),
        'description': getDescription(other),
        'icon': getIcon(other),
      },
    ];
  }
}
