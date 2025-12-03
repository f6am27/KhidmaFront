import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../models/models.dart';
import '../../../services/task_service.dart';
import '../../../services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'task_candidates.dart';
import 'create_task.dart';
import '../../shared_screens/dialogs/subscription_prompt_dialog.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<TaskModel> _allTasks = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await taskService.getMyTasks();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['ok'] == true) {
          _allTasks = result['tasks'] as List<TaskModel>;
        } else {
          _errorMessage = result['error'];
        }
      });
    }
  }

  /// Mes tâches = tâches publiées ou actives
  List<TaskModel> get _myTasks {
    return _allTasks
        .where((task) =>
            task.status == TaskStatus.published ||
            task.status == TaskStatus.active)
        .toList();
  }

  /// Tâches annulées
  List<TaskModel> get _cancelledTasks {
    return _allTasks
        .where((task) => task.status == TaskStatus.cancelled)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes prestationss'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ThemeColors.primaryColor,
          labelColor: ThemeColors.primaryColor,
          unselectedLabelColor: Colors.grey[600],
          isScrollable: true,
          tabs: const [
            Tab(text: 'prestations'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTasksList(_myTasks, 'my'),
                    _buildTasksList(_cancelledTasks, 'cancelled'),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTaskWithLimitCheck,
        backgroundColor: ThemeColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Créer une nouvelle tâche',
      ),
    );
  }

  // ───────────────── ÉTATS GÉNÉRAUX ─────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(ThemeColors.primaryColor),
          ),
          const SizedBox(height: 16),
          const Text('Chargement des tâches...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTasks,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── LISTES & CARTES ─────────────────

  Widget _buildTasksList(List<TaskModel> tasks, String type) {
    if (tasks.isEmpty) {
      return _buildEmptyState(type);
    }
    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildTaskCard(tasks[index], type),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = task.status == TaskStatus.active;
    final hasAssignedProvider = task.assignedProvider != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? ThemeColors.shadowDark : ThemeColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getServiceIcon(task.serviceType),
                  color: _getStatusColor(task.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(task.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${task.budget} MRU',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(task.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            task.description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Localisation + heure
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.location,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                ),
              ),
              Icon(
                Icons.schedule,
                size: 16,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                task.preferredTime,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
              ),
            ],
          ),

          // Candidats (Mes Tâches)
          if (type == 'my' &&
              task.status == TaskStatus.published &&
              !hasAssignedProvider &&
              task.applicantsCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    color: ThemeColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${task.applicantsCount} candidat(s) intéressé(s)',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _viewCandidates(task),
                    child: Text(
                      'Voir',
                      style: TextStyle(color: ThemeColors.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Prestataire assigné + notation
          // Prestataire assigné + notation
          if (hasAssignedProvider) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.green,
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.assignedProvider!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // عرض التقييم الحالي فقط (إذا كان موجوداً)
                        if (task.providerRating != null &&
                            task.providerRating! > 0)
                          Row(
                            children: List.generate(5, (index) {
                              final rating = task.providerRating ?? 0;
                              return Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                size: 14,
                                color: Colors.amber,
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
                  // أزرار الاتصال والتقييم - فقط للمهام النشطة
                  if (type == 'my' && isActive) ...[
                    // زر التقييم
                    IconButton(
                      onPressed: () => _rateWorker(task),
                      icon: const Icon(Icons.star_outline),
                      color: Colors.orange,
                      tooltip: 'Évaluer',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    // زر الاتصال/الرسالة
                    IconButton(
                      onPressed: () => _contactProvider(task),
                      icon: const Icon(Icons.phone),
                      color: ThemeColors.primaryColor,
                      tooltip: 'Contacter',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          _buildActionButtons(task, type),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TaskModel task, String type) {
    final isPublished = task.status == TaskStatus.published;
    final hasAssignedProvider = task.assignedProvider != null;

    if (type == 'my') {
      // فقط المهام المنشورة بدون عامل مُعيّن تظهر لها أزرار التعديل والإلغاء
      if (isPublished && !hasAssignedProvider) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _editTask(task),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ThemeColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Modifier',
                  style: TextStyle(color: ThemeColors.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _cancelTask(task),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Annuler'),
              ),
            ),
          ],
        );
      }

      // المهام النشطة (مع عامل مُعيّن) لا تظهر لها أزرار هنا
      // لأن أزرار التقييم والاتصال موجودة في قسم العامل المُعيّن
      return const SizedBox.shrink();
    }

    // تبويب المهام الملغاة لا يحتاج أزرار
    return const SizedBox.shrink();
  }

  // ───────────────── ÉTAT VIDE ─────────────────

  Widget _buildEmptyState(String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String title, subtitle;
    IconData icon;

    switch (type) {
      case 'my':
        icon = Icons.inbox_outlined;
        title = 'Aucune tâche pour le moment';
        subtitle = 'Créez votre première tâche pour trouver un prestataire.';
        break;
      case 'cancelled':
        icon = Icons.cancel_outlined;
        title = 'Aucune tâche annulée';
        subtitle = 'Vos tâches annulées apparaîtront ici.';
        break;
      default:
        icon = Icons.inbox_outlined;
        title = 'Aucune tâche';
        subtitle = 'Vos tâches apparaîtront ici.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
          ),
          if (type == 'my') ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _createNewTaskWithLimitCheck,
              icon: const Icon(Icons.add),
              label: const Text('Créer une tâche'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───────────────── UTILITAIRES ─────────────────

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.published:
        return Colors.blue;
      case TaskStatus.active:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'nettoyage':
        return Icons.cleaning_services;
      case 'plomberie':
        return Icons.plumbing;
      case 'électricité':
        return Icons.electrical_services;
      case 'jardinage':
        return Icons.grass;
      case 'peinture':
        return Icons.format_paint;
      case 'déménagement':
        return Icons.local_shipping;
      case 'réparation':
        return Icons.build;
      case 'cuisine':
        return Icons.restaurant;
      case 'autre':
        return Icons.work_outline;
      default:
        return Icons.work_outline;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.published:
        return 'Publiée';
      case TaskStatus.active:
        return 'Active';
      case TaskStatus.cancelled:
        return 'Annulée';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a ${weeks} sem';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a ${months} mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a ${years} an${years > 1 ? 's' : ''}';
    }
  }

  // ───────────────── NAVIGATION & ACTIONS ─────────────────

  Future<void> _createNewTaskWithLimitCheck() async {
    // Vérifier la limite avant d’ouvrir l’écran de création
    final result = await paymentService.checkTaskLimit();

    if (result['ok'] == true && result['counter'] != null) {
      final counter = result['counter'];
      if (counter.needsSubscription) {
        await SubscriptionPromptDialog.show(
          context,
          role: 'client',
          tasksUsed: counter.tasksUsed,
          tasksRemaining: counter.tasksRemaining,
          errorMessage: result['error']?.toString(),
        );
        return;
      }

      // Limite OK → on ouvre l’écran de création
      final navResult = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
      );
      if (navResult == true) {
        await _loadTasks();
        if (mounted) {
          _tabController.animateTo(0);
        }
      }
      return;
    }

    // En cas d’erreur réseau ou de format, on informe l’utilisateur
    if (mounted) {
      final message =
          result['error']?.toString() ?? 'Impossible de vérifier la limite.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
        ),
      );

      // On permet tout de même la création pour ne pas bloquer l’utilisateur
      final navResult = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
      );
      if (navResult == true) {
        await _loadTasks();
        if (mounted) {
          _tabController.animateTo(0);
        }
      }
    }
  }

  void _viewCandidates(TaskModel task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskCandidatesScreen(task: task),
      ),
    );
    if (result == true) _loadTasks();
  }

  Future<void> _contactProvider(TaskModel task) async {
    // تحقق من وجود رقم هاتف العامل
    if (task.providerPhone == null || task.providerPhone!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.warning_amber, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Numéro de téléphone non disponible'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      return;
    }

    // إنشاء رابط المكالمة الهاتفية
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: task.providerPhone,
    );

    try {
      // محاولة فتح تطبيق الهاتف
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // في حالة فشل فتح تطبيق الهاتف
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child:
                        Text('Impossible d\'ouvrir l\'application téléphone'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Text('Erreur: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _editTask(TaskModel task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(taskToEdit: task),
      ),
    );
    if (result == true) _loadTasks();
  }

  void _cancelTask(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Annuler la tâche'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir annuler cette tâche ?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, size: 20, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cette action est irréversible',
                      style: TextStyle(fontSize: 13, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non, garder'),
          ),
          ElevatedButton(
            onPressed: () => _performCancelTask(context, task),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _performCancelTask(
      BuildContext dialogContext, TaskModel task) async {
    Navigator.pop(dialogContext); // أغلق Dialog التأكيد

    // Loading overlay
    OverlayEntry? loadingOverlay;
    if (mounted) {
      loadingOverlay = OverlayEntry(
        builder: (context) => Container(
          color: Colors.black54,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(ThemeColors.primaryColor),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(loadingOverlay);
    }

    try {
      final result = await taskService.cancelTask(taskId: task.id);

      loadingOverlay?.remove();
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      if (result['ok'] == true) {
        // نجح الإلغاء
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(child: Text('Tâche annulée avec succès')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        _loadTasks(); // إعادة تحميل المهام
      } else {
        // فشل الإلغاء
        final errorMsg = result['error'] ?? 'Échec d\'annulation';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMsg)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      loadingOverlay?.remove();
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Text('Erreur: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
  // ───────────────── SYSTÈME D’ÉVALUATION ─────────────────

  Future<void> _submitReview(TaskModel task, int rating, String comment) async {
    OverlayEntry? loadingOverlay;

    if (mounted) {
      loadingOverlay = OverlayEntry(
        builder: (context) => Container(
          color: Colors.black54,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(ThemeColors.primaryColor),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(loadingOverlay);
    }

    try {
      final result = await taskService.submitTaskReview(
        taskId: task.id,
        rating: rating,
        reviewText: comment.isEmpty ? null : comment,
      );

      loadingOverlay?.remove();
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      if (result['ok'] == true) {
        _showReviewSuccessDialog();
        _loadTasks();
      } else {
        final errorMsg = result['error'] ?? 'Erreur';

        if (errorMsg.toLowerCase().contains('déjà') ||
            errorMsg.toLowerCase().contains('already') ||
            errorMsg.toLowerCase().contains('existe')) {
          // Déjà évalué
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Déjà évalué',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Vous avez déjà évalué ce prestataire pour cette tâche.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          'Compris',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(child: Text(errorMsg.toString())),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      loadingOverlay?.remove();
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Text('Erreur: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showReviewSuccessDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Merci pour votre avis !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Votre évaluation a été envoyée avec succès.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'D\'accord',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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

  void _rateWorker(TaskModel task) {
    int selectedRating = 5;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        '🤩',
                        style: TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Laissez votre avis',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          task.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                      if (task.assignedProvider != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Prestataire: ${task.assignedProvider!}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: ThemeColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRating = index + 1;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                index < selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 44,
                                color: const Color(0xFFFFA726),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: commentController,
                            maxLines: 4,
                            maxLength: 500,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2D2D2D),
                            ),
                            decoration: const InputDecoration(
                              hintText:
                                  'Partagez votre expérience avec ce prestataire...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFAAAAAA),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                              counterStyle: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _submitReview(
                                task,
                                selectedRating,
                                commentController.text.trim(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: const Text(
                              'Envoyer l\'avis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      commentController.dispose();
    });
  }
}
