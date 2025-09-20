import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'task_candidates.dart'; // استيراد صفحة المتقدمين
import 'create_task.dart'; // استيراد صفحة إنشاء المهمة
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Tâches'),
        centerTitle: true,
        automaticallyImplyLeading: false, // إزالة زر الرجوع لأنها صفحة رئيسية
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ThemeColors.primaryColor,
          labelColor: ThemeColors.primaryColor,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.grey[600],
          isScrollable: true,
          tabs: [
            Tab(text: 'Publiées'),
            Tab(text: 'En cours'),
            Tab(text: 'Terminées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTasksList(_publishedTasks, isDark, 'published'),
          _buildTasksList(_activeTasks, isDark, 'active'),
          _buildTasksList(_completedTasks, isDark, 'completed'),
          _buildTasksList(_cancelledTasks, isDark, 'cancelled'),
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

  Widget _buildTasksList(List<TaskModel> tasks, bool isDark, String type) {
    if (tasks.isEmpty) {
      return _buildEmptyState(isDark, type);
    }

    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => SizedBox(height: 16),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, isDark, type);
      },
    );
  }

  Widget _buildTaskCard(TaskModel task, bool isDark, String type) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                  color: _getStatusColor(task.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getServiceIcon(task.serviceType),
                  color: _getStatusColor(task.status),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(task.status),
                        style: TextStyle(
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.primaryColor,
                        ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatDate(task.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            task.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.location,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.grey[500],
                      ),
                ),
              ),
              Icon(
                Icons.schedule,
                size: 16,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              SizedBox(width: 4),
              Text(
                task.preferredTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.grey[500],
                    ),
              ),
            ],
          ),
          if (task.applicantsCount > 0 && type == 'published') ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
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
                  SizedBox(width: 8),
                  Text(
                    '${task.applicantsCount} candidat(s) intéressé(s)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ThemeColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Spacer(),
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
          if (task.assignedProvider != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.assignedProvider!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < (task.providerRating ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 12,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  if (type == 'active')
                    TextButton(
                      onPressed: () => _contactProvider(task),
                      child: Text(
                        'Contacter',
                        style: TextStyle(
                          color: ThemeColors.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12),
          Row(
            children: [
              if (type == 'published') ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editTask(task),
                    child: Text(
                      'Modifier',
                      style: TextStyle(color: ThemeColors.primaryColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ThemeColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ] else if (type == 'completed') ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rateService(task),
                    child: Text(
                      'Évaluer',
                      style: TextStyle(color: ThemeColors.primaryColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ThemeColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _reorderService(task),
                    child: Text('Recommander'),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String type) {
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
          Icon(
            icon,
            size: 64,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
          ),
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
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
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
      case TaskStatus.completed:
        return 'Terminée';
      case TaskStatus.cancelled:
        return 'Annulée';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Action methods
  void _createNewTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final taskData = result['taskData'];
      final isEditing = result['isEditing'] ?? false;

      if (!isEditing) {
        // إضافة مهمة جديدة
        final newTask = TaskModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: taskData['title'],
          description: taskData['description'],
          serviceType: taskData['serviceType'],
          budget: taskData['budget'],
          location: taskData['location'],
          preferredTime: taskData['preferredTime'],
          status: TaskStatus.published,
          createdAt: DateTime.now(),
          applicantsCount: 0,
        );

        setState(() {
          _publishedTasks.insert(0, newTask);
        });

        // التنقل إلى تبويب المنشورة
        _tabController.animateTo(0);
      }
    }
  }

  void _viewCandidates(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskCandidatesScreen(task: task),
      ),
    );
  }

  void _contactProvider(TaskModel task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture du chat avec ${task.assignedProvider}'),
        backgroundColor: ThemeColors.primaryColor,
      ),
    );
  }

  void _editTask(TaskModel task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(taskToEdit: task),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final taskData = result['taskData'];
      final isEditing = result['isEditing'] ?? false;

      if (isEditing) {
        // تحديث المهمة الموجودة
        setState(() {
          final index = _publishedTasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            _publishedTasks[index] = TaskModel(
              id: task.id,
              title: taskData['title'],
              description: taskData['description'],
              serviceType: taskData['serviceType'],
              budget: taskData['budget'],
              location: taskData['location'],
              preferredTime: taskData['preferredTime'],
              status: task.status,
              createdAt: task.createdAt,
              applicantsCount: task.applicantsCount,
              assignedProvider: task.assignedProvider,
              providerRating: task.providerRating,
            );
          }
        });
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
            onPressed: () => Navigator.pop(context),
            child: Text('Non'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _publishedTasks.remove(task);
                task.status = TaskStatus.cancelled;
                _cancelledTasks.add(task);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tâche annulée'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Oui', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _rateService(TaskModel task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Évaluation du service "${task.title}"'),
        backgroundColor: ThemeColors.primaryColor,
      ),
    );
  }

  void _reorderService(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(taskToEdit: task),
      ),
    );
  }

  // Sample data
  final List<TaskModel> _publishedTasks = [
    TaskModel(
      id: '1',
      title: 'Nettoyage appartement 3 pièces',
      description:
          'Nettoyage complet d\'un appartement de 3 pièces avec cuisine et salle de bain. Produits fournis.',
      serviceType: 'Nettoyage',
      budget: 5000,
      location: 'Tevragh Zeina, Nouakchott',
      preferredTime: '9:00 AM',
      status: TaskStatus.published,
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
      applicantsCount: 3,
    ),
    TaskModel(
      id: '2',
      title: 'Réparation robinet cuisine',
      description: 'Réparation d\'un robinet qui fuit dans la cuisine. Urgent.',
      serviceType: 'Plomberie',
      budget: 2000,
      location: 'Ksar, Nouakchott',
      preferredTime: 'Après-midi (14h-18h)',
      status: TaskStatus.published,
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      applicantsCount: 1,
    ),
  ];

  final List<TaskModel> _activeTasks = [
    TaskModel(
      id: '3',
      title: 'Peinture salon',
      description: 'Peinture du salon avec couleur beige.',
      serviceType: 'Peinture',
      budget: 8000,
      location: 'Sebkha, Nouakchott',
      preferredTime: 'Toute la journée',
      status: TaskStatus.active,
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      assignedProvider: 'Hassan Ould Baba',
      providerRating: 4,
      applicantsCount: 0,
    ),
  ];

  final List<TaskModel> _completedTasks = [
    TaskModel(
      id: '4',
      title: 'Jardinage et tonte',
      description: 'Tonte de pelouse et taille des arbustes.',
      serviceType: 'Jardinage',
      budget: 3000,
      location: 'Arafat, Nouakchott',
      preferredTime: '8:00 AM',
      status: TaskStatus.completed,
      createdAt: DateTime.now().subtract(Duration(days: 7)),
      assignedProvider: 'Omar Ba',
      providerRating: 5,
      applicantsCount: 0,
    ),
  ];

  final List<TaskModel> _cancelledTasks = [
    TaskModel(
      id: '5',
      title: 'Déménagement studio',
      description: 'Déménagement d\'un studio vers nouvel appartement.',
      serviceType: 'Déménagement',
      budget: 15000,
      location: 'Dar Naim, Nouakchott',
      preferredTime: 'À convenir',
      status: TaskStatus.cancelled,
      createdAt: DateTime.now().subtract(Duration(days: 10)),
      applicantsCount: 0,
    ),
  ];
}

// Models
enum TaskStatus { published, active, completed, cancelled }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String serviceType;
  final int budget;
  final String location;
  final String preferredTime;
  TaskStatus status;
  final DateTime createdAt;
  final String? assignedProvider;
  final int? providerRating;
  final int applicantsCount;
  final bool isUrgent; // ← إضافة هذا السطر
  final LatLng? coordinates;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.serviceType,
    required this.budget,
    required this.location,
    required this.preferredTime,
    required this.status,
    required this.createdAt,
    this.assignedProvider,
    this.providerRating,
    required this.applicantsCount,
    this.isUrgent = false, // ← القيمة الافتراضية
    this.coordinates,
  });
}
