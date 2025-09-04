import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'tasks_screen.dart'; // استيراد TaskModel من tasks_screen

class TaskCandidatesScreen extends StatelessWidget {
  final TaskModel task;

  const TaskCandidatesScreen({Key? key, required this.task}) : super(key: key);

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
          // Task summary
          _buildTaskSummary(context, isDark),

          // Candidates list
          Expanded(
            child: _sampleCandidates.isEmpty
                ? _buildEmptyState(context, isDark)
                : ListView.separated(
                    padding: EdgeInsets.all(16),
                    itemCount: _sampleCandidates.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final candidate = _sampleCandidates[index];
                      return _buildCandidateCard(context, candidate, isDark);
                    },
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
                  _getServiceIcon(task.serviceType),
                  color: ThemeColors.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                ),
              ),
              Text(
                '${task.budget} MRU',
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
                task.location,
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
                task.preferredTime,
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
      BuildContext context, CandidateModel candidate, bool isDark) {
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
              // Profile picture
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

              // Provider info
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

          // Experience and location
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
          SizedBox(height: 12),

          // Application message
          if (candidate.applicationMessage.isNotEmpty) ...[
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
            SizedBox(height: 12),
          ],

          // Proposed price and timing
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ThemeColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 14,
                      color: ThemeColors.primaryColor,
                    ),
                    Text(
                      '${candidate.proposedPrice} MRU',
                      style: TextStyle(
                        color: ThemeColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 4),
                    Text(
                      candidate.availableTime,
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Action buttons
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
                    'Contacter',
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

  // Helper method to get service icon (same as in TasksScreen)
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

  void _contactCandidate(BuildContext context, CandidateModel candidate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture du chat avec ${candidate.name}'),
        backgroundColor: ThemeColors.primaryColor,
      ),
    );
  }

  void _acceptCandidate(BuildContext context, CandidateModel candidate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accepter le candidat'),
        content: Text(
            'Voulez-vous accepter ${candidate.name} pour cette mission au prix de ${candidate.proposedPrice} MRU ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to tasks screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${candidate.name} accepté pour cette mission'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Accepter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Sample data
  static final List<CandidateModel> _sampleCandidates = [
    CandidateModel(
      id: '1',
      name: 'Fatima Al-Zahra',
      rating: 4.9,
      reviewCount: 124,
      location: 'Tevragh Zeina, 2km',
      completedJobs: 87,
      proposedPrice: 4500,
      availableTime: 'Demain matin',
      applicationMessage:
          'Bonjour, j\'ai 5 ans d\'expérience dans le nettoyage résidentiel. Je fournis mes propres produits écologiques. Disponible dès demain matin.',
      isOnline: true,
      profileImage: null,
    ),
    CandidateModel(
      id: '2',
      name: 'Aicha Mint Salem',
      rating: 4.7,
      reviewCount: 56,
      location: 'Ksar, 3km',
      completedJobs: 34,
      proposedPrice: 4800,
      availableTime: 'Cet après-midi',
      applicationMessage:
          'Je suis spécialisée dans le nettoyage d\'appartements. Travail soigné et rapide garanti.',
      isOnline: false,
      profileImage: null,
    ),
    CandidateModel(
      id: '3',
      name: 'Khadija Ba',
      rating: 4.8,
      reviewCount: 89,
      location: 'Tevragh Zeina, 1km',
      completedJobs: 67,
      proposedPrice: 5200,
      availableTime: 'Demain soir',
      applicationMessage:
          'Service professionnel avec équipement moderne. Références disponibles sur demande.',
      isOnline: true,
      profileImage: null,
    ),
  ];
}

// Candidate model (renamed from ApplicantModel)
class CandidateModel {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final String location;
  final int completedJobs;
  final int proposedPrice;
  final String availableTime;
  final String applicationMessage;
  final bool isOnline;
  final String? profileImage;

  CandidateModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.completedJobs,
    required this.proposedPrice,
    required this.availableTime,
    required this.applicationMessage,
    required this.isOnline,
    this.profileImage,
  });
}
