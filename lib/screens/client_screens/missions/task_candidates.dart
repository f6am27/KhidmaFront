import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../models/models.dart';
import '../../../services/task_service.dart';
import '../../shared_screens/messages/chat_screen.dart';
import '../../../../services/chat_service.dart';

class TaskCandidatesScreen extends StatefulWidget {
  final TaskModel task;

  const TaskCandidatesScreen({Key? key, required this.task}) : super(key: key);

  @override
  _TaskCandidatesScreenState createState() => _TaskCandidatesScreenState();
}

class _TaskCandidatesScreenState extends State<TaskCandidatesScreen> {
  bool _isLoading = true;
  List<TaskApplicationModel> _candidates = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await taskService.getTaskCandidates(widget.task.id);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['ok']) {
          _candidates = result['candidates'] as List<TaskApplicationModel>;
        } else {
          _errorMessage = result['error'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Candidats intéressés'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTaskSummary(context, isDark),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState(isDark)
                    : _candidates.isEmpty
                        ? _buildEmptyState(context, isDark)
                        : RefreshIndicator(
                            onRefresh: _loadCandidates,
                            child: ListView.separated(
                              padding: EdgeInsets.all(16),
                              itemCount: _candidates.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final candidate = _candidates[index];
                                return _buildCandidateCard(
                                    context, candidate, isDark);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSummary(BuildContext context, bool isDark) {
    return Container(
      margin: EdgeInsets.all(16),
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
                  color: ThemeColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getServiceIcon(widget.task.serviceType),
                  color: ThemeColors.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                ),
              ),
              Text(
                '${widget.task.budget} MRU',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primaryColor,
                    ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              SizedBox(width: 4),
              Text(
                widget.task.location,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.grey[500],
                    ),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.schedule,
                size: 16,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              SizedBox(width: 4),
              Text(
                widget.task.preferredTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.grey[500],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(
      BuildContext context, TaskApplicationModel candidate, bool isDark) {
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        isDark ? ThemeColors.darkSurface : Colors.grey[200],
                    backgroundImage: candidate.profileImage != null
                        ? NetworkImage(candidate.profileImage!)
                        : null,
                    child: candidate.profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 28,
                            color: isDark ? Colors.white54 : Colors.grey[600],
                          )
                        : null,
                  ),
                  if (candidate.isOnline)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? ThemeColors.darkBackground
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < candidate.rating.floor()
                                  ? Icons.star
                                  : (index < candidate.rating
                                      ? Icons.star_half
                                      : Icons.star_border),
                              size: 14,
                              color: Colors.amber,
                            );
                          }),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '${candidate.rating} (${candidate.reviewCount})',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    isDark ? Colors.white54 : Colors.grey[600],
                              ),
                        ),
                        Spacer(),
                        if (candidate.isOnline)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'En ligne',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.work_history,
                size: 16,
                color: ThemeColors.primaryColor,
              ),
              SizedBox(width: 6),
              Text(
                '${candidate.completedJobs} missions terminées',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  candidate.location,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.grey[500],
                      ),
                ),
              ),
            ],
          ),
          if (candidate.applicationMessage.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 16,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Message du candidat:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    candidate.applicationMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _contactCandidate(context, candidate),
                  icon: Icon(
                    Icons.chat,
                    size: 16,
                    color: ThemeColors.primaryColor,
                  ),
                  label: Text(
                    'Discuter',
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
                child: ElevatedButton.icon(
                  onPressed: () => _acceptCandidate(context, candidate),
                  icon: Icon(Icons.check, size: 16),
                  label: Text('Accepter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            valueColor: AlwaysStoppedAnimation(ThemeColors.primaryColor),
          ),
          SizedBox(height: 16),
          Text('Chargement des candidats...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Une erreur est survenue',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCandidates,
              icon: Icon(Icons.refresh),
              label: Text('Réessayer'),
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

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucun candidat pour le moment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Les prestataires intéressés apparaîtront ici',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
          ),
        ],
      ),
    );
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

  Future<void> _contactCandidate(
      BuildContext context, TaskApplicationModel candidate) async {
    int candidateId;

    try {
      candidateId = int.parse(candidate.id);
    } catch (e) {
      print('❌ Error parsing candidate.id: ${candidate.id}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Erreur: ID du candidat invalide'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(ThemeColors.primaryColor),
        ),
      ),
    );

    try {
      final result = await chatService.startConversation(candidateId);

      // ✅ إغلاق Loading
      if (mounted) Navigator.pop(context);

      // ⏳ تأخير صغير لضمان اكتمال إغلاق Dialog
      await Future.delayed(Duration(milliseconds: 100));

      if (result['ok']) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                conversationId: result['conversation_id'],
                contactName: candidate.name,
                contactId: candidateId,
                isOnline: candidate.isOnline,
                profileImageUrl: candidate.profileImage,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Erreur: ${result['error'] ?? 'Impossible de démarrer la conversation'}',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error starting conversation: $e');
      if (mounted) Navigator.pop(context);

      // ⏳ تأخير قبل إظهار الخطأ
      await Future.delayed(Duration(milliseconds: 100));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Erreur de connexion. Veuillez réessayer.'),
                ),
              ],
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _acceptCandidate(
      BuildContext context, TaskApplicationModel candidate) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.85),
        title: Text('Accepter le candidat'),
        content:
            Text('Voulez-vous accepter ${candidate.name} pour cette mission ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Accepter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _performAcceptWorker(candidate);
    }
  }

  Future<void> _performAcceptWorker(TaskApplicationModel candidate) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final result = await taskService.acceptWorker(
      taskId: widget.task.id,
      workerId: candidate.id,
    );

    if (mounted) {
      Navigator.pop(context);

      // ⏳ تأخير صغير
      await Future.delayed(Duration(milliseconds: 100));

      if (result['ok']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${candidate.name} accepté pour cette mission'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Erreur lors de l\'acceptation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
