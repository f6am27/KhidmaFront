import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/colors.dart';
import '../../../models/models.dart';

class TaskDetailsScreen extends StatelessWidget {
  final TaskModel task;
  final String userRole; // 'worker' or 'client'

  const TaskDetailsScreen({
    Key? key,
    required this.task,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Détails de la tâche',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusBanner(context),
            _buildTaskInfo(context),
            _buildTimeline(context),
            _buildOtherPartyInfo(context),
            _buildPaymentInfo(context),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 🎨 بانر الحالة
  Widget _buildStatusBanner(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (task.status) {
      case TaskStatus.active:
        if (task.workStartedAt != null) {
          statusColor = AppColors.cyan;
          statusText = 'En cours';
          statusIcon = Icons.work_outline;
        } else {
          statusColor = Colors.orange;
          statusText = 'Acceptée';
          statusIcon = Icons.handshake_outlined;
        }
        break;
      case TaskStatus.workCompleted:
        statusColor = AppColors.orange;
        statusText = 'En attente de confirmation';
        statusIcon = Icons.pending_actions;
        break;
      case TaskStatus.completed:
        statusColor = AppColors.green;
        statusText = 'Terminée et payée';
        statusIcon = Icons.check_circle;
        break;
      case TaskStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Annulée';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Publiée';
        statusIcon = Icons.publish;
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          if (task.isUrgent)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'URGENT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 📋 معلومات المهمة
  Widget _buildTaskInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work_outline,
                  color: AppColors.primaryPurple, size: 24),
              SizedBox(width: 8),
              Text(
                'Informations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Divider(height: 24),
          _buildInfoRow(Icons.title, 'Titre', task.title),
          SizedBox(height: 12),
          // _buildInfoRow(Icons.category, 'Service', task.serviceType),
          SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'Localisation', task.location),
          SizedBox(height: 12),
          _buildInfoRow(Icons.schedule, 'Horaire préféré', task.preferredTime),
          SizedBox(height: 12),
          _buildInfoRow(Icons.attach_money, 'Budget', '${task.budget} MRU'),
          // SizedBox(height: 16),
          // Text(
          //   'Description:',
          //   style: TextStyle(
          //     fontSize: 14,
          //     fontWeight: FontWeight.w600,
          //     color: AppColors.textSecondary,
          //   ),
          // ),
          // SizedBox(height: 8),
          // Container(
          //   width: double.infinity,
          //   padding: EdgeInsets.all(12),
          //   decoration: BoxDecoration(
          //     color: AppColors.lightGray.withOpacity(0.3),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Text(
          //     task.description,
          //     style: TextStyle(
          //       fontSize: 14,
          //       color: AppColors.textPrimary,
          //       height: 1.5,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // ⏱️ الجدول الزمني
  Widget _buildTimeline(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: AppColors.primaryPurple, size: 24),
              SizedBox(width: 8),
              Text(
                'Chronologie',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Divider(height: 24),
          _buildTimelineItem(
            Icons.add_circle_outline,
            'Créée',
            _formatDateTime(task.createdAt),
            true,
          ),
          if (task.status != TaskStatus.published)
            _buildTimelineItem(
              Icons.check_circle_outline,
              'Acceptée',
              task.createdAt != null ? 'Acceptée' : '-',
              true,
            ),
          if (task.workStartedAt != null)
            _buildTimelineItem(
              Icons.play_circle_outline,
              'Commencée',
              _formatDateTime(task.workStartedAt!),
              true,
            ),
          if (task.status == TaskStatus.workCompleted ||
              task.status == TaskStatus.completed)
            _buildTimelineItem(
              Icons.assignment_turned_in_outlined,
              'Travail terminé',
              task.workStartedAt != null ? 'Terminée' : '-',
              true,
            ),
          if (task.status == TaskStatus.completed)
            _buildTimelineItem(
              Icons.payment,
              'Payée',
              'Confirmée',
              true,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      IconData icon, String title, String time, bool isCompleted) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.green.withOpacity(0.1)
                  : AppColors.lightGray.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted ? AppColors.green : AppColors.textSecondary,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 👤 معلومات الطرف الآخر
  Widget _buildOtherPartyInfo(BuildContext context) {
    if (task.assignedProvider == null) return SizedBox.shrink();

    final isWorkerView = userRole == 'worker';
    final name = isWorkerView
        ? 'Client' // ← مؤقتاً حتى نضيف clientName من Backend
        : (task.assignedProvider ?? 'Non assigné');
    final role = isWorkerView ? 'Client' : 'Prestataire';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline,
                  color: AppColors.primaryPurple, size: 24),
              SizedBox(width: 8),
              Text(
                role,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Divider(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (!isWorkerView && task.providerRating != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < (task.providerRating ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                          SizedBox(width: 4),
                          Text(
                            '${task.providerRating}/5',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 💰 معلومات الدفع
  Widget _buildPaymentInfo(BuildContext context) {
    if (task.status != TaskStatus.completed &&
        task.status != TaskStatus.workCompleted) {
      return SizedBox.shrink();
    }

    final isPaid = task.status == TaskStatus.completed;

    // ✅ تأكد من عرض final_price الصحيح
    final amountToDisplay = task.finalPrice != null && task.finalPrice! > 0
        ? task.finalPrice
        : task.budget;

    print('════════ PAYMENT INFO DISPLAY ════════');
    print('Final Price: ${task.finalPrice}');
    print('Budget: ${task.budget}');
    print('Amount to Display: $amountToDisplay');
    print('Status: ${task.status}');
    print('═════════════════════════════════════');

    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPaid
            ? AppColors.green.withOpacity(0.1)
            : AppColors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid ? AppColors.green : AppColors.orange,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPaid ? Icons.check_circle : Icons.pending,
                color: isPaid ? AppColors.green : AppColors.orange,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'État du paiement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPaid ? AppColors.green : AppColors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Montant:',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountToDisplay MRU', // ✅ عرض المبلغ الصحيح
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  // ✅ عرض الفرق إذا كان هناك تعديل
                  if (task.finalPrice != null &&
                      task.finalPrice != task.budget &&
                      task.finalPrice! > 0) ...[
                    SizedBox(height: 4),
                    Text(
                      'Budget initial: ${task.budget} MRU',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statut:',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? AppColors.green : AppColors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPaid ? '✓ Payé' : '⏳ En attente',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy à HH:mm').format(dateTime);
  }
}
