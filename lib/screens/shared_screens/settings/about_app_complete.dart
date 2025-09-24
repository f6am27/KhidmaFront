import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme_colors.dart';

class AboutAppCompleteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('À propos de Khidma'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppHeaderCard(context, isDark),
            SizedBox(height: 20),
            _buildMissionCard(context, isDark),
            SizedBox(height: 16),
            _buildVisionCard(context, isDark),
            SizedBox(height: 16),
            _buildFeaturesCard(context, isDark),
            SizedBox(height: 16),
            _buildStatsCard(context, isDark),
            SizedBox(height: 16),
            _buildContactCard(context, isDark),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeaderCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? ThemeColors.shadowDark : ThemeColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // مركزة عمودية
          crossAxisAlignment: CrossAxisAlignment.center, // مركزة أفقية
          children: [
            Image.asset(
              'assets/images/kh.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, bool isDark) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.rocket_launch,
                  color: ThemeColors.primaryColor,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Notre Mission',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Khidma a pour mission de faciliter l\'accès aux services de proximité en connectant directement les prestataires locaux avec les clients qui ont besoin de leurs services.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  height: 1.6,
                ),
          ),
          SizedBox(height: 12),
          Text(
            'Nous croyons que chacun a des compétences à partager et que la technologie peut rendre ces échanges plus simples et plus accessibles pour tous.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : Colors.grey[500],
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisionCard(BuildContext context, bool isDark) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.visibility,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Notre Vision',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Devenir la plateforme de référence pour les services de proximité, en créant un écosystème où les compétences locales sont valorisées et où chacun peut facilement trouver l\'aide dont il a besoin.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context, bool isDark) {
    final features = [
      _FeatureItem(
        icon: Icons.search,
        title: 'Recherche intelligente',
        description: 'Trouvez rapidement les services près de chez vous',
        color: Colors.green,
      ),
      _FeatureItem(
        icon: Icons.chat,
        title: 'Messagerie intégrée',
        description: 'Communiquez directement avec les prestataires',
        color: Colors.orange,
      ),
      _FeatureItem(
        icon: Icons.star_rate,
        title: 'Système d\'évaluation',
        description: 'Évaluations et commentaires transparents',
        color: Colors.purple,
      ),
      _FeatureItem(
        icon: Icons.security,
        title: 'Sécurisé',
        description: 'Profils vérifiés et transactions sécurisées',
        color: Colors.red,
      ),
    ];

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.amber[700],
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Text(
                'Fonctionnalités principales',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...features
              .map((feature) => Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: _buildFeatureItem(context, feature, isDark),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
      BuildContext context, _FeatureItem feature, bool isDark) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: feature.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            feature.icon,
            color: feature.color,
            size: 20,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
              ),
              SizedBox(height: 2),
              Text(
                feature.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context, bool isDark) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Khidma en chiffres',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  '1000+',
                  'Utilisateurs actifs',
                  Icons.people,
                  ThemeColors.primaryColor,
                  isDark,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  '500+',
                  'Services réalisés',
                  Icons.check_circle,
                  Colors.green,
                  isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  '4.8/5',
                  'Note moyenne',
                  Icons.star,
                  Colors.amber,
                  isDark,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  '50+',
                  'Types de services',
                  Icons.category,
                  Colors.purple,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label,
      IconData icon, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, bool isDark) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.contact_mail,
                  color: Colors.indigo,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Text(
                'Nous Contacter',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildContactItem(
              context, 'Email', 'khidma.help@gmail.com', Icons.email, isDark),
          SizedBox(height: 12),
          _buildContactItem(
              context, 'Téléphone', '32 92 12 88', Icons.phone, isDark),
          SizedBox(height: 12),
          _buildContactItem(context, 'Support', 'khidma.help@gmail.com',
              Icons.help_center, isDark),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: ThemeColors.primaryColor,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'Contactez-nous',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  'Nous sommes là pour vous aider',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, String label, String value,
      IconData icon, bool isDark) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label copié dans le presse-papiers'),
            backgroundColor: ThemeColors.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: ThemeColors.primaryColor,
          ),
          SizedBox(width: 12),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ThemeColors.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
