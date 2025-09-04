import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme_colors.dart';
import 'tasks_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  final TaskModel? taskToEdit; // للتعديل على مهمة موجودة

  const CreateTaskScreen({Key? key, this.taskToEdit}) : super(key: key);

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  String _selectedServiceType = 'Nettoyage';
  String _selectedLocation = 'Tevragh Zeina';
  String _selectedTime = '9:00 AM';
  bool _isLoading = false;

  // Service types with their icons
  final Map<String, IconData> _serviceTypes = {
    'Nettoyage': Icons.cleaning_services,
    'Plomberie': Icons.plumbing,
    'Électricité': Icons.electrical_services,
    'Jardinage': Icons.grass,
    'Peinture': Icons.format_paint,
    'Déménagement': Icons.local_shipping,
    'Réparation': Icons.build,
    'Cuisine': Icons.restaurant,
    'Autre': Icons.work_outline,
  };

  // Nouakchott areas/districts
  final List<String> _nouakchottAreas = [
    'Tevragh Zeina',
    'Ksar',
    'Sebkha',
    'Arafat',
    'Dar Naim',
    'El Mina',
    'Toujounine',
    'Riyadh',
    'Hay Saken',
    'Socogim',
    'Basra',
    'Dubai',
    'Melah',
    'Sixième',
    'Cinquième',
  ];

  // Time slots for Mauritania (12-hour format)
  final List<String> _timeSlots = [
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
    '7:00 PM',
    'Matin (8h-12h)',
    'Après-midi (14h-18h)',
    'Soir (18h-21h)',
    'Toute la journée',
    'À convenir',
  ];

  @override
  void initState() {
    super.initState();
    // إذا كنا نعدل مهمة موجودة، نملأ الحقول
    if (widget.taskToEdit != null) {
      _fillFormWithTaskData();
    }
  }

  void _fillFormWithTaskData() {
    final task = widget.taskToEdit!;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _budgetController.text = task.budget.toString();
    _selectedLocation = task.location.split(', ').first;
    _selectedServiceType = task.serviceType;
    _selectedTime = task.preferredTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la tâche' : 'Créer une tâche'),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              onPressed: () => _showDeleteConfirmation(),
              icon: Icon(Icons.delete, color: Colors.red),
              tooltip: 'Supprimer la tâche',
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    // Service Type Selection
                    _buildServiceTypeSelector(isDark),
                    SizedBox(height: 20),

                    // Title Field
                    _buildTitleField(isDark),
                    SizedBox(height: 16),

                    // Description Field
                    _buildDescriptionField(isDark),
                    SizedBox(height: 16),

                    // Budget Field
                    _buildBudgetField(isDark),
                    SizedBox(height: 16),

                    // Location Selector
                    _buildLocationSelector(isDark),
                    SizedBox(height: 16),

                    // Time Selector
                    _buildTimeSelector(isDark),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              // Action Buttons - Fixed at bottom
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? ThemeColors.darkBackground : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black26
                          : Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: _buildActionButtons(isEditing),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTypeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de service *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkCardBackground : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedServiceType,
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _serviceTypes[_selectedServiceType] ?? Icons.work_outline,
                    color: ThemeColors.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: isDark ? Colors.white : Colors.black54,
                  ),
                ],
              ),
              isExpanded: true,
              dropdownColor:
                  isDark ? ThemeColors.darkCardBackground : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedServiceType = newValue!;
                });
              },
              items:
                  _serviceTypes.entries.map<DropdownMenuItem<String>>((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(
                        entry.value,
                        color: ThemeColors.primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Titre de la tâche *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Ex: Nettoyage appartement 3 pièces',
            prefixIcon: Icon(Icons.title),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor:
                isDark ? ThemeColors.darkCardBackground : Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez saisir un titre';
            }
            if (value.trim().length < 5) {
              return 'Le titre doit contenir au moins 5 caractères';
            }
            return null;
          },
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description détaillée *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Décrivez en détail ce que vous souhaitez...',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.description),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor:
                isDark ? ThemeColors.darkCardBackground : Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez saisir une description';
            }
            if (value.trim().length < 20) {
              return 'La description doit contenir au moins 20 caractères';
            }
            return null;
          },
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildBudgetField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget proposé *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '0',
            prefixIcon: Icon(Icons.attach_money),
            suffixText: 'MRU',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor:
                isDark ? ThemeColors.darkCardBackground : Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez saisir un budget';
            }
            final budget = int.tryParse(value);
            if (budget == null || budget <= 0) {
              return 'Veuillez saisir un budget valide';
            }
            if (budget < 500) {
              return 'Le budget minimum est de 500 MRU';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zone à Nouakchott *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkCardBackground : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLocation,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: isDark ? Colors.white : Colors.black54,
              ),
              isExpanded: true,
              dropdownColor:
                  isDark ? ThemeColors.darkCardBackground : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLocation = newValue!;
                });
              },
              items:
                  _nouakchottAreas.map<DropdownMenuItem<String>>((String area) {
                return DropdownMenuItem<String>(
                  value: area,
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: ThemeColors.primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        area,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horaire préféré *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkCardBackground : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTime,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: isDark ? Colors.white : Colors.black54,
              ),
              isExpanded: true,
              dropdownColor:
                  isDark ? ThemeColors.darkCardBackground : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTime = newValue!;
                });
              },
              items: _timeSlots.map<DropdownMenuItem<String>>((String time) {
                return DropdownMenuItem<String>(
                  value: time,
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: ThemeColors.primaryColor,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isEditing) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _submitForm,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(isEditing ? Icons.save : Icons.add),
            label: Text(
              _isLoading
                  ? 'Traitement...'
                  : (isEditing ? 'Sauvegarder' : 'Créer la tâche'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: Icon(Icons.cancel),
            label: Text('Annuler'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulation d'une requête API
    await Future.delayed(Duration(seconds: 2));

    final isEditing = widget.taskToEdit != null;

    // تجميع الموقع الكامل
    final fullLocation = '$_selectedLocation, Nouakchott';

    // Créer ou mettre à jour la tâche
    final taskData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'serviceType': _selectedServiceType,
      'budget': int.parse(_budgetController.text),
      'location': fullLocation,
      'preferredTime': _selectedTime,
    };

    setState(() {
      _isLoading = false;
    });

    // Afficher message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Tâche modifiée avec succès!'
              : 'Tâche créée avec succès!',
        ),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Voir',
          textColor: Colors.white,
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
    );

    // إعادة البيانات للصفحة السابقة
    Navigator.pop(context, {
      'taskData': taskData,
      'isEditing': isEditing,
      'taskId': widget.taskToEdit?.id,
    });
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la tâche'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette tâche? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              Navigator.pop(context); // Retourner à la liste
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tâche supprimée'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
