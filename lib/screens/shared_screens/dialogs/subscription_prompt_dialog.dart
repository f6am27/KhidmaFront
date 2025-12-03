import 'package:flutter/material.dart';

import '../../../core/theme/theme_colors.dart';
import '../../../constants/colors.dart';
import '../../../services/payment_service.dart';

/// Dialog d'abonnement réutilisable pour client et prestataire.
///
/// S'affiche lorsque la limite gratuite (ex : 5 tâches / 5 candidatures)
/// est atteinte.
class SubscriptionPromptDialog extends StatefulWidget {
  final String role; // 'client' ou 'worker'
  final int tasksUsed;
  final int tasksRemaining;
  final String? errorMessage;

  const SubscriptionPromptDialog({
    Key? key,
    required this.role,
    required this.tasksUsed,
    required this.tasksRemaining,
    this.errorMessage,
  }) : super(key: key);

  /// Helper statique pour afficher le dialog.
  ///
  /// Exemple d'utilisation :
  /// await SubscriptionPromptDialog.show(
  ///   context,
  ///   role: 'client',
  ///   tasksUsed: 5,
  ///   tasksRemaining: 0,
  ///   errorMessage: backendMessage,
  /// );
  static Future<void> show(
    BuildContext context, {
    required String role,
    required int tasksUsed,
    required int tasksRemaining,
    String? errorMessage,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => SubscriptionPromptDialog(
        role: role,
        tasksUsed: tasksUsed,
        tasksRemaining: tasksRemaining,
        errorMessage: errorMessage,
      ),
    );
  }

  @override
  State<SubscriptionPromptDialog> createState() =>
      _SubscriptionPromptDialogState();
}

class _SubscriptionPromptDialogState extends State<SubscriptionPromptDialog> {
  bool _isLoading = false;

  String get _title {
    return 'Limite atteinte';
  }

  String get _description {
    if (widget.role == 'worker') {
      return 'Vous avez atteint la limite de 5 candidatures gratuites.\n'
          'Abonnez-vous pour continuer à postuler aux missions.';
    }
    // Par défaut : client
    return 'Vous avez atteint la limite de 5 tâches gratuites.\n'
        'Abonnez-vous pour continuer à publier des tâches.';
  }

  String get _tasksUsageText {
    final total = (widget.tasksUsed + widget.tasksRemaining) > 0
        ? (widget.tasksUsed + widget.tasksRemaining)
        : 5; // fallback 5 si info manquante
    return '${widget.tasksUsed}/$total tâches utilisées';
  }

  Future<void> _onSubscribePressed() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await paymentService.subscribe();

      final ok = result['ok'] == true;
      final message = result['error']?.toString() ??
          result['json']?['message']?.toString() ??
          (ok
              ? 'L’abonnement sera disponible prochainement.'
              : 'Cette fonctionnalité sera bientôt disponible.');

      // Dans l’état actuel du produit, l’abonnement n’est pas encore actif.
      // On affiche donc toujours un message d’information.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[800],
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cette fonctionnalité sera bientôt disponible.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[800],
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        (isDark ? ThemeColors.darkCardBackground : Colors.white)
            .withOpacity(0.9);

    final primaryTextColor =
        isDark ? ThemeColors.darkTextPrimary : ThemeColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? ThemeColors.darkTextSecondary : Colors.grey[700];

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône / illustration
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primaryPurple,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),

              // Titre
              Text(
                _title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Description en fonction du rôle
              Text(
                _description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Ligne d’info sur l’utilisation des tâches
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : AppColors.primaryPurple)
                      .withOpacity(isDark ? 0.05 : 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.countertops_outlined,
                      size: 20,
                      color: AppColors.primaryPurple,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _tasksUsageText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Prix de l’abonnement
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: 18,
                    color: AppColors.primaryPurple,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Abonnement : 8 MRU/mois',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              // Message d’erreur backend optionnel
              if (widget.errorMessage != null &&
                  widget.errorMessage!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  widget.errorMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 20),

              // Boutons d’action
              Row(
                children: [
                  // Bouton "Compris"
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDark
                              ? ThemeColors.darkBorder
                              : Colors.grey[300]!,
                          width: 1.3,
                        ),
                      ),
                      child: Text(
                        'Compris',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Bouton "S'abonner maintenant"
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onSubscribePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'S’abonner maintenant',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
