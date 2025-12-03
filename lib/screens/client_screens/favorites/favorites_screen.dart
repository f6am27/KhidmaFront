import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../models/favorite_worker_model.dart';
import '../../../services/favorite_workers_service.dart';
import '../../../services/category_service.dart';
import '../../../models/service_category_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared_screens/messages/chat_screen.dart';
import '../../../../services/chat_service.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FavoriteWorkersService _service = FavoriteWorkersService();
  final CategoryService _categoryService = CategoryService();

  List<FavoriteWorker> filteredWorkers = [];
  List<FavoriteWorker> allWorkers = [];
  List<ServiceCategory> allCategories = [];
  Set<int> blockedUserIds = {};
  String selectedCategory = 'Tous';
  bool _isLoading = true;
  String? _errorMessage;

  // بدل الفئات الثابتة، استخدم dynamic categories:
  late List<String> categories; // ✅ عدّل

  @override
  void initState() {
    super.initState();
    categories = ['Tous']; // بداية مع Tous فقط
    _loadData(); // جديد
  }

  Future<void> _loadBlockedUsers() async {
    try {
      final result = await chatService.getBlockedUsers();

      if (result['ok']) {
        final blockedUsers = result['blocked_users'] as List<dynamic>;
        final blockedIds = <int>{};

        for (var user in blockedUsers) {
          // ✅ جرّب عدة احتمالات للـ structure
          int? blockedId;

          if (user is Map<String, dynamic>) {
            blockedId = user['blocked_user_id'] as int? ??
                user['blocked_user']?['id'] as int? ??
                user['id'] as int?;
          } else if (user is int) {
            blockedId = user;
          }

          if (blockedId != null) {
            blockedIds.add(blockedId);
          }
        }

        setState(() {
          blockedUserIds = blockedIds;
        });

        print(
            '✅ Loaded ${blockedUserIds.length} blocked users: $blockedUserIds');
      }
    } catch (e) {
      print('❌ Error loading blocked users: $e');
    }
  }

  // ✅ دالة جديدة لجلب البيانات
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ جلب المحظورين أولاً
      await _loadBlockedUsers();

      // جلب الفئات
      final categoriesResult = await _categoryService.getServiceCategories();

      // جلب العمال المفضلين
      final workersResult = await _service.getFavoriteWorkers();

      if (categoriesResult['ok'] && workersResult['ok']) {
        setState(() {
          allCategories =
              categoriesResult['categories'] as List<ServiceCategory>;
          // بناء قائمة الفئات من الـ Backend
          categories = ['Tous'] + allCategories.map((cat) => cat.name).toList();

          final workers = workersResult['workers'] as List<FavoriteWorker>;
          allWorkers = workers
              .where((worker) => !blockedUserIds.contains(worker.workerId))
              .toList();
          filteredWorkers = allWorkers;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = workersResult['error'] ?? categoriesResult['error'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteWorkers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ إعادة جلب المحظورين
      await _loadBlockedUsers();

      final result = await _service.getFavoriteWorkers();

      if (result['ok']) {
        setState(() {
          final workers = result['workers'] as List<FavoriteWorker>;
          allWorkers = workers
              .where((worker) => !blockedUserIds.contains(worker.workerId))
              .toList();
          filteredWorkers = allWorkers;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _filterWorkers(String query) {
    setState(() {
      var filtered = allWorkers;

      // Filter by category
      if (selectedCategory != 'Tous') {
        filtered = filtered
            .where((worker) =>
                worker.services.any((service) => service == selectedCategory))
            .toList();
      }

      // Filter by search query
      if (query.isNotEmpty) {
        filtered = filtered
            .where((worker) =>
                worker.name.toLowerCase().contains(query.toLowerCase()) ||
                worker.services.any((service) =>
                    service.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }

      filteredWorkers = filtered;
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: ThemeColors.primaryColor,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(_errorMessage!),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFavoriteWorkers,
                        child: Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search bar
                    _buildSearchBar(isDark),

                    // Category filter
                    _buildCategoryFilter(isDark),

                    // Workers list
                    Expanded(
                      child: filteredWorkers.isEmpty
                          ? _buildEmptyState(isDark)
                          : RefreshIndicator(
                              onRefresh: _loadFavoriteWorkers,
                              child: ListView.separated(
                                padding: EdgeInsets.all(16),
                                itemCount: filteredWorkers.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final worker = filteredWorkers[index];
                                  return _buildWorkerCard(worker, isDark);
                                },
                              ),
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
        onChanged: _filterWorkers,
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
                    _filterWorkers('');
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
                  _filterWorkers(_searchController.text);
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

  Widget _buildWorkerCard(FavoriteWorker worker, bool isDark) {
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
                    backgroundImage: worker.profileImage != null
                        ? NetworkImage(worker.profileImage!)
                        : null,
                    child: worker.profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 35,
                            color: isDark ? Colors.white54 : Colors.grey[600],
                          )
                        : null,
                  ),
                  if (worker.isOnline)
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
                ],
              ),
              SizedBox(width: 16),

              // Worker info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            worker.name,
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
                          onPressed: () => _removeFromFavorites(worker),
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
                              index < worker.rating.floor()
                                  ? Icons.star
                                  : (index < worker.rating
                                      ? Icons.star_half
                                      : Icons.star_border),
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '${worker.rating} (${worker.reviewCount})',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    isDark ? Colors.white54 : Colors.grey[600],
                              ),
                        ),
                        if (worker.isOnline) ...[
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
            children: worker.services.map((service) {
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
                '${worker.completedJobs} missions',
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
                  worker.location,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.grey[500],
                      ),
                  overflow: TextOverflow.ellipsis,
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
                  onPressed: () => _contactWorker(worker),
                  icon: Icon(
                    Icons.chat,
                    size: 16,
                    color: ThemeColors.primaryColor,
                  ),
                  label: Text(
                    'Discuter',
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
                  onPressed: () => _callWorker(worker),
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
            onPressed: _loadFavoriteWorkers,
            icon: Icon(Icons.refresh),
            label: Text('Réessayer'),
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
            // ✅ فقط التقييم والأونلاين
            _buildSortOption(
              'Note la plus élevée',
              Icons.star,
              'rating_high',
              isDark,
            ),
            _buildSortOption(
              'En ligne maintenant',
              Icons.circle,
              'online',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
      String title, IconData icon, String sortBy, bool isDark) {
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
        _sortWorkers(sortBy);
      },
    );
  }

  void _sortWorkers(String sortBy) {
    setState(() {
      switch (sortBy) {
        case 'rating_high':
          // ترتيب من الأعلى تقييماً للأقل
          filteredWorkers.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'online':
          // عرض العمال الأونلاين فقط
          filteredWorkers =
              filteredWorkers.where((worker) => worker.isOnline).toList();
          break;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(sortBy == 'rating_high'
            ? 'مرتب حسب التقييم'
            : 'عرض العمال الأونلاين فقط'),
        backgroundColor: ThemeColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _removeFromFavorites(FavoriteWorker worker) async {
    final result = await _service.removeFromFavorites(worker.workerId);

    if (result['ok']) {
      await _loadFavoriteWorkers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${worker.name} retiré des favoris'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _contactWorker(FavoriteWorker worker) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final result = await chatService.startConversation(worker.workerId);
    Navigator.pop(context); // أغلق Loading

    if (result['ok']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            conversationId: result['conversation_id'],
            contactName: worker.name,
            contactId: worker.workerId,
            isOnline: worker.isOnline,
            profileImageUrl: worker.profileImage,
          ),
        ),
      );
    } else {
      // ✅ تحقق من status code 403 أو رسالة block
      final errorMessage = (result['error'] ?? '').toString().toLowerCase();
      final statusCode = result['status'];

      String displayMessage;

      if (statusCode == 403 ||
          errorMessage.contains('block') ||
          errorMessage.contains('bloqué') ||
          errorMessage.contains('forbidden')) {
        displayMessage =
            'Vous ne pouvez pas discuter avec un utilisateur bloqué';
      } else {
        displayMessage =
            result['error'] ?? 'Erreur lors du démarrage de la conversation';
      }

      // ✅ عرض Dialog بدلاً من SnackBar
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.block, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Accès refusé',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Text(
            displayMessage,
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  color: ThemeColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _callWorker(FavoriteWorker worker) async {
    // إزالة + وكود الدولة 222
    String cleanPhone = worker.phone
        .replaceAll('+', '')
        .replaceAll('222', '')
        .trim(); // ✅ إزالة المسافات الزائدة

    // استخدام tel:// لفتح تطبيق الهاتف
    final phoneNumber = 'tel://$cleanPhone';

    print('📞 Opening dialer with: $cleanPhone');

    try {
      if (await canLaunch(phoneNumber)) {
        await launch(phoneNumber);
        print('✅ Dialer opened successfully');
      } else {
        final fallbackPhone = 'tel:$cleanPhone';
        if (await canLaunch(fallbackPhone)) {
          await launch(fallbackPhone);
          print('✅ Dialer opened with fallback');
        } else {
          throw 'Cannot launch dialer';
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Numéro: $cleanPhone\n(Testé sur appareil réel uniquement)',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
