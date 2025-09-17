// import 'package:flutter/material.dart';
// import '../../../../../constants/colors.dart';

// class WorkerReviewsScreen extends StatefulWidget {
//   @override
//   _WorkerReviewsScreenState createState() => _WorkerReviewsScreenState();
// }

// class _WorkerReviewsScreenState extends State<WorkerReviewsScreen> {
//   String selectedFilter = 'Tous';
//   final List<String> filters = [
//     'Tous',
//     '5 étoiles',
//     '4 étoiles',
//     '3 étoiles',
//     '2 étoiles',
//     '1 étoile'
//   ];

//   List<ReviewModel> get filteredReviews {
//     if (selectedFilter == 'Tous') return _reviews;

//     int stars = int.parse(selectedFilter.split(' ')[0]);
//     return _reviews.where((review) => review.rating == stars).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         title: Text(
//           'Avis & Évaluations',
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
//           // Rating Overview
//           _buildRatingOverview(),

//           // Filter Tabs
//           _buildFilterTabs(),

//           // Reviews List
//           Expanded(child: _buildReviewsList()),
//         ],
//       ),
//     );
//   }

//   Widget _buildRatingOverview() {
//     return Container(
//       margin: EdgeInsets.all(16),
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppColors.gradientStart, AppColors.gradientEnd],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryPurple.withOpacity(0.2),
//             blurRadius: 15,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Overall Rating
//           Column(
//             children: [
//               Text(
//                 '4.8',
//                 style: TextStyle(
//                   fontSize: 48,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               Row(
//                 children: List.generate(
//                     5,
//                     (index) => Icon(
//                           Icons.star,
//                           color: index < 4
//                               ? Colors.white
//                               : Colors.white.withOpacity(0.3),
//                           size: 20,
//                         )),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Basé sur ${_reviews.length} avis',
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.9),
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(width: 32),

//           // Rating Breakdown
//           Expanded(
//             child: Column(
//               children: [
//                 _buildRatingBar(5, 18, Colors.white),
//                 _buildRatingBar(4, 6, Colors.white),
//                 _buildRatingBar(3, 2, Colors.white),
//                 _buildRatingBar(2, 1, Colors.white),
//                 _buildRatingBar(1, 1, Colors.white),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRatingBar(int stars, int count, Color color) {
//     final total = _reviews.length;
//     final percentage = total > 0 ? count / total : 0.0;

//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Text(
//             '$stars',
//             style: TextStyle(
//               color: color.withOpacity(0.9),
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(width: 8),
//           Expanded(
//             child: Container(
//               height: 6,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(3),
//               ),
//               child: FractionallySizedBox(
//                 alignment: Alignment.centerLeft,
//                 widthFactor: percentage,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: color,
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 8),
//           Text(
//             '$count',
//             style: TextStyle(
//               color: color.withOpacity(0.9),
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterTabs() {
//     return Container(
//       height: 50,
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: filters.length,
//         itemBuilder: (context, index) {
//           final filter = filters[index];
//           final isSelected = selectedFilter == filter;
//           return GestureDetector(
//             onTap: () => setState(() => selectedFilter = filter),
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
//                 filter,
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

//   Widget _buildReviewsList() {
//     final reviews = filteredReviews;

//     if (reviews.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.star_outline,
//               size: 64,
//               color: AppColors.mediumGray,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Aucun avis trouvé',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Aucun avis correspondant à ce filtre',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.separated(
//       padding: EdgeInsets.all(16),
//       itemCount: reviews.length,
//       separatorBuilder: (context, index) => SizedBox(height: 16),
//       itemBuilder: (context, index) {
//         final review = reviews[index];
//         return _buildReviewCard(review);
//       },
//     );
//   }

//   Widget _buildReviewCard(ReviewModel review) {
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
//           // Header with client info and rating
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 20,
//                 backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
//                 child: Icon(
//                   Icons.person,
//                   color: AppColors.primaryPurple,
//                   size: 20,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       review.clientName,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Row(
//                           children: List.generate(
//                               5,
//                               (index) => Icon(
//                                     Icons.star,
//                                     size: 14,
//                                     color: index < review.rating
//                                         ? AppColors.orange
//                                         : AppColors.lightGray,
//                                   )),
//                         ),
//                         SizedBox(width: 8),
//                         Text(
//                           _formatDate(review.dateCreated),
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               if (review.isRecent)
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     'NOUVEAU',
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.green,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           SizedBox(height: 16),

//           // Service info
//           Container(
//             padding: EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppColors.lightGray.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   _getServiceIcon(review.serviceType),
//                   size: 16,
//                   color: AppColors.primaryPurple,
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   review.serviceName,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 16),

//           // Review comment
//           Text(
//             review.comment,
//             style: TextStyle(
//               fontSize: 15,
//               color: AppColors.textSecondary,
//               height: 1.5,
//             ),
//           ),

//           // Helpful badges if positive review
//           if (review.rating >= 4) ...[
//             SizedBox(height: 16),
//             Wrap(
//               spacing: 8,
//               children: review.positiveAspects
//                   .map((aspect) => Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: AppColors.green.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.check, size: 12, color: AppColors.green),
//                             SizedBox(width: 4),
//                             Text(
//                               aspect,
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: AppColors.green,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ))
//                   .toList(),
//             ),
//           ],
//         ],
//       ),
//     );
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
//       case 'bricolage':
//         return Icons.build;
//       default:
//         return Icons.work_outline;
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
//       return 'Il y a ${difference.inDays} jours';
//     } else if (difference.inDays < 30) {
//       final weeks = (difference.inDays / 7).floor();
//       return 'Il y a ${weeks} semaine${weeks > 1 ? 's' : ''}';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }

