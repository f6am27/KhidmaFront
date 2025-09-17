// import 'package:flutter/material.dart';
// import '../../../../../constants/colors.dart';

// class WorkerSettingsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         title: Text(
//           'Paramètres',
//           style: TextStyle(
//             color: AppColors.textPrimary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 20),

//             // Account Section
//             _buildSectionTitle(context, 'Votre compte'),
//             _buildSettingsItem(
//               context: context,
//               icon: Icons.person_outline,
//               title: 'Modifier le Profil',
//               subtitle: 'Photo, nom, informations personnelles',
//               onTap: () => _navigateToProfileEdit(context),
//             ),
//             _buildSettingsItem(
//               context: context,
//               icon: Icons.lock_outline,
//               title: 'Sécurité',
//               subtitle: 'Mot de passe, authentification',
//               onTap: () => _navigateToSecurity(context),
//             ),
//             _buildSettingsItem(
//               context: context,
//               icon: Icons.work_outline,
//               title: 'Disponibilité',
//               subtitle: 'Gérer vos horaires de travail',
//               onTap: () => _navigateToAvailability(context),
//             ),
//             SizedBox(height: 30),

//             // Preferences Section
//             _buildSectionTitle(context, 'Préférences'),
//             _buildSettingsItem(
//               context: context,
//               icon: Icons.language,
//               title: 'Langue',
//               subtitle: 'Changer la langue de l\'application',
//               onTap: () => _navigateToLanguage(context),
//             ),
//             _buildThemeSettingsItem(context),
//             _buildSettingsItem(
//               context: context,
//               icon: Icons.notifications_outlined,
//               title: 'Notifications',
//               subtitle: 'Préférences de notification',
//               onTap: () => _navigateToNotifications(context),
//             ),
//             SizedBox(height: 30),

//             // Business Section
//             _buildSectionTitle(context, 'Activité professionnelle'),
//             _buildSettingsItem(
//               context: context,
//               icon: Icons.account_balance_wallet_outlined,
//               title: 'Paiements',
//               subtitle: 'Méthodes de paiement et retraits',
//               onTap: () => _navigateToPayments(context),
//             ),
//             _buildSettingsItem(
//               context: context,
//               icon: Icons.analytics_outlined,
//               title: 'Statistiques',
//               subtitle: 'Voir vos performances détaillées',
//               onTap: () => _navigateToAnalytics(context),
//             ),
//             SizedBox(height: 30),

//             // Support Section
//             _buildSectionTitle(context, 'Support'),
//             _buildSettingsItem(
//               context: context,
//               icon: Icons.help_outline,
//               title: 'Aide & Support',
//               subtitle: 'FAQ, contact, signaler un problème',
//               onTap: () => _navigateToSupport(context),
//             ),
//             _buildSettingsItem(
//               context: context,
//               icon: Icons.description_outlined,
//               title: 'Conditions d\'utilisation',
//               subtitle: 'Nos conditions générales',
//               onTap: () => _navigateToTerms(context),
//             ),
//             _buildSettingsItem(
//               context: context,
//               icon: Icons.privacy_tip_outlined,
//               title: 'Politique de confidentialité',
//               subtitle: 'Protection de vos données',
//               onTap: () => _navigateToPrivacy(context),
//             ),
//             _buildSettingsItem(
//               context: context,
//               icon: Icons.logout,
//               title: 'Déconnexion',
//               subtitle: 'Se déconnecter de l\'application',
//               onTap: () => _showLogoutDialog(context),
//               textColor: Colors.red,
//             ),
//             SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(BuildContext context, String title) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textSecondary,
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingsItem({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//     Color? textColor,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               size: 24,
//               color: textColor ?? AppColors.textPrimary,
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: textColor ?? AppColors.textPrimary,
//                     ),
//                   ),
//                   SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: 16,
//               color: AppColors.mediumGray,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildThemeSettingsItem(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       child: Row(
//         children: [
//           Icon(
//             Icons.dark_mode,
//             size: 24,
//             color: AppColors.textPrimary,
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Thème de l\'application',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   'Mode sombre ou clair',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Switch(
//             value: false, // You can manage this with a state provider
//             onChanged: (value) {
//               // Handle theme toggle
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Fonction thème en développement'),
//                   backgroundColor: AppColors.primaryPurple,
//                 ),
//               );
//             },
//             activeColor: AppColors.primaryPurple,
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToProfileEdit(BuildContext context) {
//     // Navigate to profile edit
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Navigation vers modification du profil'),
//         backgroundColor: AppColors.primaryPurple,
//       ),
//     );
//   }

//   void _navigateToSecurity(BuildContext context) {
//     // Navigate to security settings
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Navigation vers paramètres de sécurité'),
//         backgroundColor: AppColors.primaryPurple,
//       ),
//     );
//   }

//   void _navigateToAvailability(BuildContext context) {
//     // Navigate to availability settings
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Navigation vers gestion de disponibilité'),
//         backgroundColor: AppColors.primaryPurple,
//       ),
//     );
//   }

//   void _navigateToLanguage(BuildContext context) {
//     // Navigate to language settings
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Navigation vers paramètres de langue'),
//         backgroundColor: AppColors.primaryPurple,
//       ),
//     );
//   }

//   void _navigateToNotifications(BuildContext context) {
//     // Navigate to notification settings
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Navigation vers paramètres de notifications'),
//         backgroundColor: AppColors.primaryPurple,
//       ),
//     );
//   }

//   void _navigateToPayments(BuildContext context) {
//     // Navigate to payment settings
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Navigation vers paramètres de paiement'),
//         backgroundColor: AppColors.primaryPurple,
//       ),
//     );
//   }

//   void _navigateToAnalytics(BuildContext context) {
//     // Navigate to analytics
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Navigation vers statistiques détaillées'),
//         backgroundColor: AppColors.primaryPurple,
//       ),
//     );
//   }

//   void _navigateToSupport(BuildContext context) {
//     // Navigate to support
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Navigation vers aide et support'),
//         backgroundColor: AppColors.primaryPurple,
//       ),
//     );
//   }

//   void _navigateToTerms(BuildContext context) {
//     // Navigate to terms
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Navigation vers conditions d\'utilisation'),
//         backgroundColor: AppColors.primaryPurple,
//       ),
//     );
//   }

//   void _navigateToPrivacy(BuildContext context) {
//     // Navigate to privacy policy
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Navigation vers politique de confidentialité'),
//         backgroundColor: AppColors.primaryPurple,
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppColors.cardBackground,
//         title: Text(
//           'Déconnexion',
//           style: TextStyle(color: AppColors.textPrimary),
//         ),
//         content: Text(
//           'Êtes-vous sûr de vouloir vous déconnecter ?',
//           style: TextStyle(color: AppColors.textSecondary),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Annuler',
//               style: TextStyle(color: AppColors.textSecondary),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _performLogout(context);
//             },
//             child: Text(
//               'Se déconnecter',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _performLogout(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Déconnexion réussie'),
//         backgroundColor: AppColors.green,
//       ),
//     );
//     // Handle logout logic here
//   }
// }
