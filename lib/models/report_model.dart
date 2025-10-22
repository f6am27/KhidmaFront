// lib/data/models/report_model.dart

class ReportModel {
  final int? id;
  final int reportedUserId;
  final int? conversationId;
  final String reason;
  final String? description;
  final String? status;
  final DateTime? createdAt;
  final DateTime? resolvedAt; // ✅ إضافة

  ReportModel({
    this.id,
    required this.reportedUserId,
    this.conversationId,
    required this.reason,
    this.description,
    this.status,
    this.createdAt,
    this.resolvedAt, // ✅ إضافة
  });

  // من JSON (من الباك إند)
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as int?, // ✅ إصلاح
      reportedUserId: json['reported_user_id'] as int? ?? 0, // ✅ إصلاح
      conversationId: json['conversation_id'] as int?, // ✅ إصلاح
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

  // إلى JSON (لإرسال للباك إند)
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

// أسباب التبليغ (نفس الكود السابق)
class ReportReasons {
  static const String inappropriateContent = 'inappropriate_content';
  static const String harassment = 'harassment';
  static const String scamFraud = 'scam_fraud';
  static const String spam = 'spam';
  static const String fakeProfile = 'fake_profile';
  static const String other = 'other';

  static String getDisplayName(String reason) {
    switch (reason) {
      case inappropriateContent:
        return 'Contenu inapproprié';
      case harassment:
        return 'Harcèlement';
      case scamFraud:
        return 'Arnaque/Fraude';
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
      case inappropriateContent:
        return 'Ce contenu ne respecte pas nos conditions d\'utilisation';
      case harassment:
        return 'Cette personne me harcèle ou intimide';
      case scamFraud:
        return 'Je pense que c\'est une tentative d\'arnaque';
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
      case inappropriateContent:
        return 'warning';
      case harassment:
        return 'person_remove';
      case scamFraud:
        return 'security';
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

  static List<Map<String, String>> getAllReasons() {
    return [
      {
        'value': inappropriateContent,
        'label': getDisplayName(inappropriateContent),
        'description': getDescription(inappropriateContent),
        'icon': getIcon(inappropriateContent),
      },
      {
        'value': harassment,
        'label': getDisplayName(harassment),
        'description': getDescription(harassment),
        'icon': getIcon(harassment),
      },
      {
        'value': scamFraud,
        'label': getDisplayName(scamFraud),
        'description': getDescription(scamFraud),
        'icon': getIcon(scamFraud),
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
