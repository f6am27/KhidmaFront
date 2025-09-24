import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Politique de confidentialité'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, isDark),
            SizedBox(height: 20),
            _buildPrivacySection(
              context,
              '1. Collecte des informations',
              'Nous collectons les informations que vous nous fournissez lors de votre inscription : nom, email, numéro de téléphone, localisation et compétences professionnelles.',
              Icons.person_search,
              isDark,
            ),
            SizedBox(height: 16),
            _buildPrivacySection(
              context,
              '2. Utilisation des données',
              'Vos données sont utilisées pour : faciliter la mise en relation avec des clients, améliorer nos services, vous envoyer des notifications importantes et assurer la sécurité de la plateforme.',
              Icons.settings_applications,
              isDark,
            ),
            SizedBox(height: 16),
            _buildPrivacySection(
              context,
              '3. Partage des informations',
              'Nous ne vendons jamais vos données personnelles. Vos informations de profil sont visibles par les autres utilisateurs pour faciliter les contacts professionnels.',
              Icons.share_outlined,
              isDark,
            ),
            SizedBox(height: 16),
            _buildPrivacySection(
              context,
              '4. Sécurité des données',
              'Nous utilisons des mesures de sécurité standards pour protéger vos informations : chiffrement des données, serveurs sécurisés et accès limité aux données personnelles.',
              Icons.security,
              isDark,
            ),
            SizedBox(height: 16),
            _buildPrivacySection(
              context,
              '5. Cookies et tracking',
              'Nous utilisons des cookies pour améliorer votre expérience utilisateur, mémoriser vos préférences et analyser l\'utilisation de l\'application.',
              Icons.cookie,
              isDark,
            ),
            SizedBox(height: 16),
            _buildPrivacySection(
              context,
              '6. Géolocalisation',
              'Votre localisation est utilisée pour vous proposer des services près de chez vous. Vous pouvez désactiver cette fonctionnalité dans les paramètres.',
              Icons.location_on_outlined,
              isDark,
            ),
            SizedBox(height: 16),
            _buildPrivacySection(
              context,
              '7. Conservation des données',
              'Nous conservons vos données tant que votre compte est actif. Après suppression de votre compte, certaines données peuvent être conservées pour des raisons légales.',
              Icons.storage,
              isDark,
            ),
            SizedBox(height: 16),
            _buildPrivacySection(
              context,
              '8. Droits des utilisateurs',
              'Vous avez le droit de : consulter vos données, les modifier, demander leur suppression, vous opposer à leur traitement et porter plainte auprès des autorités compétentes.',
              Icons.account_balance,
              isDark,
            ),
            SizedBox(height: 16),
            _buildPrivacySection(
              context,
              '9. Mineurs',
              'Khidma est destinée aux personnes majeures. Nous ne collectons pas sciemment d\'informations personnelles de personnes de moins de 18 ans.',
              Icons.child_care,
              isDark,
            ),
            SizedBox(height: 16),
            _buildPrivacySection(
              context,
              '10. Modifications de la politique',
              'Cette politique peut être modifiée. Les changements importants vous seront notifiés par email ou via l\'application.',
              Icons.update,
              isDark,
            ),
            SizedBox(height: 16),
            _buildPrivacySection(
              context,
              '11. Nous contacter',
              'Pour toute question sur cette politique ou vos données personnelles, contactez-nous à : khidma.help@gmail.com',
              Icons.contact_mail,
              isDark,
            ),
            SizedBox(height: 30),
            _buildDataTypesCard(context, isDark),
            SizedBox(height: 20),
            _buildFooterCard(context, isDark),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.primaryColor,
            ThemeColors.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.privacy_tip,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Politique de confidentialité',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  'Protection de vos données personnelles',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  'Dernière mise à jour : Septembre 2025',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(BuildContext context, String title,
      String content, IconData icon, bool isDark) {
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
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: ThemeColors.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTypesCard(BuildContext context, bool isDark) {
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
              Icon(
                Icons.data_usage,
                color: ThemeColors.primaryColor,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Types de données collectées',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildDataType(context, 'Informations personnelles',
              'Nom, prénom, email, téléphone', Icons.person, isDark),
          SizedBox(height: 8),
          _buildDataType(context, 'Informations de profil',
              'Compétences, expérience, photos', Icons.work, isDark),
          SizedBox(height: 8),
          _buildDataType(context, 'Données de localisation',
              'Adresse, zone de service', Icons.location_on, isDark),
          SizedBox(height: 8),
          _buildDataType(context, 'Données d\'utilisation',
              'Activité dans l\'app, préférences', Icons.analytics, isDark),
          SizedBox(height: 8),
          _buildDataType(context, 'Communications',
              'Messages, évaluations, commentaires', Icons.chat, isDark),
        ],
      ),
    );
  }

  Widget _buildDataType(BuildContext context, String title, String description,
      IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ThemeColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: ThemeColors.primaryColor,
            size: 16,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeColors.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shield_outlined,
            color: ThemeColors.primaryColor,
            size: 32,
          ),
          SizedBox(height: 12),
          Text(
            'Votre vie privée est importante',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Nous nous engageons à protéger vos données personnelles et à respecter votre vie privée conformément aux lois en vigueur.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}
