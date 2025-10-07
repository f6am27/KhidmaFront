import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../models/models.dart';
import '../../../services/task_service.dart';
import 'task_candidates.dart';
import 'create_task.dart';

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

    // ════════ ADD THIS DEBUG CODE ════════
    print('════════ LOAD TASKS DEBUG ════════');
    print('Result OK: ${result['ok']}');
    print('Result keys: ${result.keys.toList()}');

    if (result['tasks'] != null) {
      print('Tasks type: ${result['tasks'].runtimeType}');
      print('Tasks length: ${(result['tasks'] as List).length}');

      if ((result['tasks'] as List).isNotEmpty) {
        print('First task type: ${(result['tasks'] as List)[0].runtimeType}');
        print('First task: ${(result['tasks'] as List)[0]}');
      }
    }

    if (result['json'] != null) {
      print('Raw JSON type: ${result['json'].runtimeType}');
      print('Raw JSON: ${result['json']}');
    }
    print('═══════════════════════════════════');
    // ════════════════════════════════════

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
                          borderRadius: BorderRadius.circular(8))))),
          SizedBox(width: 12),
          Expanded(
              child: ElevatedButton(
                  onPressed: () => _cancelTask(task),
                  child: Text('Annuler'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))))),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)))),
      );
    } else if (type == 'completed') {
      return Row(
        children: [
          Expanded(
              child: OutlinedButton(
                  onPressed: () => _rateService(task),
                  child: Text('Évaluer',
                      style: TextStyle(color: ThemeColors.primaryColor)),
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ThemeColors.primaryColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))))),
          SizedBox(width: 12),
          Expanded(
              child: ElevatedButton(
                  onPressed: () => _reorderService(task),
                  child: Text('Recommander'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))))),
        ],
      );
    }
    return SizedBox.shrink();
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

  void _confirmCompletion(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la completion'),
        content: Text(
            'Le travail a-t-il été effectué correctement ? Le paiement sera traité après confirmation.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Pas encore')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Confirmer', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm == true) _performConfirmCompletion(task);
  }

  Future<void> _performConfirmCompletion(TaskModel task) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()));
    final result = await taskService.confirmTaskCompletion(taskId: task.id);
    if (mounted) {
      Navigator.pop(context);
      if (result['ok']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Tâche confirmée terminée. Le paiement sera traité.'),
            backgroundColor: Colors.green));
        _loadTasks();
        _tabController.animateTo(2);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['error'] ?? 'Erreur'),
            backgroundColor: Colors.red));
      }
    }
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
}
