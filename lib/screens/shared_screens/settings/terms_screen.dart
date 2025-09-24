import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';

class TermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Conditions d\'utilisation'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, isDark),
            SizedBox(height: 20),
            _buildTermsSection(
              context,
              '1. Acceptation des conditions',
              'En utilisant l\'application Khidma, vous acceptez d\'être lié par ces conditions d\'utilisation. Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser notre service.',
              Icons.check_circle_outline,
              isDark,
            ),
            SizedBox(height: 16),
            _buildTermsSection(
              context,
              '2. Description du service',
              'Khidma est une plateforme qui met en relation des clients avec des prestataires de services locaux. Nous facilitons la communication mais ne sommes pas responsables de la qualité des services fournis.',
              Icons.info_outline,
              isDark,
            ),
            SizedBox(height: 16),
            _buildTermsSection(
              context,
              '3. Inscription et profil',
              'Vous devez fournir des informations exactes et à jour lors de votre inscription. Vous êtes responsable de maintenir la confidentialité de vos informations de connexion.',
              Icons.person_outline,
              isDark,
            ),
            SizedBox(height: 16),
            _buildTermsSection(
              context,
              '4. Utilisation de la plateforme',
              'Vous vous engagez à utiliser Khidma de manière légale et respectueuse. Tout comportement abusif, frauduleux ou illégal peut entraîner la suspension de votre compte.',
              Icons.gavel,
              isDark,
            ),
            SizedBox(height: 16),
            _buildTermsSection(
              context,
              '5. Paiements et transactions',
              'Les paiements s\'effectuent directement entre clients et prestataires. Khidma ne prélève aucune commission mais n\'est pas responsable des litiges de paiement.',
              Icons.payment,
              isDark,
            ),
            SizedBox(height: 16),
            _buildTermsSection(
              context,
              '6. Responsabilité',
              'Khidma agit comme intermédiaire. Nous ne sommes pas responsables des dommages résultant des services fournis par les prestataires ou des interactions entre utilisateurs.',
              Icons.warning_amber_outlined,
              isDark,
            ),
            SizedBox(height: 16),
            _buildTermsSection(
              context,
              '7. Propriété intellectuelle',
              'Tout le contenu de l\'application Khidma, y compris les textes, images, logos et codes, est protégé par le droit d\'auteur et appartient à Khidma.',
              Icons.copyright,
              isDark,
            ),
            SizedBox(height: 16),
            _buildTermsSection(
              context,
              '8. Modifications des conditions',
              'Nous nous réservons le droit de modifier ces conditions à tout moment. Les utilisateurs seront informés des changements importants via l\'application.',
              Icons.update,
              isDark,
            ),
            SizedBox(height: 16),
            _buildTermsSection(
              context,
              '9. Résiliation',
              'Vous pouvez supprimer votre compte à tout moment. Nous nous réservons le droit de suspendre ou supprimer des comptes en cas de violation des conditions.',
              Icons.cancel_outlined,
              isDark,
            ),
            SizedBox(height: 16),
            _buildTermsSection(
              context,
              '10. Contact',
              'Pour toute question concernant ces conditions, contactez-nous à : Khidma.help@gmail.com',
              Icons.contact_support,
              isDark,
            ),
            SizedBox(height: 30),
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
              Icons.description,
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
                  'Conditions d\'utilisation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  'Dernière mise à jour : Septembre 2025',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(BuildContext context, String title, String content,
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
            Icons.verified_user,
            color: ThemeColors.primaryColor,
            size: 32,
          ),
          SizedBox(height: 12),
          Text(
            'En continuant à utiliser Khidma, vous confirmez avoir lu et accepté ces conditions d\'utilisation.',
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
