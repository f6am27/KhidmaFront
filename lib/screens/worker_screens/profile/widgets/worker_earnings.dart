// import 'package:flutter/material.dart';
// import '../../../../../constants/colors.dart';

// class WorkerEarningsScreen extends StatefulWidget {
//   @override
//   _WorkerEarningsScreenState createState() => _WorkerEarningsScreenState();
// }

// class _WorkerEarningsScreenState extends State<WorkerEarningsScreen> {
//   String selectedPeriod = 'Ce mois';
//   final List<String> periods = [
//     'Cette semaine',
//     'Ce mois',
//     'Ce trimestre',
//     'Cette année'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         title: Text(
//           'Mes Revenus',
//           style: TextStyle(
//             color: AppColors.textPrimary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Period Selector
//           _buildPeriodSelector(),

//           // Summary Cards
//           _buildSummaryCards(),

//           // Earnings Chart Section
//           _buildChartSection(),

//           // Recent Earnings List
//           Expanded(child: _buildEarningsList()),
//         ],
//       ),
//     );
//   }

//   Widget _buildPeriodSelector() {
//     return Container(
//       height: 50,
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: periods.length,
//         itemBuilder: (context, index) {
//           final period = periods[index];
//           final isSelected = selectedPeriod == period;
//           return GestureDetector(
//             onTap: () => setState(() => selectedPeriod = period),
//             child: Container(
//               margin: EdgeInsets.only(right: 8),
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? AppColors.primaryPurple
//                     : AppColors.cardBackground,
//                 borderRadius: BorderRadius.circular(25),
//                 border: Border.all(
//                   color: isSelected
//                       ? AppColors.primaryPurple
//                       : AppColors.lightGray,
//                 ),
//               ),
//               child: Text(
//                 period,
//                 style: TextStyle(
//                   color: isSelected ? Colors.white : AppColors.textPrimary,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSummaryCards() {
//     return Container(
//       margin: EdgeInsets.all(16),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildSummaryCard(
//               title: 'Revenus totaux',
//               amount: '48,500 MRU',
//               subtitle: '+12% vs mois dernier',
//               icon: Icons.account_balance_wallet,
//               color: AppColors.green,
//               isPositive: true,
//             ),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: _buildSummaryCard(
//               title: 'Missions payées',
//               amount: '12',
//               subtitle: 'sur 14 missions',
//               icon: Icons.check_circle,
//               color: AppColors.cyan,
//               isPositive: true,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard({
//     required String title,
//     required String amount,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required bool isPositive,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, color: color, size: 20),
//               ),
//               Spacer(),
//               Icon(
//                 isPositive ? Icons.trending_up : Icons.trending_down,
//                 color: isPositive ? AppColors.green : Colors.red,
//                 size: 16,
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Text(
//             amount,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: AppColors.textSecondary,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             subtitle,
//             style: TextStyle(
//               fontSize: 11,
//               color: isPositive ? AppColors.green : Colors.red,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChartSection() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Évolution des revenus',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: AppColors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '+12%',
//                   style: TextStyle(
//                     color: AppColors.green,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           // Simple chart representation
//           Container(
//             height: 150,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 _buildChartBar(
//                     'S1', 0.4, AppColors.primaryPurple.withOpacity(0.7)),
//                 _buildChartBar(
//                     'S2', 0.6, AppColors.primaryPurple.withOpacity(0.7)),
//                 _buildChartBar(
//                     'S3', 0.8, AppColors.primaryPurple.withOpacity(0.7)),
//                 _buildChartBar('S4', 1.0, AppColors.primaryPurple),
//               ],
//             ),
//           ),
//           SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: AppColors.lightGray.withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 12,
//                       height: 12,
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryPurple,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       'Revenus hebdomadaires',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChartBar(String label, double height, Color color) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         Container(
//           width: 24,
//           height: height * 120,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         SizedBox(height: 8),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: AppColors.textSecondary,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEarningsList() {
//     return Container(
//       margin: EdgeInsets.only(top: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               'Paiements récents',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Expanded(
//             child: ListView.separated(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               itemCount: _earnings.length,
//               separatorBuilder: (context, index) => SizedBox(height: 12),
//               itemBuilder: (context, index) {
//                 final earning = _earnings[index];
//                 return _buildEarningCard(earning);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEarningCard(EarningModel earning) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: _getServiceColor(earning.serviceType).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   _getServiceIcon(earning.serviceType),
//                   color: _getServiceColor(earning.serviceType),
//                   size: 20,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       earning.serviceName,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       earning.clientName,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     '${earning.amount} MRU',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.green,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: _getPaymentStatusColor(earning.paymentStatus)
//                           .withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       _getPaymentStatusText(earning.paymentStatus),
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                         color: _getPaymentStatusColor(earning.paymentStatus),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           Row(
//             children: [
//               Icon(
//                 Icons.calendar_today_outlined,
//                 size: 14,
//                 color: AppColors.textSecondary,
//               ),
//               SizedBox(width: 4),
//               Text(
//                 _formatDate(earning.dateCompleted),
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               Spacer(),
//               Icon(
//                 _getPaymentMethodIcon(earning.paymentMethod),
//                 size: 14,
//                 color: AppColors.textSecondary,
//               ),
//               SizedBox(width: 4),
//               Text(
//                 earning.paymentMethod,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getServiceColor(String serviceType) {
//     switch (serviceType.toLowerCase()) {
//       case 'nettoyage':
//         return AppColors.cyan;
//       case 'jardinage':
//         return AppColors.green;
//       case 'plomberie':
//         return Colors.blue;
//       case 'garde d\'enfants':
//         return AppColors.orange;
//       default:
//         return AppColors.primaryPurple;
//     }
//   }

//   IconData _getServiceIcon(String serviceType) {
//     switch (serviceType.toLowerCase()) {
//       case 'nettoyage':
//         return Icons.cleaning_services;
//       case 'jardinage':
//         return Icons.grass;
//       case 'plomberie':
//         return Icons.plumbing;
//       case 'garde d\'enfants':
//         return Icons.child_care;
//       default:
//         return Icons.work_outline;
//     }
//   }

//   Color _getPaymentStatusColor(PaymentStatus status) {
//     switch (status) {
//       case PaymentStatus.paid:
//         return AppColors.green;
//       case PaymentStatus.pending:
//         return AppColors.orange;
//       case PaymentStatus.cancelled:
//         return Colors.red;
//     }
//   }

//   String _getPaymentStatusText(PaymentStatus status) {
//     switch (status) {
//       case PaymentStatus.paid:
//         return 'PAYÉ';
//       case PaymentStatus.pending:
//         return 'EN ATTENTE';
//       case PaymentStatus.cancelled:
//         return 'ANNULÉ';
//     }
//   }

//   IconData _getPaymentMethodIcon(String method) {
//     switch (method.toLowerCase()) {
//       case 'espèces':
//         return Icons.money;
//       case 'bankily':
//         return Icons.account_balance_wallet;
//       case 'sedad':
//         return Icons.credit_card;
//       default:
//         return Icons.payment;
//     }
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays == 0) {
//       return 'Aujourd\'hui';
//     } else if (difference.inDays == 1) {
//       return 'Hier';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} jours';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }

//   // Sample data
//   final List<EarningModel> _earnings = [
//     EarningModel(
//       id: '1',
//       serviceName: 'Nettoyage appartement 3 pièces',
//       serviceType: 'Nettoyage',
//       clientName: 'Mme. Aicha Mint Ahmed',
//       amount: 8500,
//       dateCompleted: DateTime.now().subtract(Duration(hours: 3)),
//       paymentMethod: 'Bankily',
//       paymentStatus: PaymentStatus.paid,
//     ),
//     EarningModel(
//       id: '2',
//       serviceName: 'Jardinage et taille d\'arbres',
//       serviceType: 'Jardinage',
//       clientName: 'M. Mohamed Vall',
//       amount: 6000,
//       dateCompleted: DateTime.now().subtract(Duration(days: 1)),
//       paymentMethod: 'Espèces',
//       paymentStatus: PaymentStatus.paid,
//     ),
//     EarningModel(
//       id: '3',
//       serviceName: 'Réparation robinet cuisine',
//       serviceType: 'Plomberie',
//       clientName: 'Mme. Fatimetou Mint Sid Ahmed',
//       amount: 4500,
//       dateCompleted: DateTime.now().subtract(Duration(days: 2)),
//       paymentMethod: 'Sedad',
//       paymentStatus: PaymentStatus.pending,
//     ),
//     EarningModel(
//       id: '4',
//       serviceName: 'Garde d\'enfants soirée',
//       serviceType: 'Garde d\'enfants',
//       clientName: 'M. Abdellahi Ould Cheikh',
//       amount: 7200,
//       dateCompleted: DateTime.now().subtract(Duration(days: 3)),
//       paymentMethod: 'Bankily',
//       paymentStatus: PaymentStatus.paid,
//     ),
//     EarningModel(
//       id: '5',
//       serviceName: 'Nettoyage bureau',
//       serviceType: 'Nettoyage',
//       clientName: 'Mme. Mariem Mint Brahim',
//       amount: 5500,
//       dateCompleted: DateTime.now().subtract(Duration(days: 5)),
//       paymentMethod: 'Espèces',
//       paymentStatus: PaymentStatus.paid,
//     ),
//     EarningModel(
//       id: '6',
//       serviceName: 'Entretien jardin mensuel',
//       serviceType: 'Jardinage',
//       clientName: 'M. Sidi Mohamed Ould Ahmed',
//       amount: 12000,
//       dateCompleted: DateTime.now().subtract(Duration(days: 7)),
//       paymentMethod: 'Sedad',
//       paymentStatus: PaymentStatus.paid,
//     ),
//   ];
// }

// // Models
// enum PaymentStatus { paid, pending, cancelled }

// class EarningModel {
//   final String id;
//   final String serviceName;
//   final String serviceType;
//   final String clientName;
//   final int amount;
//   final DateTime dateCompleted;
//   final String paymentMethod;
//   final PaymentStatus paymentStatus;

//   EarningModel({
//     required this.id,
//     required this.serviceName,
//     required this.serviceType,
//     required this.clientName,
//     required this.amount,
//     required this.dateCompleted,
//     required this.paymentMethod,
//     required this.paymentStatus,
//   });
// }
