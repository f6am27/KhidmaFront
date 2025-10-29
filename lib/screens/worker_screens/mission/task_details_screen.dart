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
        child: Column(
          children: [
            _buildStatusBanner(context),
            _buildTimeline(context),
            _buildOtherPartyInfo(context),
            _buildPaymentInfo(context),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (widget.task.status) {
      case TaskStatus.active:
        if (widget.task.workStartedAt != null) {
          statusColor = AppColors.cyan;
          statusText = 'En cours';
        } else {
          statusColor = Colors.orange;
          statusText = 'Acceptée';
        }
        break;
      case TaskStatus.workCompleted:
        statusColor = AppColors.orange;
        statusText = 'En attente de confirmation';
        break;
      case TaskStatus.completed:
        statusColor = AppColors.green;
        statusText = 'Terminée';
        break;
      case TaskStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Annulée';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Publiée';
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            statusText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
          if (widget.task.isUrgent)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
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

  Widget _buildTimeline(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeColors.darkCardBackground
            : Colors.white,
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
          Text(
            'Chronologie',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkTextPrimary
                  : ThemeColors.lightTextPrimary,
            ),
          ),
          Divider(height: 24),
          if (widget.task.workStartedAt != null)
            _buildTimelineItem(
              'Commencée',
              _formatDateTime(widget.task.workStartedAt!),
              true,
            ),
          if (widget.task.status == TaskStatus.completed)
            _buildTimelineItem(
              'Confirmée',
              _paymentData != null
                  ? _formatDateTime(_paymentData!.createdAt)
                  : 'Confirmée',
              true,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, bool isCompleted) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.green : AppColors.lightGray,
              shape: BoxShape.circle,
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkTextPrimary
                        : ThemeColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkTextSecondary
                        : ThemeColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherPartyInfo(BuildContext context) {
    // لا نعرض شيئاً إذا لم تكن المهمة مكتملة أو لا يوجد بيانات دفع
    if (widget.task.status != TaskStatus.completed || _paymentData == null) {
      return SizedBox.shrink();
    }

    final isWorkerView = widget.userRole == 'worker';
    final name =
        isWorkerView ? _paymentData!.payerName : _paymentData!.receiverName;
    final role = isWorkerView ? 'Client' : 'Prestataire';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeColors.darkCardBackground
            : Colors.white,
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
          Text(
            role,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkTextPrimary
                  : ThemeColors.lightTextPrimary,
            ),
          ),
          Divider(height: 24),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkTextPrimary
                  : ThemeColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context) {
    if (widget.task.status != TaskStatus.completed &&
        widget.task.status != TaskStatus.workCompleted) {
      return SizedBox.shrink();
    }

    final isPaid = widget.task.status == TaskStatus.completed;

    // استخدام بيانات الدفع إذا كانت متاحة
    final amountToDisplay = _paymentData?.amount ??
        (widget.task.finalPrice ?? widget.task.budget.toDouble());

    final initialBudget = widget.task.budget.toDouble();
    final showBudgetDifference = amountToDisplay != initialBudget;

    print('════════ PAYMENT INFO DISPLAY ════════');
    print('User Role: ${widget.userRole}');
    print('Payment Data: ${_paymentData?.toString()}');
    print('Amount to Display: $amountToDisplay MRU');
    print('Initial Budget: $initialBudget MRU');
    print('Status: ${widget.task.status}');
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
          Text(
            'État du paiement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPaid ? AppColors.green : AppColors.orange,
            ),
          ),
          SizedBox(height: 16),

          // المبلغ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Montant:',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? ThemeColors.darkTextSecondary
                      : ThemeColors.lightTextSecondary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${amountToDisplay.toStringAsFixed(0)} MRU',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? ThemeColors.darkTextPrimary
                          : ThemeColors.lightTextPrimary,
                    ),
                  ),
                  if (showBudgetDifference) ...[
                    SizedBox(height: 4),
                    Text(
                      'Budget initial: ${initialBudget.toStringAsFixed(0)} MRU',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? ThemeColors.darkTextSecondary
                            : ThemeColors.lightTextSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          SizedBox(height: 12),

          // الحالة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statut:',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? ThemeColors.darkTextSecondary
                      : ThemeColors.lightTextSecondary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPaid ? AppColors.green : AppColors.orange,
                  borderRadius: BorderRadius.circular(8),
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

          // طريقة الدفع (إذا كانت متاحة)
          if (_paymentData != null && isPaid) ...[
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Méthode:',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkTextSecondary
                        : ThemeColors.lightTextSecondary,
                  ),
                ),
                Text(
                  _paymentData!.paymentMethodDisplay,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkTextPrimary
                        : ThemeColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ],

          // تاريخ الدفع (إذا كان متاحاً)
          if (_paymentData != null && isPaid) ...[
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date:',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkTextSecondary
                        : ThemeColors.lightTextSecondary,
                  ),
                ),
                Text(
                  _formatDateTime(_paymentData!.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkTextPrimary
                        : ThemeColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy à HH:mm').format(dateTime);
  }
}
