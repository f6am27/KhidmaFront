import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProviderModel> filteredProviders = [];
  String selectedCategory = 'Tous';

  final List<String> categories = [
    'Tous',
    'Nettoyage',
    'Plomberie',
    'Électricité',
    'Jardinage',
    'Peinture',
    'Déménagement',
    'Réparation',
    'Cuisine',
  ];

  @override
  void initState() {
    super.initState();
    filteredProviders = _sampleProviders;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProviders(String query) {
    setState(() {
      var filtered = _sampleProviders;

      // Filter by category
      if (selectedCategory != 'Tous') {
        filtered = filtered
            .where((provider) =>
                provider.services.any((service) => service == selectedCategory))
            .toList();
      }

      // Filter by search query
      if (query.isNotEmpty) {
        filtered = filtered
            .where((provider) =>
                provider.name.toLowerCase().contains(query.toLowerCase()) ||
                provider.services.any((service) =>
                    service.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }

      filteredProviders = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Prestataires favoris'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _showSortOptions(),
            icon: Icon(
              Icons.sort,
              color: ThemeColors.primaryColor,
            ),
            tooltip: 'Trier',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(isDark),

          // Category filter
          _buildCategoryFilter(isDark),

          // Providers list
          Expanded(
            child: filteredProviders.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.separated(
                    padding: EdgeInsets.all(16),
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

  Widget _buildSearchBar(bool isDark) {
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

  Widget _buildCategoryFilter(bool isDark) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Container(
            margin: EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                  _filterProviders(_searchController.text);
                });
              },
              backgroundColor:
                  isDark ? ThemeColors.darkSurface : Colors.grey[200],
              selectedColor: ThemeColors.primaryColor,
              checkmarkColor: Colors.white,
            ),
          );
        },
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
              // Profile picture
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        isDark ? ThemeColors.darkSurface : Colors.grey[200],
                    backgroundImage: provider.profileImage != null
                        ? NetworkImage(provider.profileImage!)
                        : null,
                    child: provider.profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 35,
                            color: isDark ? Colors.white54 : Colors.grey[600],
                          )
                        : null,
                  ),
                  if (provider.isOnline)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? ThemeColors.darkBackground
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  // Verified badge
                  if (provider.isVerified)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
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
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeFromFavorites(provider),
                          icon: Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 24,
                          ),
                          tooltip: 'Retirer des favoris',
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
                        SizedBox(width: 6),
                        Text(
                          '${provider.rating} (${provider.reviewCount})',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    isDark ? Colors.white54 : Colors.grey[600],
                              ),
                        ),
                        if (provider.isOnline) ...[
                          SizedBox(width: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'En ligne',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Services
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: provider.services.map((service) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ThemeColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  service,
                  style: TextStyle(
                    color: ThemeColors.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12),

          // Stats
          Row(
            children: [
              Icon(
                Icons.work_history,
                size: 16,
                color: ThemeColors.primaryColor,
              ),
              SizedBox(width: 6),
              Text(
                '${provider.completedJobs} missions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  provider.location,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.grey[500],
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _contactProvider(provider),
                  icon: Icon(
                    Icons.chat,
                    size: 16,
                    color: ThemeColors.primaryColor,
                  ),
                  label: Text(
                    'Contacter',
                    style: TextStyle(color: ThemeColors.primaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ThemeColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _callProvider(provider),
                  icon: Icon(Icons.phone, size: 16),
                  label: Text('Appeler'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.successColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            selectedCategory == 'Tous'
                ? 'Aucun prestataire favori'
                : 'Aucun prestataire dans "$selectedCategory"',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Ajoutez des prestataires à vos favoris\npour les retrouver facilement ici',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to search or browse providers
            },
            icon: Icon(Icons.search),
            label: Text('Trouver des prestataires'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trier par',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
            ),
            SizedBox(height: 16),
            _buildSortOption('Note la plus élevée', Icons.star, isDark),
            _buildSortOption('Plus d\'expérience', Icons.work, isDark),
            _buildSortOption('En ligne maintenant', Icons.circle, isDark),
            _buildSortOption('Plus proche', Icons.location_on, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, IconData icon, bool isDark) {
    return ListTile(
      leading: Icon(
        icon,
        color: ThemeColors.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        _sortProviders(title);
      },
    );
  }

  void _sortProviders(String sortType) {
    setState(() {
      switch (sortType) {
        case 'Note la plus élevée':
          filteredProviders.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'Plus d\'expérience':
          filteredProviders
              .sort((a, b) => b.completedJobs.compareTo(a.completedJobs));
          break;
        case 'En ligne maintenant':
          filteredProviders.sort((a, b) => b.isOnline ? 1 : -1);
          break;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trié par: $sortType'),
        backgroundColor: ThemeColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _removeFromFavorites(ProviderModel provider) {
    setState(() {
      _sampleProviders.removeWhere((p) => p.id == provider.id);
      _filterProviders(_searchController.text);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${provider.name} retiré des favoris'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Annuler',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _sampleProviders.add(provider);
              _filterProviders(_searchController.text);
            });
          },
        ),
      ),
    );
  }

  void _contactProvider(ProviderModel provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture du chat avec ${provider.name}'),
        backgroundColor: ThemeColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _callProvider(ProviderModel provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appel de ${provider.name}'),
        backgroundColor: ThemeColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Sample data
  static List<ProviderModel> _sampleProviders = [
    ProviderModel(
      id: '1',
      name: 'Fatima Al-Zahra',
      rating: 4.9,
      reviewCount: 124,
      location: 'Tevragh Zeina, Nouakchott',
      completedJobs: 87,
      services: ['Nettoyage', 'Cuisine'],
      isOnline: true,
      isVerified: true,
      profileImage: null,
    ),
    ProviderModel(
      id: '2',
      name: 'Ahmed Hassan',
      rating: 4.8,
      reviewCount: 98,
      location: 'Ksar, Nouakchott',
      completedJobs: 156,
      services: ['Plomberie', 'Électricité'],
      isOnline: false,
      isVerified: true,
      profileImage: null,
    ),
    ProviderModel(
      id: '3',
      name: 'Omar Ba',
      rating: 4.7,
      reviewCount: 67,
      location: 'Sebkha, Nouakchott',
      completedJobs: 43,
      services: ['Jardinage', 'Nettoyage'],
      isOnline: true,
      isVerified: false,
      profileImage: null,
    ),
    ProviderModel(
      id: '4',
      name: 'Aicha Mint Salem',
      rating: 4.6,
      reviewCount: 89,
      location: 'Arafat, Nouakchott',
      completedJobs: 72,
      services: ['Peinture', 'Déménagement'],
      isOnline: false,
      isVerified: true,
      profileImage: null,
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
  final int completedJobs;
  final List<String> services;
  final bool isOnline;
  final bool isVerified;
  final String? profileImage;

  ProviderModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.completedJobs,
    required this.services,
    required this.isOnline,
    required this.isVerified,
    this.profileImage,
  });
}
