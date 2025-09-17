import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class WorkerOpportunitiesScreen extends StatefulWidget {
  final String filterType; // 'category', 'distance', 'price', 'region'
  final String? categoryFilter;

  const WorkerOpportunitiesScreen({
    Key? key,
    required this.filterType,
    this.categoryFilter,
  }) : super(key: key);

  @override
  State<WorkerOpportunitiesScreen> createState() =>
      _WorkerOpportunitiesScreenState();
}

class _WorkerOpportunitiesScreenState extends State<WorkerOpportunitiesScreen> {
  String selectedSortType = 'none';
  String selectedArea = 'Toutes Zones';

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
  ];

  List<Map<String, dynamic>> allOpportunities = [
    {
      'title': 'Nettoyage appartement 3 pièces',
      'location': 'Tevragh-Zeina',
      'price': '8500',
      'time': '3h',
      'distance': '1.2',
      'urgent': true,
      'category': 'nettoyage',
      'icon': Icons.cleaning_services,
    },
    {
      'title': 'Jardinage et taille',
      'location': 'Ksar',
      'price': '6000',
      'time': '4h',
      'distance': '2.1',
      'urgent': false,
      'category': 'jardinage',
      'icon': Icons.grass,
    },
    {
      'title': 'Garde d\'enfants soir',
      'location': 'Sebkha',
      'price': '7200',
      'time': '6h',
      'distance': '3.5',
      'urgent': false,
      'category': 'garde',
      'icon': Icons.child_care,
    },
    {
      'title': 'Réparation plomberie',
      'location': 'Dar Naim',
      'price': '12000',
      'time': '2h',
      'distance': '0.8',
      'urgent': true,
      'category': 'plomberie',
      'icon': Icons.plumbing,
    },
    {
      'title': 'Installation électrique',
      'location': 'Arafat',
      'price': '15000',
      'time': '5h',
      'distance': '4.2',
      'urgent': false,
      'category': 'electricite',
      'icon': Icons.electrical_services,
    },
  ];

  List<Map<String, dynamic>> get filteredOpportunities {
    List<Map<String, dynamic>> filtered = List.from(allOpportunities);

    // تطبيق فلترة الفئة إذا كانت محددة
    if (widget.categoryFilter != null) {
      filtered = filtered
          .where((opp) => opp['category'] == widget.categoryFilter)
          .toList();
    }

    // تطبيق فلترة المنطقة
    if (selectedArea != 'Toutes Zones') {
      filtered = filtered
          .where((opp) => opp['location'].contains(selectedArea.split(' ')[0]))
          .toList();
    }

    // تطبيق الترتيب
    if (selectedSortType == 'price_asc') {
      filtered.sort(
          (a, b) => int.parse(a['price']).compareTo(int.parse(b['price'])));
    } else if (selectedSortType == 'distance_asc') {
      filtered.sort((a, b) =>
          double.parse(a['distance']).compareTo(double.parse(b['distance'])));
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    // تطبيق الفرز الأولي حسب نوع الفلتر
    switch (widget.filterType) {
      case 'distance':
        selectedSortType = 'distance_asc';
        break;
      case 'price':
        selectedSortType = 'price_asc';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getScreenTitle(),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: AppColors.primaryPurple),
            onPressed: _showAdvancedFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط الفلاتر السريعة
          _buildQuickFilters(),

          // عدد النتائج
          _buildResultsCount(),

          // قائمة النتائج
          Expanded(
            child: filteredOpportunities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOpportunities.length,
                    itemBuilder: (context, index) =>
                        _buildOpportunityCard(filteredOpportunities[index]),
                  ),
          ),
        ],
      ),
    );
  }

  String _getScreenTitle() {
    switch (widget.filterType) {
      case 'category':
        return 'Ma catégorie';
      case 'distance':
        return 'Plus proches';
      case 'price':
        return 'Prix croissant';
      case 'region':
        return 'Par région';
      default:
        return 'Opportunités';
    }
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'Plus proche',
              selectedSortType == 'distance_asc',
              () => setState(() {
                selectedSortType = selectedSortType == 'distance_asc'
                    ? 'none'
                    : 'distance_asc';
              }),
              icon: Icons.near_me,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Prix croissant',
              selectedSortType == 'price_asc',
              () => setState(() {
                selectedSortType =
                    selectedSortType == 'price_asc' ? 'none' : 'price_asc';
              }),
              icon: Icons.attach_money,
            ),
            const SizedBox(width: 8),
            _buildAreaFilter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, VoidCallback onTap,
      {IconData? icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryPurple : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primaryPurple : AppColors.lightGray,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaFilter() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => selectedArea = value),
      itemBuilder: (context) => nouakchottAreas.map((area) {
        return PopupMenuItem<String>(
          value: area,
          child: Row(
            children: [
              if (selectedArea == area) ...[
                Icon(Icons.check, size: 16, color: AppColors.primaryPurple),
                const SizedBox(width: 8),
              ],
              Text(
                area,
                style: TextStyle(
                  color: selectedArea == area
                      ? AppColors.primaryPurple
                      : AppColors.textPrimary,
                  fontWeight: selectedArea == area
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selectedArea != 'Toutes Zones'
              ? AppColors.primaryPurple
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedArea != 'Toutes Zones'
                ? AppColors.primaryPurple
                : AppColors.lightGray,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: selectedArea != 'Toutes Zones'
                  ? Colors.white
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Zone',
              style: TextStyle(
                color: selectedArea != 'Toutes Zones'
                    ? Colors.white
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: selectedArea != 'Toutes Zones'
                  ? Colors.white
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${filteredOpportunities.length} opportunités trouvées',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (selectedSortType != 'none' || selectedArea != 'Toutes Zones')
            GestureDetector(
              onTap: () => setState(() {
                selectedSortType = 'none';
                selectedArea = 'Toutes Zones';
              }),
              child: Text(
                'Effacer filtres',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> opportunity) {
    final isUrgent = opportunity['urgent'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: isUrgent
            ? Border.all(color: AppColors.orange.withOpacity(0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  opportunity['icon'] as IconData,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.orange,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      opportunity['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${opportunity['distance']} km',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                opportunity['location'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${opportunity['time']} estimées',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showApplicationDialog(opportunity),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.primaryPurple,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Text(
                '${opportunity['price']} MRU',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.mediumGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune opportunité trouvée',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtres avancés',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppColors.mediumGray),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Trier par',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildAdvancedOption('Prix croissant', 'price_asc'),
            _buildAdvancedOption('Distance croissante', 'distance_asc'),
            _buildAdvancedOption('Urgent en premier', 'urgent'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Appliquer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOption(String title, String value) {
    final isSelected = selectedSortType == value;

    return GestureDetector(
      onTap: () => setState(() {
        selectedSortType = isSelected ? 'none' : value;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple.withOpacity(0.1)
              : AppColors.lightGray,
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected ? Border.all(color: AppColors.primaryPurple) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color:
                  isSelected ? AppColors.primaryPurple : AppColors.mediumGray,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApplicationDialog(Map<String, dynamic> opportunity) {
    final TextEditingController messageController = TextEditingController();
    final String defaultMessage =
        "Je suis l'ouvrier Omar Ba Je souhaite postuler pour ce poste.";

    messageController.text = defaultMessage;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person_add,
                          color: AppColors.primaryPurple, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Postuler pour la mission',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  opportunity['title'] as String,
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Text(
                  'Message optionnel:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Écrivez votre message de motivation...',
                    hintStyle:
                        TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.lightGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryPurple),
                    ),
                    filled: true,
                    fillColor: AppColors.lightGray.withOpacity(0.5),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Annuler',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _submitApplication(
                              opportunity, messageController.text);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Envoyer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitApplication(Map<String, dynamic> opportunity, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Candidature envoyée avec succès!'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
