import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class FavoriteProvidersScreen extends StatefulWidget {
  @override
  _FavoriteProvidersScreenState createState() =>
      _FavoriteProvidersScreenState();
}

class _FavoriteProvidersScreenState extends State<FavoriteProvidersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProviderModel> filteredProviders = [];

  @override
  void initState() {
    super.initState();
    filteredProviders = _favoriteProviders;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProviders(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProviders = _favoriteProviders;
      } else {
        filteredProviders = _favoriteProviders
            .where((provider) =>
                provider.name.toLowerCase().contains(query.toLowerCase()) ||
                provider.services.any((service) =>
                    service.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Prestataires Favoris'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(context, isDark),

          // Providers list
          Expanded(
            child: filteredProviders.isEmpty
                ? _buildEmptyState(context, isDark)
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredProviders.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final provider = filteredProviders[index];
                      return _buildProviderCard(provider, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkSurface : Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterProviders,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Rechercher un prestataire...',
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
                    _filterProviders('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildProviderCard(ProviderModel provider, bool isDark) {
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
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    isDark ? ThemeColors.darkSurface : Colors.grey[200],
                backgroundImage: provider.imageUrl != null
                    ? NetworkImage(provider.imageUrl!)
                    : null,
                child: provider.imageUrl == null
                    ? Icon(
                        Icons.person,
                        size: 32,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      )
                    : null,
              ),
              SizedBox(width: 16),

              // Provider info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _toggleFavorite(provider),
                          icon: Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < provider.rating.floor()
                                  ? Icons.star
                                  : (index < provider.rating
                                      ? Icons.star_half
                                      : Icons.star_border),
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${provider.rating.toStringAsFixed(1)} (${provider.reviewCount} avis)',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    isDark ? Colors.white54 : Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.grey[500],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            provider.location,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey[500],
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Services
          Text(
            'Services:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.services
                .map((service) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ThemeColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ThemeColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        service,
                        style: TextStyle(
                          color: ThemeColors.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 12),

          // Price range
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 16,
                color: ThemeColors.primaryColor,
              ),
              Text(
                'À partir de ${provider.startingPrice} MRU',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: ThemeColors.primaryColor,
                    ),
              ),
              Spacer(),
              Text(
                'Dernière activité: ${_formatLastSeen(provider.lastSeen)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.grey[500],
                    ),
              ),
            ],
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
            Icons.favorite_border,
            size: 64,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucun prestataire favori',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Vos prestataires favoris apparaîtront ici',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 5) {
      return 'maintenant';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'hier';
    } else {
      return '${difference.inDays}j';
    }
  }

  void _toggleFavorite(ProviderModel provider) {
    setState(() {
      _favoriteProviders.remove(provider);
      filteredProviders.remove(provider);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${provider.name} retiré des favoris'),
        backgroundColor: ThemeColors.primaryColor,
        action: SnackBarAction(
          label: 'Annuler',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _favoriteProviders.add(provider);
              if (_searchController.text.isEmpty) {
                filteredProviders = _favoriteProviders;
              } else {
                _filterProviders(_searchController.text);
              }
            });
          },
        ),
      ),
    );
  }

  // Sample data
  static List<ProviderModel> _favoriteProviders = [
    ProviderModel(
      id: '1',
      name: 'Fatima Al-Zahra',
      rating: 4.9,
      reviewCount: 124,
      location: 'Tevragh Zeina, Nouakchott',
      services: ['Nettoyage', 'Ménage', 'Repassage'],
      startingPrice: 2500,
      isOnline: true,
      lastSeen: DateTime.now().subtract(Duration(minutes: 2)),
      imageUrl: null,
    ),
    ProviderModel(
      id: '2',
      name: 'Mohamed Ould Ahmed',
      rating: 4.7,
      reviewCount: 89,
      location: 'Ksar, Nouakchott',
      services: ['Plomberie', 'Électricité', 'Réparations'],
      startingPrice: 3000,
      isOnline: false,
      lastSeen: DateTime.now().subtract(Duration(hours: 3)),
      imageUrl: null,
    ),
    ProviderModel(
      id: '3',
      name: 'Aicha Mint Salem',
      rating: 5.0,
      reviewCount: 67,
      location: 'Sebkha, Nouakchott',
      services: ['Garde d\'enfants', 'Aide aux devoirs'],
      startingPrice: 2000,
      isOnline: true,
      lastSeen: DateTime.now().subtract(Duration(minutes: 15)),
      imageUrl: null,
    ),
    ProviderModel(
      id: '4',
      name: 'Omar Ba',
      rating: 4.8,
      reviewCount: 156,
      location: 'Arafat, Nouakchott',
      services: ['Jardinage', 'Paysagisme', 'Arrosage'],
      startingPrice: 1800,
      isOnline: false,
      lastSeen: DateTime.now().subtract(Duration(days: 1)),
      imageUrl: null,
    ),
  ];
}

// Provider model
class ProviderModel {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final String location;
  final List<String> services;
  final int startingPrice;
  final bool isOnline;
  final DateTime lastSeen;
  final String? imageUrl;

  ProviderModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.services,
    required this.startingPrice,
    required this.isOnline,
    required this.lastSeen,
    this.imageUrl,
  });
}
