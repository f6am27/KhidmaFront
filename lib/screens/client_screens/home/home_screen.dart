import 'package:flutter/material.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/category_selector_widget.dart';
import 'widgets/filter_options_widget.dart';
import 'widgets/worker_card_widget.dart';
import '../../../core/theme/theme_colors.dart';
import 'widgets/all_services_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  static const Color primaryPurple = Color(0xFF6366F1);

  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  String selectedFilter = 'Tout';
  String selectedService = 'Tout';
  String searchQuery = '';
  bool showSearchResults = false;
  String selectedCategory = 'Toutes Catégories';
  bool isSearchActive = false;

  // Filter states
  String priceSort = 'none';
  String ratingSort = 'none';
  String distanceSort = 'none';
  String selectedArea = 'Toutes Zones';

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<String> categories = [
    'Toutes Catégories',
    'Nettoyage Maison',
    'Réparation Électroménager',
    'Plomberie',
    'Déménagement',
    'Électricité',
    'Peinture',
    'Menuiserie',
    'Jardinage',
    'Lavage Auto',
    'Lutte Antiparasitaire',
    'Services Sécurité',
    'Photographie',
    'Traiteur',
    'Entraîneur Personnel',
    'Cours Particuliers',
    'Soins Animaux',
    'Beauté & Salon',
    'Support Informatique',
    'Soins de Santé',
    'Blanchisserie'
  ];

  final List<String> nouakchottAreas = [
    'Toutes Zones',
    'Tevragh Zeina',
    'Riad',
    'Dar Naim',
    'Tojounin',
    'Arafat',
    'Port',
    'Carrefour',
    'Sebkha',
    'Tarhil',
    'Wahdah',
    'Riyad',
    'El Houde Ech Chargui'
  ];

  final List<Map<String, dynamic>> allServices = [
    {
      'icon': Icons.cleaning_services,
      'name': 'Nettoyage Maison',
      'category': 'Nettoyage Maison'
    },
    {
      'icon': Icons.build,
      'name': 'Réparation Électroménager',
      'category': 'Réparation Électroménager'
    },
    {'icon': Icons.plumbing, 'name': 'Plomberie', 'category': 'Plomberie'},
    {
      'icon': Icons.local_shipping,
      'name': 'Déménagement',
      'category': 'Déménagement'
    },
    {
      'icon': Icons.electrical_services,
      'name': 'Électricité',
      'category': 'Électricité'
    },
    {'icon': Icons.format_paint, 'name': 'Peinture', 'category': 'Peinture'},
    {'icon': Icons.carpenter, 'name': 'Menuiserie', 'category': 'Menuiserie'},
    {'icon': Icons.grass, 'name': 'Jardinage', 'category': 'Jardinage'},
    {
      'icon': Icons.car_repair,
      'name': 'Lavage Auto',
      'category': 'Lavage Auto'
    },
    {
      'icon': Icons.pest_control,
      'name': 'Lutte Antiparasitaire',
      'category': 'Lutte Antiparasitaire'
    },
    {
      'icon': Icons.security,
      'name': 'Services Sécurité',
      'category': 'Services Sécurité'
    },
    {
      'icon': Icons.photo_camera,
      'name': 'Photographie',
      'category': 'Photographie'
    },
    {'icon': Icons.cake, 'name': 'Traiteur', 'category': 'Traiteur'},
    {
      'icon': Icons.fitness_center,
      'name': 'Entraîneur Personnel',
      'category': 'Entraîneur Personnel'
    },
    {
      'icon': Icons.school,
      'name': 'Cours Particuliers',
      'category': 'Cours Particuliers'
    },
    {'icon': Icons.pets, 'name': 'Soins Animaux', 'category': 'Soins Animaux'},
    {'icon': Icons.cut, 'name': 'Beauté & Salon', 'category': 'Beauté & Salon'},
    {
      'icon': Icons.computer,
      'name': 'Support Informatique',
      'category': 'Support Informatique'
    },
    {
      'icon': Icons.medical_services,
      'name': 'Soins de Santé',
      'category': 'Soins de Santé'
    },
    {
      'icon': Icons.local_laundry_service,
      'name': 'Blanchisserie',
      'category': 'Blanchisserie'
    },
  ];

  List<Map<String, dynamic>> topWorkers = [
    {
      'name': 'CrispCloth',
      'service': 'Blanchisserie',
      'category': 'Blanchisserie',
      'rating': 4.8,
      'distance': '0.8 km',
      'time': '5 Min',
      'price': '500-2500 MRU',
      'minPrice': 500,
      'image': 'assets/worker1.jpg',
      'isFavorite': false,
      'area': 'Tevragh Zeina',
      'phone': '+222 12345678',
    },
    {
      'name': 'Squeaky Clean',
      'service': 'Blanchisserie',
      'category': 'Blanchisserie',
      'rating': 4.7,
      'distance': '1.2 km',
      'time': '10 Min',
      'price': '200-1600 MRU',
      'minPrice': 200,
      'image': 'assets/worker2.jpg',
      'isFavorite': true,
      'area': 'Riad',
      'phone': '+222 87654321',
    },
    {
      'name': 'PureCare Laundry',
      'service': 'Blanchisserie',
      'category': 'Blanchisserie',
      'rating': 4.8,
      'distance': '2.1 km',
      'time': '15 Min',
      'price': '300-3200 MRU',
      'minPrice': 300,
      'image': 'assets/worker3.jpg',
      'isFavorite': false,
      'area': 'Dar Naim',
      'phone': '+222 11223344',
    },
    {
      'name': 'Ahmed ElKhadem',
      'service': 'Plomberie',
      'category': 'Plomberie',
      'rating': 4.9,
      'distance': '1.5 km',
      'time': '8 Min',
      'price': '1000-5000 MRU',
      'minPrice': 1000,
      'image': 'assets/worker4.jpg',
      'isFavorite': true,
      'area': 'Tojounin',
      'phone': '+222 55667788',
    },
    {
      'name': 'Omar Fixing',
      'service': 'Électricité',
      'category': 'Électricité',
      'rating': 4.6,
      'distance': '0.9 km',
      'time': '12 Min',
      'price': '800-4000 MRU',
      'minPrice': 800,
      'image': 'assets/worker5.jpg',
      'isFavorite': false,
      'area': 'Arafat',
      'phone': '+222 99887766',
    },
    {
      'name': 'Clean House Pro',
      'service': 'Nettoyage Maison',
      'category': 'Nettoyage Maison',
      'rating': 4.5,
      'distance': '2.3 km',
      'time': '20 Min',
      'price': '400-2000 MRU',
      'minPrice': 400,
      'image': 'assets/worker6.jpg',
      'isFavorite': false,
      'area': 'Port',
      'phone': '+222 44556677',
    },
  ];

  List<Map<String, dynamic>> get filteredWorkers {
    List<Map<String, dynamic>> filtered = List.from(topWorkers);

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((worker) {
        return worker['name']
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            worker['service']
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            worker['category']
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (selectedCategory != 'Toutes Catégories') {
      filtered = filtered
          .where((worker) => worker['category'] == selectedCategory)
          .toList();
    }

    if (selectedArea != 'Toutes Zones') {
      filtered =
          filtered.where((worker) => worker['area'] == selectedArea).toList();
    }

    if (priceSort != 'none') {
      if (priceSort == 'asc') {
        filtered.sort((a, b) => a['minPrice'].compareTo(b['minPrice']));
      } else {
        filtered.sort((a, b) => b['minPrice'].compareTo(a['minPrice']));
      }
    } else if (ratingSort != 'none') {
      if (ratingSort == 'desc') {
        filtered.sort((a, b) => b['rating'].compareTo(a['rating']));
      } else {
        filtered.sort((a, b) => a['rating'].compareTo(b['rating']));
      }
    } else if (distanceSort != 'none') {
      if (distanceSort == 'asc') {
        filtered.sort((a, b) =>
            double.parse(a['distance'].replaceAll(' km', ''))
                .compareTo(double.parse(b['distance'].replaceAll(' km', ''))));
      } else {
        filtered.sort((a, b) =>
            double.parse(b['distance'].replaceAll(' km', ''))
                .compareTo(double.parse(a['distance'].replaceAll(' km', ''))));
      }
    }

    return filtered;
  }

  void _performSearch() {
    if (selectedCategory == 'Toutes Catégories' &&
        _searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Veuillez sélectionner une catégorie pour commencer la recherche'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      searchQuery = _searchController.text;
      showSearchResults = true;
      isSearchActive = true;
    });
  }

  void _showFiltersDropdown() {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (BuildContext context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
            Positioned(
              top: 180,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ThemeColors.darkCardBackground
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? ThemeColors.darkBorder
                          : Colors.grey[200]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Prix
                      _buildCleanFilterItem(
                        'Prix',
                        priceSort,
                        () {
                          setState(() {
                            if (priceSort == 'none') {
                              priceSort = 'asc';
                            } else if (priceSort == 'asc') {
                              priceSort = 'desc';
                            } else {
                              priceSort = 'none';
                            }
                            ratingSort = 'none';
                            distanceSort = 'none';
                          });
                          Navigator.pop(context);
                        },
                      ),

                      _buildDivider(),

                      // Note
                      _buildCleanFilterItem(
                        'Note',
                        ratingSort,
                        () {
                          setState(() {
                            if (ratingSort == 'none') {
                              ratingSort = 'desc';
                            } else if (ratingSort == 'desc') {
                              ratingSort = 'asc';
                            } else {
                              ratingSort = 'none';
                            }
                            priceSort = 'none';
                            distanceSort = 'none';
                          });
                          Navigator.pop(context);
                        },
                      ),

                      _buildDivider(),

                      // Distance
                      _buildCleanFilterItem(
                        'Distance',
                        distanceSort,
                        () {
                          setState(() {
                            if (distanceSort == 'none') {
                              distanceSort = 'asc';
                            } else if (distanceSort == 'asc') {
                              distanceSort = 'desc';
                            } else {
                              distanceSort = 'none';
                            }
                            priceSort = 'none';
                            ratingSort = 'none';
                          });
                          Navigator.pop(context);
                        },
                      ),

                      _buildDivider(),

                      // Zone géographique
                      _buildCleanFilterItem(
                        'Zone géographique',
                        selectedArea != 'Toutes Zones' ? 'active' : 'none',
                        () {
                          Navigator.pop(context);
                          _showAreaSelection();
                        },
                      ),

                      _buildDivider(),

                      // Réinitialiser
                      _buildCleanFilterItem(
                        'Réinitialiser',
                        'reset',
                        () {
                          _resetFilters();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCleanFilterItem(
      String title, String status, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color textColor;
    String suffix = '';

    if (status == 'reset') {
      textColor = ThemeColors.primaryColor;
    } else if (status == 'active') {
      textColor = ThemeColors.primaryColor;
    } else if (status == 'asc') {
      textColor = ThemeColors.primaryColor;
      suffix = ' ↑';
    } else if (status == 'desc') {
      textColor = ThemeColors.primaryColor;
      suffix = ' ↓';
    } else {
      textColor =
          isDark ? ThemeColors.darkTextPrimary : ThemeColors.lightTextPrimary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: status != 'none' && status != 'reset'
              ? ThemeColors.primaryColor.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Text(
          title + suffix,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            fontWeight: status != 'none' && status != 'reset'
                ? FontWeight.w500
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Theme.of(context).brightness == Brightness.dark
          ? ThemeColors.darkBorder
          : Colors.grey[100],
    );
  }

  void _showAreaSelection() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? ThemeColors.darkCardBackground : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Sélectionner une zone',
            style: TextStyle(
              color: isDark
                  ? ThemeColors.darkTextPrimary
                  : ThemeColors.lightTextPrimary,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: nouakchottAreas.length,
              itemBuilder: (context, index) {
                final area = nouakchottAreas[index];
                return ListTile(
                  title: Text(
                    area,
                    style: TextStyle(
                      color: isDark
                          ? ThemeColors.darkTextPrimary
                          : ThemeColors.lightTextPrimary,
                    ),
                  ),
                  trailing: selectedArea == area
                      ? Icon(
                          Icons.check,
                          color: ThemeColors.primaryColor,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      selectedArea = area;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      priceSort = 'none';
      ratingSort = 'none';
      distanceSort = 'none';
      selectedArea = 'Toutes Zones';
      selectedCategory = 'Toutes Catégories';
    });
  }

  void _resetSearch() {
    setState(() {
      showSearchResults = false;
      searchQuery = '';
      isSearchActive = false;
      selectedCategory = 'Toutes Catégories';
      _searchController.clear();
      _resetFilters();
    });
    _searchFocusNode.unfocus();
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      if (isSearchActive) {
        showSearchResults = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          isSearchActive = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(isDark),
              SizedBox(height: 24),

              // Search Bar Widget مع زر الفلتر منفصل
              SearchBarWidget(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onSearch: _performSearch,
                onFilterTap: isSearchActive ? _showFiltersDropdown : null,
                onSearchActiveChanged: (isActive) {
                  setState(() {
                    isSearchActive = isActive;
                  });
                },
                onSearchChanged: (value) {
                  setState(() {
                    if (showSearchResults) {
                      searchQuery = value;
                    }
                  });
                },
              ),
              SizedBox(height: 16),

              // Category Selector Widget
              if (isSearchActive)
                CategorySelectorWidget(
                  categories: categories,
                  selectedCategory: selectedCategory,
                  onCategorySelected: _onCategorySelected,
                ),

              SizedBox(height: 32),

              // Categories section
              if (!isSearchActive) ...[
                _buildCategoriesSection(isDark),
                SizedBox(height: 32),
              ],

              // Results section
              _buildResultsSection(isDark),
              SizedBox(height: 16),

              // Workers list
              if (filteredWorkers.isEmpty)
                _buildEmptyState(isDark)
              else
                ...filteredWorkers
                    .map((worker) => WorkerCardWidget(
                          worker: worker,
                          onFavoriteToggle: () {
                            setState(() {
                              worker['isFavorite'] = !worker['isFavorite'];
                            });
                          },
                          onPhoneCall: () {
                            _makePhoneCall(worker['phone']);
                          },
                          onChat: () {
                            _openChat(worker);
                          },
                        ))
                    .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Center(
      child: Text(
        'Home',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark
              ? ThemeColors.darkTextPrimary
              : ThemeColors.lightTextPrimary,
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Catégories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? ThemeColors.darkTextPrimary
                    : ThemeColors.lightTextPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => _showAllServices(context),
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: ThemeColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCategoryItem(Icons.cleaning_services, 'Nettoyage', isDark),
            _buildCategoryItem(Icons.build, 'Réparation', isDark),
            _buildCategoryItem(Icons.plumbing, 'Plomberie', isDark),
            _buildCategoryItem(Icons.local_shipping, 'Déménagement', isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkCardBackground : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? ThemeColors.shadowDark
                    : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isDark ? ThemeColors.darkTextPrimary : Colors.grey[700],
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          showSearchResults ? 'Résultats de recherche' : 'Meilleurs Ouvriers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
          ),
        ),
        if (showSearchResults)
          GestureDetector(
            onTap: _resetSearch,
            child: Text(
              'Effacer recherche',
              style: TextStyle(
                color: ThemeColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            'Voir tout',
            style: TextStyle(
              color: ThemeColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 50),
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    print('Navigating to notifications page');
  }

  void _makePhoneCall(String phone) {
    print('Calling: $phone');
    // يمكنك هنا إضافة كود للاتصال باستخدام url_launcher
  }

  void _openChat(Map<String, dynamic> worker) {
    print('Opening chat with: ${worker['name']}');
    // يمكنك هنا الانتقال إلى صفحة المحادثة
  }

// في كود home_screen الخاص بك، عليك تعديل الدالة _showAllServices كما يلي:

  void _showAllServices(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllServicesScreen(
          onServiceSelected: (String selectedCategory) {
            setState(() {
              this.selectedCategory = selectedCategory;
              showSearchResults = true;
              _searchController.text = selectedCategory;
              searchQuery = selectedCategory;
              isSearchActive = true;
            });
          },
        ),
      ),
    );
  }
}
