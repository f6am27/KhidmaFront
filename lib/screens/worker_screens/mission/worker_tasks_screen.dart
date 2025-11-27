import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../models/models.dart';
import '../../../services/task_service.dart';
import 'task_details_screen.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// import '../../../services/chat_service.dart';
// import '../../shared_screens/messages/chat_screen.dart';

class WorkerTasksScreen extends StatefulWidget {
  const WorkerTasksScreen({Key? key}) : super(key: key);

  @override
  _WorkerTasksScreenState createState() => _WorkerTasksScreenState();
}

class _WorkerTasksScreenState extends State<WorkerTasksScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<TaskModel> _allTasks = [];
  String? _errorMessage;
  bool _tabIndexLoaded = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _loadSavedTabIndex();
    _tabController.addListener(_onTabChanged);
    _loadTasks();
  }

  Future<void> _loadSavedTabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('worker_tasks_tab_index') ?? 0;
    if (!mounted) return;

    final initialIndex =
        (saved >= 0 && saved < _tabController.length) ? saved : 0;
    setState(() {
      _tabController.index = initialIndex;
      _tabIndexLoaded = true;
    });
  }

  void _onTabChanged() async {
    if (!_tabController.indexIsChanging) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('worker_tasks_tab_index', _tabController.index);
    }
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
        if (result['ok']) {
          _allTasks = result['tasks'] as List<TaskModel>;

          print('🔎 Loaded ${_allTasks.length} tasks');
          for (final t in _allTasks) {
            print(
                'Task ${t.id} clientId=${t.clientId}, clientPhone=${t.clientPhone}');
          }
        } else {
          _errorMessage = result['error'];
        }
      });
    }
  }

  List<TaskModel> get _acceptedTasks {
    return _allTasks
        .where((task) =>
            task.status == TaskStatus.active &&
            task.assignedProvider != null &&
            task.workStartedAt == null)
        .toList();
  }

  List<TaskModel> get _inProgressTasks {
    return _allTasks
        .where((task) =>
            task.status == TaskStatus.active && task.workStartedAt != null)
        .toList();
  }

  List<TaskModel> get _completedTasks {
    return _allTasks
        .where((task) =>
            task.status == TaskStatus.completed ||
            task.status == TaskStatus.workCompleted)
        .toList();
  }

  List<TaskModel> get _cancelledTasks {
    return _allTasks
        .where((task) => task.status == TaskStatus.cancelled)
        .toList();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ إذا الـ tab index لم يُحمّل بعد، اعرضي loader
    if (!_tabIndexLoaded) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            'Mes Tâches',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkTextPrimary
                  : ThemeColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
          ),
        ),
      );
    }

    // ✅ بعد تحميل الـ index، اعرضي الواجهة الكاملة
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Mes Tâches',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryPurple,
          labelColor: AppColors.primaryPurple,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
              ? ThemeColors.darkTextSecondary
              : ThemeColors.lightTextSecondary,
          labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
          isScrollable: true,
          tabs: [
            Tab(text: 'Acceptées'),
            Tab(text: 'En cours'),
            Tab(text: 'Terminées'),
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
                    _buildTasksList(_acceptedTasks, 'accepted'),
                    _buildTasksList(_inProgressTasks, 'inprogress'),
                    _buildTasksList(_completedTasks, 'completed'),
                    _buildTasksList(_cancelledTasks, 'cancelled'),
                  ],
                ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
          ),
          SizedBox(height: 16),
          Text('Chargement des tâches...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Erreur de chargement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text(_errorMessage ?? 'Une erreur est survenue',
                textAlign: TextAlign.center),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTasks,
              icon: Icon(Icons.refresh),
              label: Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(List<TaskModel> tasks, String type) {
    if (tasks.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: tasks.length,
        separatorBuilder: (context, index) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskCard(task, type);
        },
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, String type) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeColors.darkCardBackground
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getServiceIcon(task.serviceType),
                  color: _getStatusColor(task.status),
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? ThemeColors.darkTextPrimary
                            : ThemeColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(task.status),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${task.budget} MRU',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            task.description,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkTextSecondary
                  : ThemeColors.lightTextSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.location,
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text(
                task.preferredTime,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 14, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text(
                _formatDate(task.createdAt),
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Spacer(),
              if (task.isUrgent)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ],
          ),
          SizedBox(height: 16),
          _buildActionButtons(task, type),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TaskModel task, String type) {
    switch (type) {
      case 'accepted':
        // ✅ في Acceptées: [Annuler] [Commencer] [📞]
        return Row(
          children: [
            // زر الإلغاء
            Expanded(
              child: OutlinedButton(
                onPressed: () => _cancelTask(task),
                child: Text('Annuler'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 8),

            // زر البدء
            Expanded(
              child: ElevatedButton(
                onPressed: () => _startTask(task),
                child: Text('Commencer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 8),

            // ✅ أيقونة الهاتف - بدون خلفية، لون أخضر فقط
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: ThemeColors.successColor, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  print('📞 [Acceptées] Calling client for task ${task.id}');
                  print('📞 [Acceptées] clientPhone = "${task.clientPhone}"');
                  _callClient(task);
                },
                icon: Icon(Icons.phone,
                    color: ThemeColors.successColor, size: 20),
                tooltip: 'Appeler',
                padding: EdgeInsets.all(12),
              ),
            ),
          ],
        );

      case 'inprogress':
        // ✅ في En cours: [Appeler] [Terminée] - نفس الحجم
        return Row(
          children: [
            // زر الاتصال
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  print('📞 [En cours] Calling client for task ${task.id}');
                  print('📞 [En cours] clientPhone = "${task.clientPhone}"');
                  _callClient(task);
                },
                icon: Icon(Icons.phone, size: 18),
                label: Text('Appeler'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeColors.successColor,
                  side: BorderSide(color: ThemeColors.successColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),

            // زر الإنهاء - نفس الحجم تماماً
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _completeTask(task),
                icon: Icon(Icons.check, size: 18),
                label: Text('Terminée'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        );

      case 'completed':
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _viewTaskDetails(task),
            icon: Icon(Icons.visibility_outlined, size: 16),
            label: Text('Voir détails'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPurple,
              side: BorderSide(color: AppColors.primaryPurple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );

      case 'cancelled':
      default:
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.lightGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Tâche annulée',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeColors.darkTextSecondary
                    : ThemeColors.lightTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
    }
  }

  Widget _buildEmptyState(String type) {
    String title, subtitle;
    IconData icon;

    switch (type) {
      case 'accepted':
        icon = Icons.handshake_outlined;
        title = 'Aucune tâche acceptée';
        subtitle = 'Les tâches que vous acceptez apparaîtront ici';
        break;
      case 'inprogress':
        icon = Icons.work_outline;
        title = 'Aucune tâche en cours';
        subtitle = 'Vos tâches actives apparaîtront ici';
        break;
      case 'completed':
        icon = Icons.check_circle_outline;
        title = 'Aucune tâche terminée';
        subtitle = 'Vos tâches complétées apparaîtront ici';
        break;
      case 'cancelled':
        icon = Icons.cancel_outlined;
        title = 'Aucune tâche annulée';
        subtitle = 'Vos tâches annulées apparaîtront ici';
        break;
      default:
        icon = Icons.inbox_outlined;
        title = 'Aucune tâche';
        subtitle = 'Vos tâches apparaîtront ici';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.mediumGray),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeColors.darkTextPrimary
                  : ThemeColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.published:
      case TaskStatus.active:
        return AppColors.cyan;
      case TaskStatus.workCompleted:
        return AppColors.orange;
      case TaskStatus.completed:
        return AppColors.green;
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
      case 'garde d\'enfants':
        return Icons.child_care;
      default:
        return Icons.work_outline;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.published:
        return 'Acceptée';
      case TaskStatus.active:
        return 'En cours';
      case TaskStatus.workCompleted:
        return 'À payer';
      case TaskStatus.completed:
        return 'Payée';
      case TaskStatus.cancelled:
        return 'Annulée';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0)
      return 'Aujourd\'hui';
    else if (difference.inDays == 1)
      return 'Hier';
    else if (difference.inDays < 7)
      return '${difference.inDays} jours';
    else
      return '${date.day}/${date.month}/${date.year}';
  }

  // ✅ الحل: استخدام Builder للحصول على context صحيح
  void _startTask(TaskModel task) {
    bool isLoading = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          // ✅ لتحديث Dialog من الداخل
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.85),
              title: Text('Commencer la tâche'),
              content: isLoading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.primaryPurple),
                        ),
                        SizedBox(height: 16),
                        Text('Traitement en cours...'),
                      ],
                    )
                  : Text('Êtes-vous prêt à commencer cette tâche ?'),
              actions: isLoading
                  ? [] // ✅ لا أزرار أثناء التحميل
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text('Pas encore'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // ✅ بدء التحميل داخل Dialog
                          setDialogState(() {
                            isLoading = true;
                          });

                          try {
                            // ✅ الإرسال للـ backend
                            final result = await taskService.updateTaskStatus(
                              taskId: task.id,
                              status: 'start_work',
                            );

                            // ✅ إغلاق Dialog
                            if (Navigator.of(dialogContext).canPop()) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (!mounted) return;

                            // ✅ عرض النتيجة
                            if (result['ok']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Tâche commencée avec succès'),
                                  backgroundColor: AppColors.green,
                                ),
                              );
                              await _loadTasks();
                              if (mounted) {
                                _tabController.animateTo(1); // En cours tab
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['error'] ?? 'Erreur'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            // ✅ إغلاق Dialog في حالة الخطأ
                            if (Navigator.of(dialogContext).canPop()) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Text('Commencer',
                            style: TextStyle(color: AppColors.primaryPurple)),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  // Future<void> _performStartTask(TaskModel task) async {
  //   OverlayEntry? loadingOverlay;

  //   if (mounted) {
  //     loadingOverlay = OverlayEntry(
  //       builder: (overlayContext) => Container(
  //         color: Colors.black54,
  //         child: Center(
  //           child: CircularProgressIndicator(
  //             valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
  //           ),
  //         ),
  //       ),
  //     );
  //     Overlay.of(context).insert(loadingOverlay);
  //   }

  //   try {
  //     final result = await taskService.updateTaskStatus(
  //       taskId: task.id,
  //       status: 'start_work',
  //     );

  //     loadingOverlay?.remove();

  //     if (!mounted) return;

  //     if (result['ok']) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Tâche commencée avec succès'),
  //           backgroundColor: AppColors.green,
  //         ),
  //       );
  //       await _loadTasks();
  //       if (mounted) {
  //         _tabController.animateTo(1);
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(result['error'] ?? 'Erreur'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     loadingOverlay?.remove();
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Erreur: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  void _cancelTask(TaskModel task) {
    bool isLoading = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.85),
              title: Text('Annuler la tâche'),
              content: isLoading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.primaryPurple),
                        ),
                        SizedBox(height: 16),
                        Text('Traitement en cours...'),
                      ],
                    )
                  : Text('Êtes-vous sûr de vouloir annuler cette tâche ?'),
              actions: isLoading
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text('Non'),
                      ),
                      TextButton(
                        onPressed: () async {
                          setDialogState(() {
                            isLoading = true;
                          });

                          try {
                            final result = await taskService.updateTaskStatus(
                              taskId: task.id,
                              status: 'cancelled',
                            );

                            if (Navigator.of(dialogContext).canPop()) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (!mounted) return;

                            if (result['ok']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Tâche annulée'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              await _loadTasks();
                              if (mounted) {
                                _tabController.animateTo(3); // Annulées tab
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['error'] ?? 'Erreur'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            if (Navigator.of(dialogContext).canPop()) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Text('Oui', style: TextStyle(color: Colors.red)),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  // Future<void> _performCancelTask(TaskModel task) async {
  //   OverlayEntry? loadingOverlay;

  //   if (mounted) {
  //     loadingOverlay = OverlayEntry(
  //       builder: (context) => Container(
  //         color: Colors.black54,
  //         child: Center(
  //           child: CircularProgressIndicator(
  //             valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
  //           ),
  //         ),
  //       ),
  //     );
  //     Overlay.of(context).insert(loadingOverlay);
  //   }

  //   try {
  //     final result = await taskService.updateTaskStatus(
  //       taskId: task.id,
  //       status: 'cancelled',
  //     );

  //     loadingOverlay?.remove();

  //     if (!mounted) return;

  //     if (result['ok']) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Tâche annulée'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       await _loadTasks();
  //       if (mounted) {
  //         _tabController.animateTo(3);
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(result['error'] ?? 'Erreur'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     loadingOverlay?.remove();
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Erreur: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  void _completeTask(TaskModel task) {
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5), // ✅ خلفية شفافة
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.85),
              title: Text('Marquer comme terminée'),
              content: isLoading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.primaryPurple),
                        ),
                        SizedBox(height: 16),
                        Text('Traitement en cours...'),
                      ],
                    )
                  : Text('Avez-vous terminé cette tâche ?'),
              actions: isLoading
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text('Pas encore'),
                      ),
                      TextButton(
                        onPressed: () async {
                          setDialogState(() {
                            isLoading = true;
                          });

                          try {
                            final result = await taskService.updateTaskStatus(
                              taskId: task.id,
                              status: 'work_completed',
                            );

                            if (Navigator.of(dialogContext).canPop()) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (!mounted) return;

                            if (result['ok']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Tâche marquée comme terminée'),
                                  backgroundColor: AppColors.green,
                                ),
                              );
                              await _loadTasks();
                              if (mounted) {
                                _tabController.animateTo(2); // Terminées tab
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['error'] ?? 'Erreur'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            if (Navigator.of(dialogContext).canPop()) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Text('Terminée',
                            style: TextStyle(color: AppColors.green)),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  // Future<void> _performCompleteTask(TaskModel task) async {
  //   OverlayEntry? loadingOverlay;

  //   if (mounted) {
  //     loadingOverlay = OverlayEntry(
  //       builder: (context) => Container(
  //         color: Colors.black54,
  //         child: Center(
  //           child: CircularProgressIndicator(
  //             valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
  //           ),
  //         ),
  //       ),
  //     );
  //     Overlay.of(context).insert(loadingOverlay);
  //   }

  //   try {
  //     final result = await taskService.updateTaskStatus(
  //       taskId: task.id,
  //       status: 'work_completed',
  //     );

  //     loadingOverlay?.remove();

  //     if (!mounted) return;

  //     if (result['ok']) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Tâche marquée comme terminée'),
  //           backgroundColor: AppColors.green,
  //         ),
  //       );
  //       await _loadTasks();
  //       if (mounted) {
  //         _tabController.animateTo(2);
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(result['error'] ?? 'Erreur'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     loadingOverlay?.remove();
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Erreur: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  // void _showContactMenu(TaskModel task) {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;

  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     builder: (bottomSheetContext) {
  //       return Container(
  //         decoration: BoxDecoration(
  //           color: isDark ? ThemeColors.darkSurface : Colors.white,
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //         ),
  //         padding: EdgeInsets.symmetric(vertical: 20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             // ✅ مقبض السحب
  //             Container(
  //               width: 40,
  //               height: 4,
  //               decoration: BoxDecoration(
  //                 color: isDark ? Colors.grey[700] : Colors.grey[300],
  //                 borderRadius: BorderRadius.circular(2),
  //               ),
  //             ),
  //             SizedBox(height: 20),

  //             // ✅ خيار الاتصال
  //             ListTile(
  //               leading: Container(
  //                 padding: EdgeInsets.all(8),
  //                 decoration: BoxDecoration(
  //                   color: ThemeColors.successColor.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Icon(Icons.phone, color: ThemeColors.successColor),
  //               ),
  //               title: Text(
  //                 'Appel téléphonique',
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //               onTap: () {
  //                 print(
  //                     '📞 Tapped Appel for task ${task.id}, clientPhone=${task.clientPhone}');
  //                 Navigator.pop(bottomSheetContext);
  //                 _callClient(task);
  //               },
  //             ),

  //             Divider(height: 1),

  //             // ✅ خيار الشات
  //             ListTile(
  //               leading: Container(
  //                 padding: EdgeInsets.all(8),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.primaryPurple.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Icon(Icons.chat_bubble_outline,
  //                     color: AppColors.primaryPurple),
  //               ),
  //               title: Text(
  //                 'Messagerie',
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //               onTap: () {
  //                 print(
  //                     '💬 Tapped Chat for task ${task.id}, clientId=${task.clientId}');
  //                 Navigator.pop(bottomSheetContext);
  //                 _openChatWithClient(task);
  //               },
  //             ),

  //             SizedBox(height: 10),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<void> _callClient(TaskModel task) async {
    final rawPhone = task.clientPhone ?? '';
    print('📞 _callClient for task ${task.id}, rawPhone="$rawPhone"');

    if (rawPhone.isEmpty) {
      print('⚠️ clientPhone is empty, showing snackbar');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Numéro du client indisponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String cleanPhone =
        rawPhone.replaceAll('+', '').replaceAll('222', '').trim();
    print('📞 Clean phone = "$cleanPhone"');

    final phoneNumber = 'tel://$cleanPhone';
    print('📞 Trying phoneNumber = $phoneNumber');

    try {
      if (await canLaunch(phoneNumber)) {
        print('✅ canLaunch tel://, launching');

        await launch(phoneNumber);
      } else {
        final fallbackPhone = 'tel:$cleanPhone';
        print('⚠️ cannot launch tel://, trying fallback: $fallbackPhone');
        if (await canLaunch(fallbackPhone)) {
          print('✅ launched fallback tel:');

          await launch(fallbackPhone);
        } else {
          throw 'Cannot launch dialer';
        }
      }
    } catch (e) {
      print('❌ _callClient error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Numéro: $cleanPhone\n(Testez sur un appareil réel)',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Future<void> _openChatWithClient(TaskModel task) async {
  //   print(
  //       '💬 _openChatWithClient for task ${task.id}, clientId=${task.clientId}');

  //   if (!mounted) return;

  //   // ✅ عرض loading
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => Center(
  //       child: CircularProgressIndicator(
  //         valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
  //       ),
  //     ),
  //   );

  //   try {
  //     final result = await chatService.startConversation(task.clientId);
  //     print('💬 startConversation result: $result');

  //     if (!mounted) return;

  //     // ✅ إغلاق loading
  //     Navigator.pop(context);

  //     if (!mounted) return;

  //     if (result['ok']) {
  //       print(
  //           '✅ Opening ChatScreen with conversationId=${result['conversation_id']}');

  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => ChatScreen(
  //             conversationId: result['conversation_id'],
  //             contactName: task.assignedProvider ?? 'Client',
  //             contactId: task.clientId,
  //             isOnline: false,
  //             profileImageUrl: null,
  //           ),
  //         ),
  //       );
  //     } else {
  //       // معالجة الأخطاء
  //       final errorMessage = (result['error'] ?? '').toString().toLowerCase();
  //       final statusCode = result['status'];

  //       String displayMessage;
  //       if (statusCode == 403 || errorMessage.contains('block')) {
  //         displayMessage =
  //             'Vous ne pouvez pas discuter avec un utilisateur bloqué';
  //       } else {
  //         displayMessage =
  //             result['error'] ?? 'Erreur lors du démarrage de la conversation';
  //       }

  //       if (!mounted) return;

  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //           title: Row(
  //             children: [
  //               Icon(Icons.block, color: Colors.red, size: 28),
  //               SizedBox(width: 12),
  //               Text('Accès refusé', style: TextStyle(fontSize: 18)),
  //             ],
  //           ),
  //           content: Text(displayMessage,
  //               style: TextStyle(fontSize: 15, height: 1.5)),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: Text('OK',
  //                   style: TextStyle(
  //                       fontSize: 16, color: AppColors.primaryPurple)),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('❌ Error in _openChatWithClient: $e');

  //     if (!mounted) return;

  //     Navigator.pop(context);

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Erreur: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  void _viewTaskDetails(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(
          task: task,
          userRole: 'worker',
        ),
      ),
    );
  }
}
