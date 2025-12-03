// import 'package:flutter/material.dart';
// import '../../core/theme/theme_colors.dart';
// import '../../models/payment_model.dart';
// import '../../models/user_model.dart';
// import '../../services/payment_service.dart';
// import '../../services/auth_api.dart';

// class PaymentHistoryScreen extends StatefulWidget {
//   @override
//   _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
// }

// class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
//   late Future<Map<String, dynamic>> _paymentsFuture;
//   int _currentOffset = 0;
//   final int _limit = 20;
//   List<PaymentModel> _allPayments = [];
//   User? _currentUser;
//   final AuthApi _authApi = AuthApi();

//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUser();
//     _loadPayments();
//   }

//   Future<void> _loadCurrentUser() async {
//     try {
//       final response = await _authApi.getUserProfile();
//       if (response['ok'] == true && response['json'] != null) {
//         setState(() {
//           _currentUser = User.fromJson(response['json']);
//         });
//       }
//     } catch (e) {
//       print('Error loading current user: $e');
//     }
//   }

//   void _loadPayments() {
//     _paymentsFuture = paymentService.getMyPayments(
//       limit: _limit,
//       offset: _currentOffset,
//     );
//   }

//   void _loadMore() {
//     setState(() {
//       _currentOffset += _limit;
//       _loadPayments();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Historique des Paiements'),
//         centerTitle: true,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _paymentsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return _buildLoadingState();
//           }

//           if (snapshot.hasError) {
//             return _buildErrorState(snapshot.error.toString(), isDark);
//           }

//           if (!snapshot.hasData || snapshot.data!['ok'] == false) {
//             return _buildErrorState('Échec du chargement des données', isDark);
//           }

//           final payments = snapshot.data!['payments'] as List<PaymentModel>;

//           if (payments.isEmpty) {
//             return _buildEmptyState(context, isDark);
//           }

//           _allPayments = payments;

//           return Column(
//             children: [
//               _buildSummaryCard(context, payments, isDark),
//               Expanded(
//                 child: ListView.separated(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   itemCount: payments.length + 1,
//                   separatorBuilder: (context, index) => SizedBox(height: 12),
//                   itemBuilder: (context, index) {
//                     if (index == payments.length) {
//                       return Padding(
//                         padding: EdgeInsets.symmetric(vertical: 16),
//                         child: Center(
//                           child: ElevatedButton(
//                             onPressed: _loadMore,
//                             child: Text('Charger plus'),
//                           ),
//                         ),
//                       );
//                     }
//                     return _buildPaymentCard(payments[index], isDark);
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text('Chargement en cours...'),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String errorMessage, bool isDark) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 64,
//             color: Colors.red,
//           ),
//           SizedBox(height: 16),
//           Text(
//             'Une erreur est survenue',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           SizedBox(height: 8),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 32),
//             child: Text(
//               errorMessage,
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: isDark ? Colors.white70 : Colors.grey[600],
//                   ),
//             ),
//           ),
//           SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 _currentOffset = 0;
//                 _loadPayments();
//               });
//             },
//             child: Text('Réessayer'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard(
//       BuildContext context, List<PaymentModel> payments, bool isDark) {
//     final totalAmount = payments.fold<double>(
//       0,
//       (sum, p) => sum + p.amount,
//     );
//     final paymentsCount = payments.length;

//     return Container(
//       margin: EdgeInsets.all(16),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: isDark ? ThemeColors.darkCardBackground : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? ThemeColors.shadowDark : ThemeColors.shadowLight,
//             blurRadius: 10,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildSummaryItem(
//               context,
//               'Montant Total',
//               '${totalAmount.toStringAsFixed(0)} MRU',
//               Icons.attach_money,
//               isDark,
//             ),
//           ),
//           SizedBox(width: 20),
//           Expanded(
//             child: _buildSummaryItem(
//               context,
//               'Nombre d\'opérations',
//               '$paymentsCount',
//               Icons.receipt_long,
//               isDark,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryItem(BuildContext context, String label, String value,
//       IconData icon, bool isDark) {
//     return Column(
//       children: [
//         Icon(
//           icon,
//           color: ThemeColors.primaryColor,
//           size: 24,
//         ),
//         SizedBox(height: 8),
//         Text(
//           value,
//           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 color: isDark
//                     ? ThemeColors.darkTextPrimary
//                     : ThemeColors.lightTextPrimary,
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//         SizedBox(height: 4),
//         Text(
//           label,
//           textAlign: TextAlign.center,
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: isDark
//                     ? ThemeColors.darkTextSecondary
//                     : ThemeColors.lightTextSecondary,
//               ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPaymentCard(PaymentModel payment, bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark ? ThemeColors.darkCardBackground : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? ThemeColors.shadowDark : ThemeColors.shadowLight,
//             blurRadius: 8,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with service info
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: ThemeColors.primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   _getStatusIcon(payment.status),
//                   color: _getStatusColor(payment.status),
//                   size: 24,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       payment.taskTitle,
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: isDark ? Colors.white : Colors.black,
//                           ),
//                     ),
//                     SizedBox(height: 4),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: _getServiceTypeColor(payment.serviceType)
//                             .withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         payment.serviceType,
//                         style: TextStyle(
//                           color: _getServiceTypeColor(payment.serviceType),
//                           fontSize: 11,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     '${payment.amount.toStringAsFixed(0)} MRU',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: _getStatusColor(payment.status),
//                         ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     _getStatusText(payment.status),
//                     style: TextStyle(
//                       color: _getStatusColor(payment.status),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 16),

