import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class WorkerPaymentHistoryScreen extends StatefulWidget {
  @override
  _WorkerPaymentHistoryScreenState createState() =>
      _WorkerPaymentHistoryScreenState();
}

class _WorkerPaymentHistoryScreenState
    extends State<WorkerPaymentHistoryScreen> {
  String selectedFilter = 'all'; // all, this_month, last_month, this_year
  List<WorkerPaymentModel> filteredPayments = [];

  @override
  void initState() {
    super.initState();
    filteredPayments = _payments;
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      final now = DateTime.now();

      switch (filter) {
        case 'this_month':
          filteredPayments = _payments
              .where((payment) =>
                  payment.dateTime.year == now.year &&
                  payment.dateTime.month == now.month)
              .toList();
          break;
        case 'last_month':
          final lastMonth = DateTime(now.year, now.month - 1);
          filteredPayments = _payments
              .where((payment) =>
                  payment.dateTime.year == lastMonth.year &&
                  payment.dateTime.month == lastMonth.month)
              .toList();
          break;
        case 'this_year':
          filteredPayments = _payments
              .where((payment) => payment.dateTime.year == now.year)
              .toList();
          break;
        case 'all':
        default:
          filteredPayments = _payments;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Gains'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: _applyFilter,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text('Tous')),
              PopupMenuItem(value: 'this_month', child: Text('Ce mois')),
              PopupMenuItem(value: 'last_month', child: Text('Mois dernier')),
              PopupMenuItem(value: 'this_year', child: Text('Cette année')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary card
          _buildSummaryCard(context, isDark),

          // Payments list
          Expanded(
            child: filteredPayments.isEmpty
                ? _buildEmptyState(context, isDark)
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredPayments.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final payment = filteredPayments[index];
                      return _buildPaymentCard(payment, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, bool isDark) {
    final totalEarned =
        filteredPayments.fold<int>(0, (sum, p) => sum + p.amount);
    final paymentsCount = filteredPayments.length;
    final averagePayment = paymentsCount > 0 ? totalEarned / paymentsCount : 0;

    // Calculate this month's earnings
    final now = DateTime.now();
    final thisMonthEarnings = _payments
        .where(
            (p) => p.dateTime.year == now.year && p.dateTime.month == now.month)
        .fold<int>(0, (sum, p) => sum + p.amount);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? ThemeColors.shadowDark : ThemeColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main stats
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Total gagné',
                  '$totalEarned MRU',
                  Icons.account_balance_wallet,
                  isDark,
                  color: ThemeColors.successColor,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Ce mois',
                  '$thisMonthEarnings MRU',
                  Icons.calendar_month,
                  isDark,
                  color: ThemeColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(
            color: isDark ? ThemeColors.darkDivider : ThemeColors.lightDivider,
          ),
          SizedBox(height: 16),

          // Secondary stats
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Nombre de services',
                  '$paymentsCount',
                  Icons.work_outline,
                  isDark,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Gain moyen',
                  '${averagePayment.toStringAsFixed(0)} MRU',
                  Icons.trending_up,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value,
      IconData icon, bool isDark,
      {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? ThemeColors.primaryColor,
          size: 24,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color ??
                    (isDark
                        ? ThemeColors.darkTextPrimary
                        : ThemeColors.lightTextPrimary),
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? ThemeColors.darkTextSecondary
                    : ThemeColors.lightTextSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(WorkerPaymentModel payment, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? ThemeColors.shadowDark : ThemeColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with service info and amount
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ThemeColors.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.monetization_on,
                  color: ThemeColors.successColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.serviceName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getServiceTypeColor(payment.serviceType)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getServiceTypeText(payment.serviceType),
                        style: TextStyle(
                          color: _getServiceTypeColor(payment.serviceType),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${payment.amount} MRU',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.successColor,
                        ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ThemeColors.successColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Reçu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Client info
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? ThemeColors.darkSurface.withOpacity(0.5)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      isDark ? ThemeColors.darkSurface : Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    size: 18,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payé par:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white54 : Colors.grey[600],
                            ),
                      ),
                      Text(
                        payment.clientName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                      ),
                    ],
                  ),
                ),
                if (payment.rating != null) ...[
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        payment.rating!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.amber,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 12),

          // Payment details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  Icons.calendar_today_outlined,
                  _formatDateTime(payment.dateTime),
                  isDark,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  context,
                  _getPaymentMethodIcon(payment.paymentMethod),
                  payment.paymentMethod,
                  isDark,
                ),
              ),
            ],
          ),

          if (payment.transactionId != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? ThemeColors.darkSurface.withOpacity(0.3)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tag,
                    size: 14,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                  SizedBox(width: 6),
                  Text(
                    'ID Transaction: ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.grey[500],
                        ),
                  ),
                  Text(
                    payment.transactionId!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey[700],
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white54 : Colors.grey[500],
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucun paiement reçu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Vos gains apparaîtront ici\naprès avoir terminé des services',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Color _getServiceTypeColor(ServiceType type) {
    switch (type) {
      case ServiceType.direct:
        return Colors.blue;
      case ServiceType.fromTask:
        return Colors.purple;
    }
  }

  String _getServiceTypeText(ServiceType type) {
    switch (type) {
      case ServiceType.direct:
        return 'Service direct';
      case ServiceType.fromTask:
        return 'Via une tâche';
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'espèces':
        return Icons.money;
      case 'bankily':
        return Icons.account_balance_wallet;
      case 'sedad':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    String dateStr;
    if (difference.inDays == 0) {
      dateStr = "Aujourd'hui";
    } else if (difference.inDays == 1) {
      dateStr = "Hier";
    } else if (difference.inDays < 7) {
      dateStr = "Il y a ${difference.inDays} jours";
    } else {
      dateStr = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }

    String timeStr =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return "$dateStr à $timeStr";
  }

  // Sample data - payments received by the worker
  final List<WorkerPaymentModel> _payments = [
    WorkerPaymentModel(
      id: '1',
      serviceName: 'Réparation plomberie urgente',
      clientName: 'Fatima Al-Zahra',
      amount: 5000,
      dateTime: DateTime.now().subtract(Duration(hours: 3)),
      paymentMethod: 'Bankily',
      serviceType: ServiceType.fromTask,
      transactionId: 'BKL123456789',
      rating: 5.0,
    ),
    WorkerPaymentModel(
      id: '2',
      serviceName: 'Installation électrique',
      clientName: 'Ahmed Ould Salem',
      amount: 4200,
      dateTime: DateTime.now().subtract(Duration(days: 1)),
      paymentMethod: 'Espèces',
      serviceType: ServiceType.direct,
      transactionId: null,
      rating: 4.0,
    ),
    WorkerPaymentModel(
      id: '3',
      serviceName: 'Réparation fuite d\'eau',
      clientName: 'Mariem Mint Mohamed',
      amount: 2800,
      dateTime: DateTime.now().subtract(Duration(days: 3)),
      paymentMethod: 'Sedad',
      serviceType: ServiceType.direct,
      transactionId: 'SDD987654321',
      rating: 5.0,
    ),
    WorkerPaymentModel(
      id: '4',
      serviceName: 'Maintenance électrique',
      clientName: 'Hassan Ba',
      amount: 2500,
      dateTime: DateTime.now().subtract(Duration(days: 5)),
      paymentMethod: 'Bankily',
      serviceType: ServiceType.fromTask,
      transactionId: 'BKL456789123',
      rating: 4.0,
    ),
    WorkerPaymentModel(
      id: '5',
      serviceName: 'Installation prise électrique',
      clientName: 'Omar Ould Ahmed',
      amount: 1800,
      dateTime: DateTime.now().subtract(Duration(days: 8)),
      paymentMethod: 'Espèces',
      serviceType: ServiceType.direct,
      transactionId: null,
      rating: 5.0,
    ),
    WorkerPaymentModel(
      id: '6',
      serviceName: 'Réparation générale',
      clientName: 'Aicha Mint Ali',
      amount: 3000,
      dateTime: DateTime.now().subtract(Duration(days: 12)),
      paymentMethod: 'Sedad',
      serviceType: ServiceType.fromTask,
      transactionId: 'SDD321654987',
      rating: 3.0,
    ),
  ];
}

// Models
enum ServiceType { direct, fromTask }

class WorkerPaymentModel {
  final String id;
  final String serviceName;
  final String clientName;
  final int amount;
  final DateTime dateTime;
  final String paymentMethod;
  final ServiceType serviceType;
  final String? transactionId;
  final double? rating;

  WorkerPaymentModel({
    required this.id,
    required this.serviceName,
    required this.clientName,
    required this.amount,
    required this.dateTime,
    required this.paymentMethod,
    required this.serviceType,
    this.transactionId,
    this.rating,
  });
}
