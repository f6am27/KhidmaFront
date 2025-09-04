import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class AllServicesScreen extends StatelessWidget {
  final Function(String) onServiceSelected;

  const AllServicesScreen({
    Key? key,
    required this.onServiceSelected,
  }) : super(key: key);

  final List<Map<String, dynamic>> allServices = const [
    {
      'icon': Icons.cleaning_services,
      'name': 'Nettoyage',
      'category': 'Nettoyage Maison'
    },
    {
      'icon': Icons.build,
      'name': 'Réparation',
      'category': 'Réparation Électroménager'
    },
    {'icon': Icons.plumbing, 'name': 'Plomberie', 'category': 'Plomberie'},
    {
      'icon': Icons.local_shipping,
      'name': 'Déménagement',
      'category': 'Déménagement'
    },
    {'icon': Icons.format_paint, 'name': 'Peinture', 'category': 'Peinture'},
    {
      'icon': Icons.local_laundry_service,
      'name': 'Blanchisserie',
      'category': 'Blanchisserie'
    },
    {
      'icon': Icons.car_repair,
      'name': 'Réparation Auto',
      'category': 'Réparation Auto'
    },
    {
      'icon': Icons.electrical_services,
      'name': 'Électricité',
      'category': 'Électricité'
    },
    {'icon': Icons.carpenter, 'name': 'Menuiserie', 'category': 'Menuiserie'},
    {'icon': Icons.grass, 'name': 'Jardinage', 'category': 'Jardinage'},
    {'icon': Icons.iron, 'name': 'Repassage', 'category': 'Repassage'},
    {
      'icon': Icons.home_repair_service,
      'name': 'Réparations',
      'category': 'Réparations Diverses'
    },
    {'icon': Icons.cut, 'name': 'Beauté', 'category': 'Beauté & Salon'},
    {'icon': Icons.grass, 'name': 'Jardinage', 'category': 'Jardinage'},
    {
      'icon': Icons.security,
      'name': 'Sécurité',
      'category': 'Services Sécurité'
    },
    {'icon': Icons.spa, 'name': 'Massage', 'category': 'Massage'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black, // السهم حسب الوضع
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Catégories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemCount: allServices.length,
            itemBuilder: (context, index) {
              final service = allServices[index];
              return _buildServiceItem(
                service['icon'],
                service['name'],
                service['category'],
                isDark,
                context,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem(
    IconData icon,
    String name,
    String category,
    bool isDark,
    BuildContext context,
  ) {
    final iconColor = isDark ? Colors.white : ThemeColors.primaryColor;

    return GestureDetector(
      onTap: () {
        onServiceSelected(category);
        Navigator.pop(context);
      },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? ThemeColors.darkCardBackground : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? ThemeColors.shadowDark
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor, // الأيقونات حسب الوضع
                size: 24,
              ),
            ),
            SizedBox(height: 6),
            Expanded(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? ThemeColors.darkTextPrimary
                      : ThemeColors.lightTextPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
