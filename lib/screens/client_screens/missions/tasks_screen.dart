import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../models/models.dart';
import '../../../services/task_service.dart';
import 'task_candidates.dart';
import 'create_task.dart';
import '../../worker_screens/mission/task_details_screen.dart';
import '../../../services/payment_service.dart';
import 'package:moosyl/moosyl.dart';

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
    _tabController = TabController(length: 4, vsync: this);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await taskService.getMyTasks();

    print('════════ TASKS DEBUG ════════');
    print('Result OK: ${result['ok']}');
    print(
        'Total tasks: ${result['tasks'] != null ? (result['tasks'] as List).length : 0}');

    if (result['tasks'] != null) {
      for (var task in result['tasks'] as List<TaskModel>) {
        print('─────────────────────────');
        print('Task: ${task.title}');
        print('Status: ${task.status}');
        print('Assigned: ${task.assignedProvider}');
      }
    }
    print('═══════════════════════════');

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['ok']) {
          _allTasks = result['tasks'] as List<TaskModel>;
        } else {
          _errorMessage = result['error'];
        }
      });
    }
  }

  List<TaskModel> get _publishedTasks {
    return _allTasks
        .where((task) => task.status == TaskStatus.published)
        .toList();
  }

  List<TaskModel> get _activeTasks {
    return _allTasks
        .where((task) =>
            task.status == TaskStatus.active ||
            task.status == TaskStatus.workCompleted)
        .toList();
  }

  List<TaskModel> get _completedTasks {
    return _allTasks
        .where((task) => task.status == TaskStatus.completed)
        .toList();
  }

  List<TaskModel> get _cancelledTasks {
    return _allTasks
        .where((task) => task.status == TaskStatus.cancelled)
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Tâches'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ThemeColors.primaryColor,
          labelColor: ThemeColors.primaryColor,
          unselectedLabelColor: Colors.grey[600],
          isScrollable: true,
          tabs: [
            Tab(text: 'Publiées'),
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
                    _buildTasksList(_publishedTasks, 'published'),
                    _buildTasksList(_activeTasks, 'active'),
                    _buildTasksList(_completedTasks, 'completed'),
                    _buildTasksList(_cancelledTasks, 'cancelled'),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewTask(),
        backgroundColor: ThemeColors.primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Créer une nouvelle tâche',
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(ThemeColors.primaryColor),
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
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTasks,
              icon: Icon(Icons.refresh),
              label: Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primaryColor,
                  foregroundColor: Colors.white),
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
        itemBuilder: (context, index) => _buildTaskCard(tasks[index], type),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWorkCompleted = task.status == TaskStatus.workCompleted;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: isDark ? ThemeColors.shadowDark : ThemeColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 4))
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
                    color: _getStatusColor(task.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(_getServiceIcon(task.serviceType),
                    color: _getStatusColor(task.status), size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black)),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: _getStatusColor(task.status),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(_getStatusText(task.status),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${task.budget} MRU',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.primaryColor)),
                  SizedBox(height: 4),
                  Text(_formatDate(task.createdAt),
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey[500])),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(task.description,
              style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: isDark ? Colors.white54 : Colors.grey[500]),
              SizedBox(width: 4),
              Expanded(
                  child: Text(task.location,
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.grey[500]))),
              Icon(Icons.schedule,
                  size: 16, color: isDark ? Colors.white54 : Colors.grey[500]),
              SizedBox(width: 4),
              Text(task.preferredTime,
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.grey[500])),
            ],
          ),
          if (isWorkCompleted) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 1)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          'Le prestataire a terminé le travail. Veuillez vérifier et confirmer.',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500))),
                ],
              ),
            ),
          ],
          if (task.applicantsCount > 0 && type == 'published') ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: ThemeColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.people_outline,
                      color: ThemeColors.primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text('${task.applicantsCount} candidat(s) intéressé(s)',
                      style: TextStyle(
                          fontSize: 14,
                          color: ThemeColors.primaryColor,
                          fontWeight: FontWeight.w500)),
                  Spacer(),
                  TextButton(
                      onPressed: () => _viewCandidates(task),
                      child: Text('Voir',
                          style: TextStyle(color: ThemeColors.primaryColor))),
                ],
              ),
            ),
          ],
          if (task.assignedProvider != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.person, color: Colors.white, size: 16)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.assignedProvider!,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black)),
                        if (task.providerRating != null)
                          Row(
                              children: List.generate(
                                  5,
                                  (index) => Icon(
                                      index < task.providerRating!
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 12,
                                      color: Colors.amber))),
                      ],
                    ),
                  ),
                  if (type == 'active' && !isWorkCompleted)
                    TextButton(
                        onPressed: () => _contactProvider(task),
                        child: Text('Contacter',
                            style: TextStyle(
                                color: ThemeColors.primaryColor,
                                fontSize: 12))),
                ],
              ),
            ),
          ],
          SizedBox(height: 12),
          _buildActionButtons(task, type, isWorkCompleted),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      TaskModel task, String type, bool isWorkCompleted) {
    if (type == 'published') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _editTask(task),
              child: Text('Modifier',
                  style: TextStyle(color: ThemeColors.primaryColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ThemeColors.primaryColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _cancelTask(task),
              child: Text('Annuler'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      );
    } else if (type == 'active' && isWorkCompleted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _confirmCompletion(task),
          icon: Icon(Icons.check_circle, size: 18),
          label: Text('Confirmer et payer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    } else if (type == 'completed') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewTaskDetails(task),
              icon: Icon(Icons.visibility_outlined, size: 16),
              label: Text('Voir détails'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeColors.primaryColor,
                side: BorderSide(color: ThemeColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _rateWorker(task),
              icon: Icon(Icons.star_outline, size: 16),
              label: Text('Évaluer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return SizedBox.shrink(); // ← مهم!
  }

  Widget _buildEmptyState(String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String title, subtitle;
    IconData icon;
    switch (type) {
      case 'published':
        icon = Icons.publish;
        title = 'Aucune tâche publiée';
        subtitle = 'Créez votre première tâche';
        break;
      case 'active':
        icon = Icons.pending_actions;
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
          Icon(icon,
              size: 64, color: isDark ? Colors.white38 : Colors.grey[400]),
          SizedBox(height: 16),
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.grey[600])),
          SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey[500])),
          if (type == 'published') ...[
            SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: () => _createNewTask(),
                icon: Icon(Icons.add),
                label: Text('Créer une tâche'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12)))
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.published:
        return Colors.blue;
      case TaskStatus.active:
        return Colors.orange;
      case TaskStatus.workCompleted:
        return Colors.deepOrange;
      case TaskStatus.completed:
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
        return 'En cours';
      case TaskStatus.workCompleted:
        return 'À confirmer';
      case TaskStatus.completed:
        return 'Terminée';
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

  void _createNewTask() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreateTaskScreen()));
    if (result == true) {
      _loadTasks();
      _tabController.animateTo(0);
    }
  }

  void _viewCandidates(TaskModel task) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TaskCandidatesScreen(task: task)));
    if (result == true) _loadTasks();
  }

  void _contactProvider(TaskModel task) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Fonctionnalité de messagerie bientôt disponible'),
        backgroundColor: ThemeColors.primaryColor));
  }

  void _editTask(TaskModel task) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateTaskScreen(taskToEdit: task)));
    if (result == true) _loadTasks();
  }

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

      if (!mounted) return;

      if (result['ok']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Évaluation envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Erreur'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      loadingOverlay?.remove();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelTask(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Annuler la tâche'),
        content: Text('Êtes-vous sûr de vouloir annuler cette tâche ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Non')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performCancelTask(task);
              },
              child: Text('Oui', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Future<void> _performCancelTask(TaskModel task) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()));
    final result = await taskService.updateTaskStatus(
        taskId: task.id, status: 'cancelled');
    if (mounted) {
      Navigator.pop(context);
      if (result['ok']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Tâche annulée'), backgroundColor: Colors.red));
        _loadTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['error'] ?? 'Erreur'),
            backgroundColor: Colors.red));
      }
    }
  }

  void _confirmCompletion(TaskModel task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: ThemeColors.primaryColor),
            SizedBox(width: 8),
            Text('Choisir le mode de paiement'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Le travail a été terminé par le prestataire. Veuillez confirmer et choisir votre mode de paiement.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),

            // ✅ Option Bankily (maintenant disponible)
            InkWell(
              onTap: () {
                Navigator.pop(dialogContext);
                _initiateMoosylPayment(task, 'bankily');
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet,
                        color: Colors.blue, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paiement Bankily',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Payer via l\'application Bankily',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.blue),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12),

            // ✅ Option Sedad
            InkWell(
              onTap: () {
                Navigator.pop(dialogContext);
                _initiateMoosylPayment(task, 'sedad');
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.orange.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance, color: Colors.orange, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paiement Sedad',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Payer via l\'application Sedad',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.orange),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12),

            // ✅ Option Masrivi
            InkWell(
              onTap: () {
                Navigator.pop(dialogContext);
                _initiateMoosylPayment(task, 'masrivi');
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.purple.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.payment, color: Colors.purple, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paiement Masrivi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Payer via l\'application Masrivi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.purple),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12),

            // Option Cash
            InkWell(
              onTap: () {
                Navigator.pop(dialogContext);
                _confirmCashPayment(task);
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.money, color: Colors.green, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paiement en Cash',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Payer directement au prestataire',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _confirmCashPayment(TaskModel task) {
    final priceController = TextEditingController(text: task.budget.toString());
    final maxReasonableAmount = task.budget * 3;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: Colors.green),
            SizedBox(width: 8),
            Text('Confirmer le paiement'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.money, color: Colors.green, size: 48),
              SizedBox(height: 16),
              Text(
                'Avez-vous payé en espèces au prestataire ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Montant payé (MRU)',
                  hintText: 'Entrez le montant final',
                  prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  helperText:
                      'Maximum autorisé : ${maxReasonableAmount.toStringAsFixed(0)} MRU',
                  helperStyle: TextStyle(
                    fontSize: 11,
                    color: Colors.orange[700],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Budget initial :',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${task.budget} MRU',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Maximum autorisé :',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                        Text(
                          '${maxReasonableAmount.toStringAsFixed(0)} MRU',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              priceController.dispose();
              Navigator.pop(dialogContext);
            },
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final priceText = priceController.text.trim();
              final finalPrice = double.tryParse(priceText);

              if (finalPrice == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Veuillez entrer un nombre valide'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              if (finalPrice <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Le montant doit être supérieur à zéro'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              if (finalPrice > maxReasonableAmount) {
                final confirmHighAmount = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Attention'),
                      ],
                    ),
                    content: Text(
                      'Le montant saisi (${finalPrice.toStringAsFixed(0)} MRU) dépasse le maximum autorisé (${maxReasonableAmount.toStringAsFixed(0)} MRU).\n\nÊtes-vous sûr du montant ?',
                      style: TextStyle(fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Modifier le montant'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: Text(
                          'Confirmer',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmHighAmount != true) {
                  return;
                }
              }

              priceController.dispose();
              Navigator.pop(dialogContext);

              // ⏳ التأخير لحل مشكلة الشاشة الحمراء
              await Future.delayed(Duration(milliseconds: 100));

              await _performConfirmCompletion(task, finalPrice);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Confirmer le paiement',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((_) {
      try {
        priceController.dispose();
      } catch (e) {
        print('Controller already disposed: $e');
      }
    });
  }

  void _showBankilyUnavailable() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text('Service indisponible'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, color: Colors.orange, size: 64),
            SizedBox(height: 16),
            Text(
              'Le paiement via Bankily n\'est pas encore disponible.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 12),
            Text(
              'Veuillez utiliser le paiement en cash pour le moment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primaryColor,
            ),
            child: Text('Compris', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performConfirmCompletion(
      TaskModel task, double finalPrice) async {
    print('════════ DEBUG PAYMENT ════════');
    print('Task ID: ${task.id}');
    print('Final Price: $finalPrice');
    print('Initial Budget: ${task.budget}');
    print('════════════════════════════');

    OverlayEntry? loadingOverlay;

    if (mounted) {
      loadingOverlay = OverlayEntry(
        builder: (context) => Container(
          color: Colors.black54,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(ThemeColors.primaryColor),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Confirmation du paiement...\n${finalPrice.toStringAsFixed(0)} MRU',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      Overlay.of(context).insert(loadingOverlay);
    }

    try {
      if (finalPrice <= 0) {
        throw Exception('Le montant doit être supérieur à zéro');
      }

      final result = await taskService.confirmTaskCompletion(
        taskId: task.id,
        finalPrice: finalPrice,
      );

      loadingOverlay?.remove();

      // ⏳ التأخير بعد إزالة Loading
      await Future.delayed(Duration(milliseconds: 100));

      if (!mounted) return;

      if (result['ok']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tâche confirmée avec succès !',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Montant payé : ${finalPrice.toStringAsFixed(0)} MRU',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
          ),
        );

        await _loadTasks();
        if (mounted) {
          _tabController.animateTo(2);
        }
      } else {
        String errorMessage =
            result['error'] ?? 'Erreur lors de la confirmation';

        if (errorMessage.contains('too high')) {
          errorMessage =
              'Le montant est trop élevé ! Veuillez vérifier et réessayer.';
        } else if (errorMessage.contains('negative')) {
          errorMessage = 'Le montant ne peut pas être négatif !';
        } else if (errorMessage.contains('Payment creation failed')) {
          errorMessage =
              'Échec de la création du paiement. Veuillez réessayer.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      loadingOverlay?.remove();
      await Future.delayed(Duration(milliseconds: 100));
      print('❌ Error in payment confirmation: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Une erreur est survenue !',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Veuillez réessayer ou contacter le support',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () {
                _confirmCashPayment(task);
              },
            ),
          ),
        );
      }
    }
  }

  void _viewTaskDetails(TaskModel task) async {
    print('════════ LOADING TASK DETAILS ════════');
    print('Task ID: ${task.id}');
    print('Current final_price in memory: ${task.finalPrice}');
    print('═════════════════════════════════════');

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
      // ✅ احصل على التفاصيل المحدثة من الـ Backend
      final result = await taskService.getTaskDetails(task.id.toString());

      loadingOverlay?.remove();

      if (!mounted) return;

      if (result['ok']) {
        final updatedTask = result['task'] as TaskModel;

        print('════════ TASK DETAILS LOADED ════════');
        print('Task ID: ${updatedTask.id}');
        print('Final Price from Backend: ${updatedTask.finalPrice}');
        print('Budget: ${updatedTask.budget}');
        print('Status: ${updatedTask.status}');
        print('═════════════════════════════════════');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(
              task: updatedTask, // ← البيانات المحدثة من الـ Backend
              userRole: 'client',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'خطأ في تحميل التفاصيل'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      loadingOverlay?.remove();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rateWorker(TaskModel task) {
    int selectedRating = 5;
    String comment = '';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 8),
              Text('Évaluer le prestataire'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.assignedProvider != null) ...[
                  Text(
                    task.assignedProvider!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                Text(
                  'Votre note:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        size: 40,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 16),
                Text(
                  'Commentaire (optionnel):',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  onChanged: (value) => comment = value,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Partagez votre expérience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: ThemeColors.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _submitReview(task, selectedRating, comment.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryColor,
              ),
              child: Text('Envoyer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _rateService(TaskModel task) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Évaluation du service "${task.title}"'),
        backgroundColor: ThemeColors.primaryColor));
  }

  void _reorderService(TaskModel task) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateTaskScreen(taskToEdit: task)));
  }

  // ════════════════════════════════════════════════════
  // MOOSYL PAYMENT METHODS (NEW)
  // ════════════════════════════════════════════════════

  Future<void> _initiateMoosylPayment(
      TaskModel task, String paymentMethod) async {
    // عرض Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(ThemeColors.primaryColor),
              ),
              SizedBox(height: 16),
              Text(
                'Initialisation du paiement...',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // استدعاء API لإنشاء طلب الدفع
      final result = await paymentService.initiateMoosylPayment(
        taskId: int.parse(task.id),
        paymentMethod: paymentMethod,
        amount: task.budget.toDouble(),
      );

      // إغلاق Loading
      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      if (result['ok']) {
        // final paymentId = result['payment_id'] as int;
        // final transactionId = result['transaction_id'] as String;
        // final publishableKey = result['publishable_key'] as String;
        // final amount = result['amount'] as double;

        final paymentId = (result['payment_id'] ?? 0);
        final transactionId = (result['transaction_id'] ?? '');
        final publishableKey = (result['publishable_key'] ?? '');
        final amount = (result['amount'] ?? 0).toDouble();

        if (paymentId == 0 || transactionId.isEmpty || publishableKey.isEmpty) {
          throw Exception("Missing payment information from server");
        }

        print('✅ Payment initiated successfully');
        print('Payment ID: $paymentId');
        print('Transaction ID: $transactionId');

        // الآن نعرض رسالة للمستخدم
        // (في المستقبل هنا سنعرض Moosyl Widget)
        _showMoosylPaymentInfo(
          task: task,
          paymentId: paymentId,
          transactionId: transactionId,
          publishableKey: publishableKey,
          amount: amount,
          paymentMethod: paymentMethod,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(result['error'] ?? 'Erreur d\'initialisation'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMoosylPaymentInfo({
    required TaskModel task,
    required int paymentId,
    required String transactionId,
    required String publishableKey,
    required double amount,
    required String paymentMethod,
  }) {
    print('════════ DEBUG MOOSYL VIEW ════════');
    print('publishableKey: $publishableKey');
    print('transactionId: $transactionId');
    print('paymentId: $paymentId');
    print('amount: $amount');
    print('══════════════════════════════════');

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Paiement ${_getPaymentMethodName(paymentMethod)}'),
            backgroundColor: ThemeColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: (publishableKey.isEmpty || transactionId.isEmpty)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Chargement...'),
                    ],
                  ),
                )
              : MoosylView(
                  publishableApiKey: publishableKey,
                  transactionId: transactionId,
                  organizationLogo: Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Khidma',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.primaryColor,
                      ),
                    ),
                  ),
                  onPaymentSuccess: () {
                    print('✅ Payment successful!');
                    Navigator.pop(context);
                    _startPaymentVerification(task, paymentId);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method.toLowerCase()) {
      case 'bankily':
        return 'Bankily';
      case 'sedad':
        return 'Sedad';
      case 'masrivi':
        return 'Masrivi';
      default:
        return method;
    }
  }

  Future<void> _startPaymentVerification(TaskModel task, int paymentId) async {
    // عرض Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(ThemeColors.primaryColor),
              ),
              SizedBox(height: 16),
              Text(
                'Vérification du paiement...',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // التحقق من حالة الدفع
      final result = await paymentService.verifyMoosylPayment(
        paymentId: paymentId,
      );

      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      if (result['ok']) {
        final status = result['status'] as String;

        if (status == 'completed') {
          // ✅ الدفع اكتمل
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Paiement complété avec succès !'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // تحديث قائمة المهام
          await _loadTasks();
          if (mounted) {
            _tabController.animateTo(2); // الانتقال إلى Terminées
          }
        } else if (status == 'processing' || status == 'pending') {
          // ⏳ لا يزال قيد المعالجة
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Paiement en cours de traitement...'),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (status == 'failed') {
          // ❌ الدفع فشل
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Le paiement a échoué'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Erreur de vérification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
