import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../models/review_model.dart';
import '../../../../services/task_service.dart';

class ReviewsRatingsScreen extends StatefulWidget {
  @override
  _ReviewsRatingsScreenState createState() => _ReviewsRatingsScreenState();
}

class _ReviewsRatingsScreenState extends State<ReviewsRatingsScreen> {
  final TextEditingController _searchController = TextEditingController();

  late Future<Map<String, dynamic>> _reviewsFuture;
  List<ReviewModel> _allReviews = [];
  List<ReviewModel> filteredReviews = [];
  ReviewStatisticsModel? _statistics;

  String selectedFilter = 'all'; // all, 5, 4, 3, 2, 1
  int _currentOffset = 0;
  final int _limit = 20;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadReviews({bool loadMore = false}) {
    if (loadMore) {
      _currentOffset += _limit;
    } else {
      _currentOffset = 0;
    }

    int? ratingFilter =
        selectedFilter != 'all' ? int.parse(selectedFilter) : null;

    _reviewsFuture = taskService.getMyReviews(
      rating: ratingFilter,
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      ordering: '-created_at',
      limit: _limit,
      offset: _currentOffset,
    );
  }

  void _filterReviews(String query) {
    setState(() {
      _loadReviews();
    });
  }

  void _applyRatingFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      _currentOffset = 0;
      _loadReviews();
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString(), isDark);
          }

          if (!snapshot.hasData || snapshot.data!['ok'] == false) {
            return _buildErrorState(
              snapshot.data?['error'] ?? 'Failed to load data',
              isDark,
            );
          }

          final reviews = snapshot.data!['reviews'] as List<ReviewModel>;
          final stats = snapshot.data!['statistics'] as ReviewStatisticsModel;

          _allReviews = reviews;
          filteredReviews = reviews;
          _statistics = stats;

          if (reviews.isEmpty &&
              selectedFilter == 'all' &&
              _searchController.text.isEmpty) {
            return _buildEmptyState(context, isDark);
          }

          return Column(
            children: [
              // Statistics summary
              _buildRatingsSummary(context, stats, isDark),

              // Search bar
              _buildSearchBar(context, isDark),

              // Rating filters
              _buildRatingFilters(context, isDark),

              // Reviews list
              Expanded(
                child: filteredReviews.isEmpty
                    ? _buildNoResultsState(context, isDark)
                    : ListView.separated(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredReviews.length + 1,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          if (index == filteredReviews.length) {
                            // Load more button
                            if (filteredReviews.length >= _limit) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: _isLoadingMore
                                      ? CircularProgressIndicator()
                                      : ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _isLoadingMore = true;
                                              _loadReviews(loadMore: true);
                                            });
                                          },
                                          child: Text('Charger plus'),
                                        ),
                                ),
                              );
                            }
                            return SizedBox.shrink();
                          }
                          final review = filteredReviews[index];
                          return _buildReviewCard(review, isDark);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading ratings...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'An error occurred',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentOffset = 0;
                _loadReviews();
              });
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSummary(
      BuildContext context, ReviewStatisticsModel stats, bool isDark) {
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
                      stats.averageRating.toStringAsFixed(1),
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
                          index < stats.averageRating.floor()
                              ? Icons.star
                              : (index < stats.averageRating
                                  ? Icons.star_half
                                  : Icons.star_border),
                          color: Colors.amber,
                          size: 24,
                        );
                      }),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${stats.totalReviews} avis',
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
                    final count = stats.getRatingCount(rating);
                    final percentage = stats.getRatingPercentage(rating) / 100;

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
        onChanged: (value) {
          // Debounce search
          Future.delayed(Duration(milliseconds: 500), () {
            if (_searchController.text == value) {
              _filterReviews(value);
            }
          });
        },
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
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
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
                      _formatDate(review.createdAt),
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
                      color: ThemeColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      review.taskTitle,
                      style: TextStyle(
                        color: ThemeColors.primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),

          // Commentaire
          if (review.reviewText.isNotEmpty) ...[
            Text(
              review.reviewText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    height: 1.4,
                  ),
            ),
            SizedBox(height: 12),
          ],

          // Task details
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
                  Icons.work_outline,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tâche: ${review.taskTitle}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                  ),
                ),
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
            'Aucun avis reçu',
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

  Widget _buildNoResultsState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
          ),
        ],
      ),
    );
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
}
