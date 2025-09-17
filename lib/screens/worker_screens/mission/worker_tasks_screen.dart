import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class WorkerTasksScreen extends StatefulWidget {
  @override
  _WorkerTasksScreenState createState() => _WorkerTasksScreenState();
}

class _WorkerTasksScreenState extends State<WorkerTasksScreen>
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Mes Tâches',
          style: TextStyle(
            color: AppColors.textPrimary,
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
          unselectedLabelColor: AppColors.textSecondary,
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
      body: TabBarView(
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

  Widget _buildTasksList(List<WorkerTaskModel> tasks, String type) {
    if (tasks.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => SizedBox(height: 16),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, type);
      },
    );
  }

  Widget _buildTaskCard(WorkerTaskModel task, String type) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
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
                        color: AppColors.textPrimary,
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
              color: AppColors.textSecondary,
              height: 1.4,
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
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.location,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Icon(
                Icons.schedule,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 4),
              Text(
                task.preferredTime,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 4),
              Text(
                _formatDate(task.acceptedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
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

  Widget _buildActionButtons(WorkerTaskModel task, String type) {
    switch (type) {
      case 'accepted':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _cancelTask(task),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
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
                ),
              ),
            ),
          ],
        );

      case 'inprogress':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _contactClient(task),
                icon: Icon(Icons.chat_bubble_outline, size: 16),
                label: Text('Contacter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryPurple,
                  side: BorderSide(color: AppColors.primaryPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _completeTask(task),
                icon: Icon(Icons.check, size: 16),
                label: Text('Terminée'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                color: AppColors.textSecondary,
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
          Icon(
            icon,
            size: 64,
            color: AppColors.mediumGray,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(WorkerTaskStatus status) {
    switch (status) {
      case WorkerTaskStatus.accepted:
        return AppColors.cyan;
      case WorkerTaskStatus.inProgress:
        return AppColors.orange;
      case WorkerTaskStatus.completed:
        return AppColors.green;
      case WorkerTaskStatus.cancelled:
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

  String _getStatusText(WorkerTaskStatus status) {
    switch (status) {
      case WorkerTaskStatus.accepted:
        return 'Acceptée';
      case WorkerTaskStatus.inProgress:
        return 'En cours';
      case WorkerTaskStatus.completed:
        return 'Terminée';
      case WorkerTaskStatus.cancelled:
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
  void _startTask(WorkerTaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Commencer la tâche'),
        content: Text('Êtes-vous prêt à commencer cette tâche ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Pas encore'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _acceptedTasks.remove(task);
                task.status = WorkerTaskStatus.inProgress;
                task.startedAt = DateTime.now();
                _inProgressTasks.insert(0, task);
              });
              _tabController.animateTo(1); // Aller au tab "En cours"
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tâche commencée avec succès'),
                  backgroundColor: AppColors.green,
                ),
              );
            },
            child: Text(
              'Commencer',
              style: TextStyle(color: AppColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelTask(WorkerTaskModel task) {
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
                _acceptedTasks.remove(task);
                task.status = WorkerTaskStatus.cancelled;
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

  void _completeTask(WorkerTaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Marquer comme terminée'),
        content: Text('Avez-vous terminé cette tâche ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Pas encore'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _inProgressTasks.remove(task);
                task.status = WorkerTaskStatus.completed;
                task.completedAt = DateTime.now();
                _completedTasks.insert(0, task);
              });
              _tabController.animateTo(2); // Aller au tab "Terminées"
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tâche marquée comme terminée'),
                  backgroundColor: AppColors.green,
                ),
              );
            },
            child: Text(
              'Terminée',
              style: TextStyle(color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _contactClient(WorkerTaskModel task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture du chat avec le client'),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }

  void _viewTaskDetails(WorkerTaskModel task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Affichage des détails de "${task.title}"'),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }

  // Sample data
  final List<WorkerTaskModel> _acceptedTasks = [
    WorkerTaskModel(
      id: '1',
      title: 'Nettoyage appartement 3 pièces',
      description:
          'Nettoyage complet d\'un appartement de 3 pièces avec cuisine et salle de bain.',
      serviceType: 'Nettoyage',
      budget: 8500,
      location: 'Tevragh-Zeina, Nouakchott',
      preferredTime: '9:00 AM',
      status: WorkerTaskStatus.accepted,
      acceptedAt: DateTime.now().subtract(Duration(hours: 3)),
      isUrgent: false,
    ),
    WorkerTaskModel(
      id: '2',
      title: 'Réparation robinet cuisine',
      description: 'Réparation d\'un robinet qui fuit dans la cuisine.',
      serviceType: 'Plomberie',
      budget: 2000,
      location: 'Ksar, Nouakchott',
      preferredTime: 'Après-midi (14h-18h)',
      status: WorkerTaskStatus.accepted,
      acceptedAt: DateTime.now().subtract(Duration(days: 1)),
      isUrgent: true,
    ),
  ];

  final List<WorkerTaskModel> _inProgressTasks = [
    WorkerTaskModel(
      id: '3',
      title: 'Jardinage et taille',
      description: 'Tonte de pelouse et taille des arbustes dans le jardin.',
      serviceType: 'Jardinage',
      budget: 6000,
      location: 'Sebkha, Nouakchott',
      preferredTime: '8:00 AM',
      status: WorkerTaskStatus.inProgress,
      acceptedAt: DateTime.now().subtract(Duration(days: 2)),
      startedAt: DateTime.now().subtract(Duration(hours: 2)),
      isUrgent: false,
    ),
  ];

  final List<WorkerTaskModel> _completedTasks = [
    WorkerTaskModel(
      id: '4',
      title: 'Peinture salon',
      description: 'Peinture du salon avec couleur beige.',
      serviceType: 'Peinture',
      budget: 12000,
      location: 'Arafat, Nouakchott',
      preferredTime: 'Toute la journée',
      status: WorkerTaskStatus.completed,
      acceptedAt: DateTime.now().subtract(Duration(days: 5)),
      startedAt: DateTime.now().subtract(Duration(days: 4)),
      completedAt: DateTime.now().subtract(Duration(days: 2)),
      isUrgent: false,
    ),
    WorkerTaskModel(
      id: '5',
      title: 'Garde d\'enfants',
      description: 'Garde d\'enfants pour la soirée.',
      serviceType: 'Garde d\'enfants',
      budget: 7200,
      location: 'Dar Naim, Nouakchott',
      preferredTime: '18:00 - 23:00',
      status: WorkerTaskStatus.completed,
      acceptedAt: DateTime.now().subtract(Duration(days: 7)),
      startedAt: DateTime.now().subtract(Duration(days: 6)),
      completedAt: DateTime.now().subtract(Duration(days: 6)),
      isUrgent: false,
    ),
  ];

  final List<WorkerTaskModel> _cancelledTasks = [
    WorkerTaskModel(
      id: '6',
      title: 'Installation électrique',
      description: 'Installation de prises électriques supplémentaires.',
      serviceType: 'Électricité',
      budget: 5000,
      location: 'Tojounin, Nouakchott',
      preferredTime: 'À convenir',
      status: WorkerTaskStatus.cancelled,
      acceptedAt: DateTime.now().subtract(Duration(days: 10)),
      isUrgent: false,
    ),
  ];
}

// Models
enum WorkerTaskStatus { accepted, inProgress, completed, cancelled }

class WorkerTaskModel {
  final String id;
  final String title;
  final String description;
  final String serviceType;
  final int budget;
  final String location;
  final String preferredTime;
  WorkerTaskStatus status;
  final DateTime acceptedAt;
  DateTime? startedAt;
  DateTime? completedAt;
  final bool isUrgent;

  WorkerTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.serviceType,
    required this.budget,
    required this.location,
    required this.preferredTime,
    required this.status,
    required this.acceptedAt,
    this.startedAt,
    this.completedAt,
    required this.isUrgent,
  });
}
