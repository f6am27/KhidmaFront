import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/colors.dart';
import '../../../models/models.dart';
import '../../../models/payment_model.dart';
import '../../../services/payment_service.dart';
import '../../../core/theme/theme_colors.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;
  final String userRole; // 'worker' or 'client'

  const TaskDetailsScreen({
    Key? key,
    required this.task,
    required this.userRole,
  }) : super(key: key);

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  PaymentModel? _paymentData;
  bool _isLoadingPayment = false;

  @override
  void initState() {
    super.initState();
    // جلب بيانات الدفع إذا كانت المهمة مكتملة
    if (widget.task.status == TaskStatus.completed) {
      _loadPaymentData();
    }
  }

  Future<void> _loadPaymentData() async {
    setState(() => _isLoadingPayment = true);

    try {
      final result = await paymentService.getMyPayments(limit: 100);

      if (result['ok'] == true) {
        final payments = result['payments'] as List<PaymentModel>;

        // البحث عن الدفعة المرتبطة بهذه المهمة
        final payment = payments.firstWhere(
          (p) => p.taskTitle == widget.task.title,
          orElse: () =>
              payments.isNotEmpty ? payments.first : _createDummyPayment(),
        );

        setState(() {
          _paymentData = payment;
          _isLoadingPayment = false;
        });

        print(
            '✅ Payment loaded: ${payment.payerName} → ${payment.receiverName}');
      }
    } catch (e) {
      print('❌ Error loading payment: $e');
      setState(() => _isLoadingPayment = false);
    }
  }

  PaymentModel _createDummyPayment() {
    return PaymentModel(
      id: 0,
      taskTitle: widget.task.title,
      serviceType: widget.task.serviceType,
      amount: widget.task.finalPrice ?? widget.task.budget.toDouble(),
      paymentMethod: 'cash',
      paymentMethodDisplay: 'Espèces',
      status: 'completed',
      payerName: 'Client',
      receiverName: widget.task.assignedProvider ?? 'Prestataire',
      createdAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).brightness == Brightness.dark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Détails de la tâche',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: _buildPaymentInfo(context),
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context) {
    if (widget.task.status != TaskStatus.completed &&
        widget.task.status != TaskStatus.workCompleted) {
      return SizedBox.shrink();
    }

    final isPaid = widget.task.status == TaskStatus.completed;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // استخدام بيانات الدفع إذا كانت متاحة
    final amountToDisplay = _paymentData?.amount ??
        (widget.task.finalPrice ?? widget.task.budget.toDouble());

    final initialBudget = widget.task.budget.toDouble();
    final showBudgetDifference = amountToDisplay != initialBudget;

    final isWorkerView = widget.userRole == 'worker';
    final payerName = _paymentData?.payerName ?? 'Client';
    final receiverName = _paymentData?.receiverName ??
        (widget.task.assignedProvider ?? 'Prestataire');

    print('════════ PAYMENT INFO DISPLAY ════════');
    print('User Role: ${widget.userRole}');
    print('Payment Data: ${_paymentData?.toString()}');
    print('Amount to Display: $amountToDisplay MRU');
    print('Initial Budget: $initialBudget MRU');
    print('Status: ${widget.task.status}');
    print('═════════════════════════════════════');

    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // أيقونة النجاح الدائرية
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isPaid
                    ? [
                        AppColors.green.withOpacity(0.2),
                        AppColors.green.withOpacity(0.1),
                      ]
                    : [
                        AppColors.orange.withOpacity(0.2),
                        AppColors.orange.withOpacity(0.1),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPaid ? AppColors.green : AppColors.orange,
              ),
              child: Icon(
                isPaid ? Icons.check : Icons.access_time,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          SizedBox(height: 20),

          // عنوان الحالة
          Text(
            isPaid ? 'Paiement Confirmé' : 'En Attente de Paiement',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? ThemeColors.darkTextPrimary
                  : ThemeColors.lightTextPrimary,
            ),
          ),

          SizedBox(height: 8),

          // رسالة فرعية
          Text(
            isPaid
                ? 'Le paiement a été effectué avec succès'
                : 'En attente de confirmation du client',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? ThemeColors.darkTextSecondary
                  : ThemeColors.lightTextSecondary,
            ),
          ),

          // عرض الوقت المنقضي منذ بداية المهمة
          if (widget.task.workStartedAt != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? ThemeColors.darkTextSecondary.withOpacity(0.1)
                    : ThemeColors.lightTextSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getTimeAgo(widget.task.workStartedAt!),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? ThemeColors.darkTextSecondary
                      : ThemeColors.lightTextSecondary,
                ),
              ),
            ),
          ],

          SizedBox(height: 24),

          // خط فاصل
          Container(
            height: 1,
            color: isDark
                ? ThemeColors.darkTextSecondary.withOpacity(0.2)
                : ThemeColors.lightTextSecondary.withOpacity(0.2),
          ),

          SizedBox(height: 24),

          // تفاصيل الدفع
          _buildPaymentDetailRow(
            context,
            widget.task.title,
            null,
            isHeader: true,
          ),

          SizedBox(height: 16),

          _buildPaymentDetailRow(
            context,
            widget.task.serviceType,
            '${amountToDisplay.toStringAsFixed(0)} MRU',
          ),

          if (_paymentData != null && isPaid) ...[
            SizedBox(height: 12),
            _buildPaymentDetailRow(
              context,
              _paymentData!.paymentMethodDisplay,
              null,
            ),
          ],

          if (showBudgetDifference) ...[
            SizedBox(height: 12),
            _buildPaymentDetailRow(
              context,
              'Budget initial',
              '${initialBudget.toStringAsFixed(0)} MRU',
              isStriked: true,
            ),
          ],

          SizedBox(height: 20),

          // خط فاصل
          Container(
            height: 1,
            color: isDark
                ? ThemeColors.darkTextSecondary.withOpacity(0.2)
                : ThemeColors.lightTextSecondary.withOpacity(0.2),
          ),

          SizedBox(height: 20),

          // المجموع النهائي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ThemeColors.darkTextPrimary
                      : ThemeColors.lightTextPrimary,
                ),
              ),
              Text(
                '${amountToDisplay.toStringAsFixed(0)} MRU',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isPaid ? AppColors.green : AppColors.orange,
                ),
              ),
            ],
          ),

          // معلومات الدافع والمستلم
          if (_paymentData != null && isPaid) ...[
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? ThemeColors.darkTextSecondary.withOpacity(0.1)
                    : ThemeColors.lightTextSecondary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payé par',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? ThemeColors.darkTextSecondary
                              : ThemeColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        payerName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? ThemeColors.darkTextPrimary
                              : ThemeColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reçu par',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? ThemeColors.darkTextSecondary
                              : ThemeColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        receiverName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? ThemeColors.darkTextPrimary
                              : ThemeColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (_paymentData!.createdAt != null) ...[
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? ThemeColors.darkTextSecondary
                                : ThemeColors.lightTextSecondary,
                          ),
                        ),
                        Text(
                          _formatDateTime(_paymentData!.createdAt),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? ThemeColors.darkTextPrimary
                                : ThemeColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentDetailRow(
    BuildContext context,
    String label,
    String? value, {
    bool isHeader = false,
    bool isStriked = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isHeader ? 15 : 14,
              fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
              color: isHeader
                  ? (isDark
                      ? ThemeColors.darkTextPrimary
                      : ThemeColors.lightTextPrimary)
                  : (isDark
                      ? ThemeColors.darkTextSecondary
                      : ThemeColors.lightTextSecondary),
            ),
          ),
        ),
        if (value != null)
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? ThemeColors.darkTextPrimary
                  : ThemeColors.lightTextPrimary,
              decoration: isStriked ? TextDecoration.lineThrough : null,
            ),
          ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy à HH:mm', 'fr_FR').format(dateTime);
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Il y a ${difference.inSeconds} secondes';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Il y a $minutes minute${minutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Il y a $hours heure${hours > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final days = difference.inDays;
      return 'Il y a $days jour${days > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }
}
