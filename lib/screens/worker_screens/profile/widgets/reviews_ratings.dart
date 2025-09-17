import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class ReviewsRatingsScreen extends StatefulWidget {
  @override
  _ReviewsRatingsScreenState createState() => _ReviewsRatingsScreenState();
}

class _ReviewsRatingsScreenState extends State<ReviewsRatingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ReviewModel> filteredReviews = [];
  String selectedFilter = 'all'; // all, 5, 4, 3, 2, 1

  @override
  void initState() {
    super.initState();
    filteredReviews = _reviews;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterReviews(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredReviews = _getFilteredByRating();
      } else {
        filteredReviews = _getFilteredByRating()
            .where((review) =>
                review.clientName.toLowerCase().contains(query.toLowerCase()) ||
                review.comment.toLowerCase().contains(query.toLowerCase()) ||
                review.serviceName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  List<ReviewModel> _getFilteredByRating() {
    if (selectedFilter == 'all') {
      return _reviews;
    } else {
      int rating = int.parse(selectedFilter);
      return _reviews.where((review) => review.rating == rating).toList();
    }
  }

  void _applyRatingFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      _filterReviews(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Avis & Évaluations'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Statistics summary
          _buildRatingsSummary(context, isDark),

          // Search bar
          _buildSearchBar(context, isDark),

          // Rating filters
          _buildRatingFilters(context, isDark),

          // Reviews list
          Expanded(
            child: filteredReviews.isEmpty
                ? _buildEmptyState(context, isDark)
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredReviews.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final review = filteredReviews[index];
                      return _buildReviewCard(review, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSummary(BuildContext context, bool isDark) {
    final totalReviews = _reviews.length;
    final averageRating = _reviews.isEmpty
        ? 0.0
        : _reviews.fold<double>(0, (sum, review) => sum + review.rating) /
            totalReviews;

    // Count by rating
    Map<int, int> ratingCounts = {};
    for (int i = 1; i <= 5; i++) {
      ratingCounts[i] = _reviews.where((r) => r.rating == i).length;
    }

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
          Row(
            children: [
              // Overall rating
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.primaryColor,
                              ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < averageRating.floor()
                              ? Icons.star
                              : (index < averageRating
                                  ? Icons.star_half
                                  : Icons.star_border),
                          color: Colors.amber,
                          size: 24,
                        );
                      }),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$totalReviews avis',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

              // Rating breakdown
              Expanded(
                flex: 3,
                child: Column(
                  children: List.generate(5, (index) {
                    final rating = 5 - index;
                    final count = ratingCounts[rating] ?? 0;
                    final percentage =
                        totalReviews > 0 ? count / totalReviews : 0.0;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '$rating',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.star, size: 12, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor:
                                  isDark ? Colors.white12 : Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ThemeColors.primaryColor,
                              ),
                              minHeight: 4,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '$count',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkSurface : Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterReviews,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Rechercher dans les avis...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.white54 : Colors.grey[500],
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _filterReviews('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRatingFilters(BuildContext context, bool isDark) {
    final filters = [
      {'value': 'all', 'label': 'Tous'},
      {'value': '5', 'label': '5⭐'},
      {'value': '4', 'label': '4⭐'},
      {'value': '3', 'label': '3⭐'},
      {'value': '2', 'label': '2⭐'},
      {'value': '1', 'label': '1⭐'},
    ];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      height: 40,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['value'];

          return FilterChip(
            label: Text(filter['label']!),
            selected: isSelected,
            onSelected: (_) => _applyRatingFilter(filter['value']!),
            showCheckmark: false,
            selectedColor: ThemeColors.primaryColor.withOpacity(0.1),
            side: BorderSide(
              color: isSelected
                  ? ThemeColors.primaryColor
                  : (isDark ? ThemeColors.darkBorder : Colors.grey[300]!),
            ),
            labelStyle: TextStyle(
              color: isSelected
                  ? ThemeColors.primaryColor
                  : (isDark ? Colors.white : Colors.black87),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review, bool isDark) {
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
          // Header avec info client et rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    isDark ? ThemeColors.darkSurface : Colors.grey[200],
                backgroundImage: review.clientAvatar != null
                    ? NetworkImage(review.clientAvatar!)
                    : null,
                child: review.clientAvatar == null
                    ? Icon(
                        Icons.person,
                        size: 20,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      )
                    : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clientName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                    ),
                    Text(
                      _formatDate(review.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white54 : Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getServiceTypeColor(review.serviceType)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      review.serviceName,
                      style: TextStyle(
                        color: _getServiceTypeColor(review.serviceType),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),

          // Commentaire
          if (review.comment.isNotEmpty) ...[
            Text(
              review.comment,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    height: 1.4,
                  ),
            ),
            SizedBox(height: 12),
          ],

          // Service details et prix
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
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 16,
                        color: isDark ? Colors.white54 : Colors.grey[500],
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Service: ${review.serviceName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                ),
                if (review.servicePrice != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: ThemeColors.successColor,
                      ),
                      Text(
                        '${review.servicePrice} MRU',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ThemeColors.successColor,
                              fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 64,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucun avis trouvé',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Vos évaluations clients\napparaîtront ici',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Color _getServiceTypeColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'plomberie':
        return Colors.blue;
      case 'électricité':
        return Colors.orange;
      case 'nettoyage':
        return Colors.green;
      case 'jardinage':
        return Colors.lightGreen;
      case 'garde d\'enfants':
        return Colors.pink;
      case 'réparation':
        return Colors.red;
      default:
        return ThemeColors.primaryColor;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "Il y a ${weeks == 1 ? '1 semaine' : '$weeks semaines'}";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "Il y a ${months == 1 ? '1 mois' : '$months mois'}";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  // Sample data
  final List<ReviewModel> _reviews = [
    ReviewModel(
      id: '1',
      clientName: 'Fatima Al-Zahra',
      clientAvatar: null,
      rating: 5,
      comment:
          'Excellent travail! Mohamed est très professionnel et ponctuel. La réparation de plomberie a été faite rapidement et proprement. Je le recommande vivement.',
      serviceName: 'Réparation plomberie',
      serviceType: 'Plomberie',
      servicePrice: 3500,
      date: DateTime.now().subtract(Duration(days: 2)),
    ),
    ReviewModel(
      id: '2',
      clientName: 'Ahmed Ould Salem',
      clientAvatar: null,
      rating: 4,
      comment:
          'Bon travail dans l\'ensemble. L\'installation électrique s\'est bien passée, juste un peu de retard sur l\'horaire prévu.',
      serviceName: 'Installation électrique',
      serviceType: 'Électricité',
      servicePrice: 4200,
      date: DateTime.now().subtract(Duration(days: 5)),
    ),
    ReviewModel(
      id: '3',
      clientName: 'Mariem Mint Mohamed',
      clientAvatar: null,
      rating: 5,
      comment:
          'Parfait! Mohamed a réparé ma fuite d\'eau très rapidement. Prix correct et service de qualité.',
      serviceName: 'Réparation fuite',
      serviceType: 'Plomberie',
      servicePrice: 2800,
      date: DateTime.now().subtract(Duration(days: 8)),
    ),
    ReviewModel(
      id: '4',
      clientName: 'Hassan Ba',
      clientAvatar: null,
      rating: 4,
      comment:
          'Très satisfait du service. Mohamed connaît bien son métier et explique bien ce qu\'il fait.',
      serviceName: 'Maintenance électrique',
      serviceType: 'Électricité',
      servicePrice: 2500,
      date: DateTime.now().subtract(Duration(days: 12)),
    ),
    ReviewModel(
      id: '5',
      clientName: 'Aicha Mint Ali',
      clientAvatar: null,
      rating: 3,
      comment:
          'Le travail a été fait correctement mais le délai était un peu long. Sinon pas de problème.',
      serviceName: 'Réparation générale',
      serviceType: 'Réparation',
      servicePrice: 3000,
      date: DateTime.now().subtract(Duration(days: 15)),
    ),
    ReviewModel(
      id: '6',
      clientName: 'Omar Ould Ahmed',
      clientAvatar: null,
      rating: 5,
      comment:
          'Excellent! Mohamed a installé ma nouvelle prise électrique parfaitement. Très professionnel et prix raisonnable.',
      serviceName: 'Installation prise',
      serviceType: 'Électricité',
      servicePrice: 1800,
      date: DateTime.now().subtract(Duration(days: 20)),
    ),
  ];
}

// Review model
class ReviewModel {
  final String id;
  final String clientName;
  final String? clientAvatar;
  final int rating;
  final String comment;
  final String serviceName;
  final String serviceType;
  final int? servicePrice;
  final DateTime date;

  ReviewModel({
    required this.id,
    required this.clientName,
    this.clientAvatar,
    required this.rating,
    required this.comment,
    required this.serviceName,
    required this.serviceType,
    this.servicePrice,
    required this.date,
  });
}
