import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/colors.dart';
import 'worker_opportunities_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  bool _isLocationEnabled = false; // تغيير القيمة الافتراضية لـ false
  String _currentLocation = "Nouakchott";
  String _currentCountry = "Mauritanie";
  bool _isLocationLoading = false;
  String _workerName = "Omar Ba"; // اسم العامل - يمكن جلبه من قاعدة البيانات

  @override
  void initState() {
    super.initState();
    // تحميل حالة الموقع المحفوظة
    _loadLocationState();
  }

  // تحميل حالة الموقع من SharedPreferences
  void _loadLocationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocationState =
          prefs.getBool('worker_location_enabled') ?? false;

      setState(() {
        _isLocationEnabled = savedLocationState;
      });
    } catch (e) {
      print('Error loading location state: $e');
      // في حالة الخطأ، نبقي القيمة الافتراضية false
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              AppColors.primaryPurple,
              AppColors.primaryPurple.withOpacity(0.8),
              AppColors.background,
            ],
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernLocationHeader(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildWelcomeCard(),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        _buildOpportunitiesSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernLocationHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Position',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _isLocationEnabled
                              ? AppColors.green
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isLocationLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isLocationEnabled
                                      ? _currentLocation
                                      : 'Désactivée',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_isLocationEnabled)
                                  Text(
                                    _currentCountry,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                              ],
                            ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white.withOpacity(0.7),
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Switch(
                  value: _isLocationEnabled,
                  onChanged: _toggleLocation,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.green.withOpacity(0.8),
                  inactiveThumbColor: Colors.white.withOpacity(0.7),
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _showSearchOptions,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rechercher des opportunités...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: Colors.white.withOpacity(0.9),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // باقي الدوال بدون تغيير...
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Spécial pour vous',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Nouvelles missions\ndisponibles',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jusqu\'à 15 000 MRU aujourd\'hui',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.work_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.explore,
                title: 'Explorer',
                subtitle: 'Trouver missions',
                color: AppColors.cyan,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.assignment,
                title: 'Mes Tâches',
                subtitle: 'Gérer missions',
                color: AppColors.orange,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Opportunités près de vous',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) => _buildOpportunityCard(index),
        ),
      ],
    );
  }

  Widget _buildOpportunityCard(int index) {
    final opportunities = [
      {
        'title': 'Nettoyage appartement',
        'location': 'Tevragh-Zeina',
        'price': '8500',
        'time': '3h',
        'distance': '1.2',
        'urgent': true,
        'icon': Icons.cleaning_services,
      },
      {
        'title': 'Jardinage',
        'location': 'Ksar',
        'price': '6000',
        'time': '4h',
        'distance': '2.1',
        'urgent': false,
        'icon': Icons.grass,
      },
      {
        'title': 'Garde d\'enfants',
        'location': 'Sebkha',
        'price': '7200',
        'time': '6h',
        'distance': '3.5',
        'urgent': false,
        'icon': Icons.child_care,
      },
    ];

    final opportunity = opportunities[index];
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
                  '${opportunity['distance'] as String} km',
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
                '${opportunity['time'] as String} estimées',
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
                  // زر التقديم مع أيقونة
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
                  // زر المحادثة
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
                ],
              ),
              Text(
                '${opportunity['price'] as String} MRU',
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

  void _showApplicationDialog(Map<String, dynamic> opportunity) {
    final TextEditingController messageController = TextEditingController();
    final String defaultMessage =
        "Je suis l'ouvrier $_workerName Je souhaite postuler pour ce poste.";

    // تعيين الرسالة الافتراضية
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
                // عنوان النافذة
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person_add,
                        color: AppColors.primaryPurple,
                        size: 20,
                      ),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // حقل الرسالة
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
                    hintText: 'اكتب رسالة إضافية (اختياري)',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
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

                // أزرار التحكم
                Row(
                  children: [
                    // زر الإلغاء
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
                    // زر التأكيد
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
    // هنا يتم إرسال الطلب مع الرسالة إلى الخادم
    print('تم التقدم للمهمة: ${opportunity['title']}');
    print('الرسالة: $message');

    // إظهار رسالة تأكيد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Candidature envoyée avec succès!'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // تحديث دالة تبديل الموقع مع حفظ الحالة
  void _toggleLocation(bool value) async {
    setState(() => _isLocationLoading = true);

    try {
      // حفظ الحالة الجديدة
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('worker_location_enabled', value);

      // محاكاة تحميل (يمكن استبداله بطلب GPS حقيقي)
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _isLocationEnabled = value;
        _isLocationLoading = false;
      });

      // رسالة تأكيد
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                value ? Icons.location_on : Icons.location_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                value ? 'Position activée avec succès!' : 'Position désactivée',
              ),
            ],
          ),
          backgroundColor: value ? AppColors.green : AppColors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      // في حالة الخطأ
      setState(() => _isLocationLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text('Erreur lors de la mise à jour de la position'),
            ],
          ),
          backgroundColor: AppColors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSearchOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trier les missions',
                  style: TextStyle(
                    fontSize: 18,
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
            const SizedBox(height: 16),
            _buildSearchOption(
              icon: Icons.work_outline,
              title: 'Ma catégorie',
              subtitle: 'Missions dans votre domaine',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkerOpportunitiesScreen(
                      filterType: 'category',
                      categoryFilter: 'nettoyage',
                    ),
                  ),
                );
              },
            ),
            _buildSearchOption(
              icon: Icons.location_on_outlined,
              title: 'Plus proches',
              subtitle: 'Triées par distance croissante',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkerOpportunitiesScreen(filterType: 'distance'),
                  ),
                );
              },
            ),
            _buildSearchOption(
              icon: Icons.attach_money,
              title: 'Prix croissant',
              subtitle: 'Du moins cher au plus cher',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkerOpportunitiesScreen(filterType: 'price'),
                  ),
                );
              },
            ),
            _buildSearchOption(
              icon: Icons.map_outlined,
              title: 'Par région',
              subtitle: 'Groupées par zones',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkerOpportunitiesScreen(filterType: 'region'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryPurple, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.mediumGray),
          ],
        ),
      ),
    );
  }
}
