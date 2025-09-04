import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';
import 'about_app_complete.dart';

class SupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Aide & Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // FAQ Section
            _buildSectionTitle(context, 'Questions fréquentes'),
            _buildFAQSection(context, isDark),
            SizedBox(height: 30),

            // App Info Section
            _buildSectionTitle(context, 'À propos'),
            _buildAppInfoSection(context, isDark),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
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
          _buildSupportItem(
            context: context,
            icon: Icons.help_outline,
            title: 'Comment ça marche ?',
            subtitle: 'Guide d\'utilisation de l\'app',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HowItWorksScreen()),
            ),
            isDark: isDark,
          ),
          _buildDivider(context, isDark),
          _buildSupportItem(
            context: context,
            icon: Icons.work_outline,
            title: 'Services disponibles',
            subtitle: 'Types de services sur Khidma',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ServicesInfoScreen()),
            ),
            isDark: isDark,
          ),
          _buildDivider(context, isDark),
          _buildSupportItem(
            context: context,
            icon: Icons.payment,
            title: 'Paiements & Tarifs',
            subtitle: 'Informations sur les paiements',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentInfoScreen()),
            ),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
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
          _buildSupportItem(
            context: context,
            icon: Icons.info_outline,
            title: 'À propos de Khidma',
            subtitle: 'Notre mission et vision',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutAppCompleteScreen()),
            ),
            isDark: isDark,
          ),
          _buildDivider(context, isDark),
          _buildSupportItem(
            context: context,
            icon: Icons.description_outlined,
            title: 'Conditions d\'utilisation',
            subtitle: 'Nos conditions générales',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TermsScreen()),
            ),
            isDark: isDark,
          ),
          _buildDivider(context, isDark),
          _buildSupportItem(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: 'Politique de confidentialité',
            subtitle: 'Protection de vos données',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
            ),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ThemeColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: ThemeColors.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.white60 : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: isDark ? ThemeColors.darkDivider : ThemeColors.lightDivider,
    );
  }
}

// How It Works Screen
class HowItWorksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Comment ça marche ?'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepCard(
              context,
              '1',
              'Créez votre profil',
              'Inscrivez-vous et remplissez votre profil avec vos compétences et disponibilités.',
              Icons.person_add,
              isDark,
            ),
            SizedBox(height: 16),
            _buildStepCard(
              context,
              '2',
              'Trouvez des services',
              'Parcourez les demandes de services près de chez vous ou publiez vos propres services.',
              Icons.search,
              isDark,
            ),
            SizedBox(height: 16),
            _buildStepCard(
              context,
              '3',
              'Communiquez',
              'Discutez directement avec les clients via notre messagerie intégrée.',
              Icons.chat,
              isDark,
            ),
            SizedBox(height: 16),
            _buildStepCard(
              context,
              '4',
              'Effectuez le service',
              'Réalisez la mission selon les conditions convenues.',
              Icons.work,
              isDark,
            ),
            SizedBox(height: 16),
            _buildStepCard(
              context,
              '5',
              'Recevez des évaluations',
              'Les clients vous notent et laissent des commentaires pour améliorer votre réputation.',
              Icons.star,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, String stepNumber, String title,
      String description, IconData icon, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? ThemeColors.shadowDark : ThemeColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ThemeColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        stepNumber,
                        style: TextStyle(
                          color: ThemeColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
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
}

// Services Info Screen
class ServicesInfoScreen extends StatelessWidget {
  final List<ServiceCategory> categories = [
    ServiceCategory('Nettoyage', 'Nettoyage de maisons, bureaux, vitres',
        Icons.cleaning_services, [
      'Nettoyage de maison',
      'Nettoyage de bureau',
      'Nettoyage de vitres',
      'Nettoyage après travaux',
    ]),
    ServiceCategory(
        'Jardinage', 'Entretien d\'espaces verts, tonte', Icons.grass, [
      'Tonte de pelouse',
      'Taille de haies',
      'Plantation',
      'Arrosage',
    ]),
    ServiceCategory(
        'Garde d\'enfants', 'Baby-sitting, accompagnement', Icons.child_care, [
      'Baby-sitting ponctuel',
      'Garde de soirée',
      'Accompagnement scolaire',
      'Activités créatives',
    ]),
    ServiceCategory('Bricolage', 'Petites réparations, montage', Icons.build, [
      'Montage de meubles',
      'Réparations mineures',
      'Installation d\'étagères',
      'Peinture',
    ]),
    ServiceCategory(
        'Livraison', 'Transport de colis, courses', Icons.delivery_dining, [
      'Livraison de colis',
      'Courses alimentaires',
      'Transport de meubles',
      'Déménagement léger',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Services disponibles'),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildServiceCard(context, category, isDark);
        },
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, ServiceCategory category, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: ThemeColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: ThemeColors.primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      category.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: category.services
                .map((service) => Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ThemeColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ThemeColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        service,
                        style: TextStyle(
                          color: ThemeColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// Payment Info Screen
class PaymentInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Paiements & Tarifs'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              context,
              'Comment ça marche',
              'Les paiements sont sécurisés et s\'effectuent directement entre le client et le prestataire après validation du service.',
              Icons.payment,
              isDark,
            ),
            SizedBox(height: 16),
            _buildInfoCard(
              context,
              'Modes de paiement',
              'Espèces, virement bancaire. Le mode de paiement est convenu entre les parties.',
              Icons.account_balance_wallet,
              isDark,
            ),
            SizedBox(height: 16),
            _buildInfoCard(
              context,
              'Frais de service',
              'Khidma ne prélève aucune commission sur les transactions. L\'application est gratuite.',
              Icons.money_off,
              isDark,
            ),
            SizedBox(height: 16),
            _buildInfoCard(
              context,
              'Tarification',
              'Les tarifs sont librement fixés par les prestataires selon leurs compétences et le marché local.',
              Icons.local_offer,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String content,
      IconData icon, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? ThemeColors.shadowDark : ThemeColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: ThemeColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: ThemeColors.primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  content,
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
}

// Service Category Model
class ServiceCategory {
  final String name;
  final String description;
  final IconData icon;
  final List<String> services;

  ServiceCategory(this.name, this.description, this.icon, this.services);
}
