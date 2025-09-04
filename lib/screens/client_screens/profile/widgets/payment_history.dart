import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class PaymentHistoryScreen extends StatefulWidget {
  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Paiements'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Summary card
          _buildSummaryCard(context, isDark),

          // Payments list
          Expanded(
            child: _payments.isEmpty
                ? _buildEmptyState(context, isDark)
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _payments.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final payment = _payments[index];
                      return _buildPaymentCard(payment, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, bool isDark) {
    final totalPaid = _payments.fold<int>(0, (sum, p) => sum + p.amount);
    final paymentsCount = _payments.length;

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
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              context,
              'Total payé',
              '$totalPaid MRU',
              Icons.attach_money,
              isDark,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: _buildSummaryItem(
              context,
              'Nombre de paiements',
              '$paymentsCount',
              Icons.receipt_long,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value,
      IconData icon, bool isDark) {
    return Column(
      children: [
        Icon(
          icon,
          color: ThemeColors.primaryColor,
          size: 24,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isDark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
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

  Widget _buildPaymentCard(PaymentModel payment, bool isDark) {
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
          // Header with service info
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ThemeColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.check_circle,
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
                    '${payment.amount} MRU',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.successColor,
                        ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Payé',
                    style: TextStyle(
                      color: ThemeColors.successColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: ThemeColors.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Payé à: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                ),
                Expanded(
                  child: Text(
                    payment.clientName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                  ),
                ),
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
            Icons.receipt_long_outlined,
            size: 64,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucun paiement effectué',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Vos paiements aux prestataires\napparaîtront ici',
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

  // Sample data
  final List<PaymentModel> _payments = [
    PaymentModel(
      id: '1',
      serviceName: 'Nettoyage de maison',
      clientName: 'Fatima Al-Zahra',
      amount: 5000,
      dateTime: DateTime.now().subtract(Duration(hours: 2)),
      paymentMethod: 'Bankily',
      serviceType: ServiceType.direct,
      transactionId: 'BKL123456789',
    ),
    PaymentModel(
      id: '2',
      serviceName: 'Réparation plomberie',
      clientName: 'Mohamed Ould Ahmed',
      amount: 3500,
      dateTime: DateTime.now().subtract(Duration(days: 1)),
      paymentMethod: 'Espèces',
      serviceType: ServiceType.fromTask,
      transactionId: null,
    ),
    PaymentModel(
      id: '3',
      serviceName: 'Jardinage',
      clientName: 'Omar Ba',
      amount: 2800,
      dateTime: DateTime.now().subtract(Duration(days: 3)),
      paymentMethod: 'Sedad',
      serviceType: ServiceType.direct,
      transactionId: 'SDD987654321',
    ),
    PaymentModel(
      id: '4',
      serviceName: 'Garde d\'enfants',
      clientName: 'Aicha Mint Salem',
      amount: 4200,
      dateTime: DateTime.now().subtract(Duration(days: 5)),
      paymentMethod: 'Bankily',
      serviceType: ServiceType.fromTask,
      transactionId: 'BKL456789123',
    ),
    PaymentModel(
      id: '5',
      serviceName: 'Peinture salon',
      clientName: 'Hassan Ould Baba',
      amount: 7500,
      dateTime: DateTime.now().subtract(Duration(days: 8)),
      paymentMethod: 'Sedad',
      serviceType: ServiceType.direct,
      transactionId: 'SDD321654987',
    ),
    PaymentModel(
      id: '6',
      serviceName: 'Lavage auto',
      clientName: 'Ahmed Ould Mohamed',
      amount: 1500,
      dateTime: DateTime.now().subtract(Duration(days: 12)),
      paymentMethod: 'Espèces',
      serviceType: ServiceType.direct,
      transactionId: null,
    ),
  ];
}

// Models
enum ServiceType { direct, fromTask }

class PaymentModel {
  final String id;
  final String serviceName;
  final String clientName;
  final int amount;
  final DateTime dateTime;
  final String paymentMethod;
  final ServiceType serviceType;
  final String? transactionId;

  PaymentModel({
    required this.id,
    required this.serviceName,
    required this.clientName,
    required this.amount,
    required this.dateTime,
    required this.paymentMethod,
    required this.serviceType,
    this.transactionId,
  });
}