//   // Sample data
//   final List<ReviewModel> _reviews = [
//     ReviewModel(
//       id: '1',
//       clientName: 'Aicha Mint Salem',
//       rating: 5,
//       comment:
//           'Excellent travail de nettoyage! Omar est très professionnel, ponctuel et minutieux. Mon appartement n\'a jamais été aussi propre. Je le recommande vivement!',
//       serviceName: 'Nettoyage appartement 3 pièces',
//       serviceType: 'Nettoyage',
//       dateCreated: DateTime.now().subtract(Duration(days: 2)),
//       isRecent: true,
//       positiveAspects: ['Ponctuel', 'Professionnel', 'Minutieux'],
//     ),
//     ReviewModel(
//       id: '2',
//       clientName: 'Mohamed Ould Ahmed',
//       rating: 5,
//       comment:
//           'Travail de jardinage impeccable. Omar connaît bien son métier et a transformé mon jardin. Très satisfait du résultat!',
//       serviceName: 'Entretien jardin',
//       serviceType: 'Jardinage',
//       dateCreated: DateTime.now().subtract(Duration(days: 5)),
//       isRecent: false,
//       positiveAspects: ['Compétent', 'Créatif', 'Efficace'],
//     ),
//     ReviewModel(
//       id: '3',
//       clientName: 'Fatima Al-Zahra',
//       rating: 4,
//       comment:
//           'Bon travail de réparation. Omar a résolu le problème rapidement. Peut-être un peu cher mais le résultat est là.',
//       serviceName: 'Réparation robinet',
//       serviceType: 'Plomberie',
//       dateCreated: DateTime.now().subtract(Duration(days: 8)),
//       isRecent: false,
//       positiveAspects: ['Rapide', 'Efficace'],
//     ),
//     ReviewModel(
//       id: '4',
//       clientName: 'Hassan Ould Baba',
//       rating: 5,
//       comment:
//           'Omar s\'est très bien occupé de mes enfants. Ils l\'adorent et moi je suis tranquille quand je le laisse avec eux. Très recommandé!',
//       serviceName: 'Garde d\'enfants soirée',
//       serviceType: 'Garde d\'enfants',
//       dateCreated: DateTime.now().subtract(Duration(days: 12)),
//       isRecent: false,
//       positiveAspects: ['Fiable', 'Patient', 'Bienveillant'],
//     ),
//     ReviewModel(
//       id: '5',
//       clientName: 'Mariem Mint Brahim',
//       rating: 4,
//       comment:
//           'Très bon travail de bricolage. Omar a monté mes meubles rapidement et proprement. Je ferai appel à lui à nouveau.',
//       serviceName: 'Montage meubles IKEA',
//       serviceType: 'Bricolage',
//       dateCreated: DateTime.now().subtract(Duration(days: 15)),
//       isRecent: false,
//       positiveAspects: ['Rapide', 'Soigneux'],
//     ),
//     ReviewModel(
//       id: '6',
//       clientName: 'Sidi Mohamed Ould Ahmed',
//       rating: 5,
//       comment:
//           'Service de nettoyage exceptionnel pour mon bureau. Équipe professionnelle et résultat parfait. Merci Omar!',
//       serviceName: 'Nettoyage bureau',
//       serviceType: 'Nettoyage',
//       dateCreated: DateTime.now().subtract(Duration(days: 18)),
//       isRecent: false,
//       positiveAspects: ['Professionnel', 'Qualité', 'Ponctuel'],
//     ),
//     ReviewModel(
//       id: '7',
//       clientName: 'Khadija Mint Ali',
//       rating: 3,
//       comment:
//           'Travail correct mais Omar était en retard. Le résultat final est satisfaisant mais j\'aurais aimé plus de ponctualité.',
//       serviceName: 'Nettoyage maison',
//       serviceType: 'Nettoyage',
//       dateCreated: DateTime.now().subtract(Duration(days: 22)),
//       isRecent: false,
//       positiveAspects: [],
//     ),
//     ReviewModel(
//       id: '8',
//       clientName: 'Ahmed Ould Salem',
//       rating: 5,
//       comment:
//           'Omar a fait un travail fantastique dans mon jardin. Très créatif et respectueux des plantes. Mon jardin n\'a jamais été aussi beau!',
//       serviceName: 'Aménagement paysager',
//       serviceType: 'Jardinage',
//       dateCreated: DateTime.now().subtract(Duration(days: 25)),
//       isRecent: false,
//       positiveAspects: ['Créatif', 'Respectueux', 'Artistique'],
//     ),
//   ];
// }

// // Review model
// class ReviewModel {
//   final String id;
//   final String clientName;
//   final int rating;
//   final String comment;
//   final String serviceName;
//   final String serviceType;
//   final DateTime dateCreated;
//   final bool isRecent;
//   final List<String> positiveAspects;

//   ReviewModel({
//     required this.id,
//     required this.clientName,
//     required this.rating,
//     required this.comment,
//     required this.serviceName,
//     required this.serviceType,
//     required this.dateCreated,
//     required this.isRecent,
//     required this.positiveAspects,
//   });
// }
