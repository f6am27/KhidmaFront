// lib/screens/shared/messages/widgets/report_dialog.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../models/report_model.dart';
import '../../../../services/report_service.dart';

class ReportDialog extends StatelessWidget {
  final int reportedUserId;
  final String reportedUserName;
  final int? conversationId;

  const ReportDialog({
    Key? key,
    required this.reportedUserId,
    required this.reportedUserName,
    this.conversationId,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required int reportedUserId,
    required String reportedUserName,
    int? conversationId,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ReportDialog(
        reportedUserId: reportedUserId,
        reportedUserName: reportedUserName,
        conversationId: conversationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reasons = ReportReasons.getAllReasons();

    return AlertDialog(
      backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Column(
        children: [
          Icon(
            Icons.flag,
            color: Colors.red,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'Signaler l\'utilisateur',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signaler $reportedUserName',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[700],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Choisissez la raison:',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            ...reasons.map((reason) => _buildReportOption(
                  context,
                  isDark,
                  reason['label']!,
                  _getIconData(reason['icon']!),
                  reason['description']!,
                  reason['value']!,
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportOption(
    BuildContext context,
    bool isDark,
    String title,
    IconData icon,
    String description,
    String reasonValue,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        _submitReport(context, reasonValue);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.red,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white54 : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'warning':
        return Icons.warning;
      case 'person_remove':
        return Icons.person_remove;
      case 'security':
        return Icons.security;
      case 'block':
        return Icons.block;
      case 'verified_user':
        return Icons.verified_user;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.flag;
    }
  }

  Future<void> _submitReport(BuildContext context, String reason) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    final result = await reportService.quickReport(
      reportedUserId: reportedUserId,
      reason: reason,
      conversationId: conversationId,
    );

    // Close loading
    Navigator.of(context).pop();

    // Show result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['ok']
              ? 'Signalement envoyé avec succès'
              : 'Erreur: ${result['error']}',
        ),
        backgroundColor: result['ok'] ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