//           // Client/Worker info
//           Container(
//             padding: EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: isDark
//                   ? ThemeColors.darkSurface.withOpacity(0.5)
//                   : Colors.grey[50],
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.person_outline,
//                   size: 18,
//                   color: ThemeColors.primaryColor,
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   'Avec : ',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: isDark ? Colors.white54 : Colors.grey[600],
//                       ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     _getOtherPersonName(payment),
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: isDark ? Colors.white : Colors.black,
//                         ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 12),

//           // Payment details
//           Row(
//             children: [
//               Expanded(
//                 child: _buildDetailItem(
//                   context,
//                   Icons.calendar_today_outlined,
//                   _formatDateTime(payment.createdAt),
//                   isDark,
//                 ),
//               ),
//               SizedBox(width: 16),
//               Expanded(
//                 child: _buildDetailItem(
//                   context,
//                   _getPaymentMethodIcon(payment.paymentMethodDisplay),
//                   payment.paymentMethodDisplay,
//                   isDark,
//                 ),
//               ),
//             ],
//           ),

//           // Transaction ID (only for non-cash payments)
//           if (payment.transactionId != null &&
//               payment.transactionId!.isNotEmpty) ...[
//             SizedBox(height: 12),
//             Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: isDark
//                     ? ThemeColors.darkSurface.withOpacity(0.3)
//                     : Colors.grey[100],
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.tag,
//                     size: 14,
//                     color: isDark ? Colors.white54 : Colors.grey[500],
//                   ),
//                   SizedBox(width: 6),
//                   Text(
//                     'N° Transaction : ',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: isDark ? Colors.white54 : Colors.grey[500],
//                         ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       payment.transactionId!,
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: isDark ? Colors.white70 : Colors.grey[700],
//                             fontFamily: 'monospace',
//                             fontWeight: FontWeight.w500,
//                           ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailItem(
//       BuildContext context, IconData icon, String text, bool isDark) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 16,
//           color: isDark ? Colors.white54 : Colors.grey[500],
//         ),
//         SizedBox(width: 6),
//         Expanded(
//           child: Text(
//             text,
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: isDark ? Colors.white70 : Colors.grey[700],
//                   fontWeight: FontWeight.w500,
//                 ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyState(BuildContext context, bool isDark) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.receipt_long_outlined,
//             size: 64,
//             color: isDark ? Colors.white38 : Colors.grey[400],
//           ),
//           SizedBox(height: 16),
//           Text(
//             'Aucun paiement',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   color: isDark ? Colors.white70 : Colors.grey[600],
//                 ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Vos paiements apparaîtront ici\nlorsque vous commencerez à utiliser l\'application',
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: isDark ? Colors.white54 : Colors.grey[500],
//                 ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getServiceTypeColor(String type) {
//     // Vous pouvez personnaliser les couleurs selon le type de service
//     switch (type.toLowerCase()) {
//       case 'plomberie':
//         return Colors.blue;
//       case 'électricité':
//         return Colors.amber;
//       case 'jardinage':
//         return Colors.green;
//       case 'ménage':
//         return Colors.purple;
//       case 'peinture':
//         return Colors.orange;
//       default:
//         return Colors.blue;
//     }
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'completed':
//         return ThemeColors.successColor;
//       case 'pending':
//         return Colors.orange;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getStatusIcon(String status) {
//     switch (status.toLowerCase()) {
//       case 'completed':
//         return Icons.check_circle;
//       case 'pending':
//         return Icons.access_time;
//       case 'cancelled':
//         return Icons.cancel;
//       default:
//         return Icons.info;
//     }
//   }

//   String _getStatusText(String status) {
//     switch (status.toLowerCase()) {
//       case 'completed':
//         return 'Complété';
//       case 'pending':
//         return 'En attente';
//       case 'cancelled':
//         return 'Annulé';
//       default:
//         return status;
//     }
//   }

//   String _getOtherPersonName(PaymentModel payment) {
//     // ✅ الحل الصحيح: عرض الشخص الآخر حسب دور المستخدم الحالي
//     if (_currentUser == null) {
//       // في حالة عدم وجود بيانات المستخدم، نعرض المتلقي افتراضياً
//       return payment.receiverName.isNotEmpty
//           ? payment.receiverName
//           : payment.payerName;
//     }

//     // إذا كان المستخدم الحالي هو العامل (worker) -> نعرض العميل (payer)
//     if (_currentUser!.isWorker) {
//       return payment.payerName.isNotEmpty ? payment.payerName : 'Client';
//     }

//     // إذا كان المستخدم الحالي هو العميل (client) -> نعرض العامل (receiver)
//     if (_currentUser!.isClient) {
//       return payment.receiverName.isNotEmpty
//           ? payment.receiverName
//           : 'Travailleur';
//     }

//     // الحالة الافتراضية
//     return payment.receiverName.isNotEmpty
//         ? payment.receiverName
//         : payment.payerName;
//   }

//   IconData _getPaymentMethodIcon(String method) {
//     switch (method.toLowerCase()) {
//       case 'especes':
//       case 'espèces':
//         return Icons.money;
//       case 'bankily':
//         return Icons.account_balance_wallet;
//       case 'sedad':
//       case 'sédad':
//         return Icons.credit_card;
//       default:
//         return Icons.payment;
//     }
//   }

//   String _formatDateTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);

//     String dateStr;
//     if (difference.inDays == 0) {
//       dateStr = "Aujourd'hui";
//     } else if (difference.inDays == 1) {
//       dateStr = "Hier";
//     } else if (difference.inDays < 7) {
//       dateStr = "Il y a ${difference.inDays} jours";
//     } else {
//       // Format français : jour/mois/année
//       dateStr =
//           "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
//     }

//     String timeStr =
//         "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
//     return "$dateStr à $timeStr";
//   }
// }
