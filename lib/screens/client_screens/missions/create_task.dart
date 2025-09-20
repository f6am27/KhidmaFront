import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/theme_colors.dart';
import '../onboarding/client_location_permission_screen.dart';
import 'location_picker_screen.dart';
import 'tasks_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  final TaskModel? taskToEdit;

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
  int _selectedHour = 9;
  int _selectedMinute = 0;
  bool _isAM = true;
  String _selectedTimeDescription = 'Ce matin';
  bool _isLoading = false;
  bool _isUsingCurrentLocation = false;
  String? _currentLocationAddress;
  LatLng? _selectedCoordinates;
  bool _isUrgent = false;

  // Service types with their icons and colors
  final Map<String, Map<String, dynamic>> _serviceTypes = {
    'Nettoyage': {'icon': Icons.cleaning_services, 'color': Colors.blue},
    'Plomberie': {'icon': Icons.plumbing, 'color': Colors.indigo},
    'Électricité': {'icon': Icons.electrical_services, 'color': Colors.amber},
    'Jardinage': {'icon': Icons.grass, 'color': Colors.green},
    'Peinture': {'icon': Icons.format_paint, 'color': Colors.purple},
    'Déménagement': {'icon': Icons.local_shipping, 'color': Colors.orange},
    'Réparation': {'icon': Icons.build, 'color': Colors.red},
    'Cuisine': {'icon': Icons.restaurant, 'color': Colors.brown},
    'Autre': {'icon': Icons.work_outline, 'color': Colors.grey},
  };

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

  final List<String> _timeDescriptions = [
    'Ce matin',
    'Cet après-midi',
    'Ce soir',
    'Demain matin',
    'Demain après-midi',
    'Demain soir',
    'Cette semaine',
    'Le week-end',
    'Quand vous voulez',
  ];

  @override
  void initState() {
    super.initState();
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

    try {
      _isUrgent = (task as dynamic).isUrgent ?? false;
    } catch (e) {
      _isUrgent = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      backgroundColor: isDark ? ThemeColors.darkBackground : Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? ThemeColors.darkCardBackground : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Modifier la tâche' : 'Créer une nouvelle tâche',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete, color: Colors.red, size: 18),
              ),
              onPressed: () => _showDeleteConfirmation(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Type Chips
                    _buildServiceTypeChips(isDark),
                    SizedBox(height: 24),

                    // Title Card
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Titre de la tâche',
                      child: _buildTitleField(isDark),
                    ),
                    SizedBox(height: 20),

                    // Description Card
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Description',
                      child: _buildDescriptionField(isDark),
                    ),
                    SizedBox(height: 20),

                    // Budget Card
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Budget',
                      child: _buildBudgetField(isDark),
                    ),
                    SizedBox(height: 20),

                    // Priority Switch - Now in its own card
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Priorité',
                      child: _buildUrgentSwitch(isDark),
                    ),
                    SizedBox(height: 20),

                    // Location Card
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Localisation',
                      child: _buildLocationSelector(isDark),
                    ),
                    SizedBox(height: 20),

                    // Time Picker Card
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Horaire',
                      child: _buildTimePicker(isDark),
                    ),
                    SizedBox(height: 20),

                    // Time Description Card
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Quand',
                      child: _buildTimeDescription(isDark),
                    ),
                    SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(isEditing, isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildModernCard({
    required bool isDark,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
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
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildServiceTypeChips(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _serviceTypes.length,
            itemBuilder: (context, index) {
              final entry = _serviceTypes.entries.elementAt(index);
              final isSelected = _selectedServiceType == entry.key;
              final serviceColor = entry.value['color'] as Color;

              return Container(
                margin: EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedServiceType = entry.key),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 80,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? serviceColor.withOpacity(0.15)
                          : (isDark
                              ? ThemeColors.darkCardBackground
                              : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? serviceColor
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          entry.value['icon'] as IconData,
                          color: isSelected ? serviceColor : Colors.grey[600],
                          size: 24,
                        ),
                        SizedBox(height: 6),
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: isSelected
                                ? serviceColor
                                : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField(bool isDark) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        hintText: 'Ex: Nettoyage appartement 3 pièces',
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ThemeColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: isDark ? ThemeColors.darkSurface : Colors.grey[50],
        contentPadding: EdgeInsets.all(16),
      ),
      style: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white : Colors.black87,
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
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Décrivez en détail ce que vous souhaitez...',
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ThemeColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: isDark ? ThemeColors.darkSurface : Colors.grey[50],
        contentPadding: EdgeInsets.all(16),
      ),
      style: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white : Colors.black87,
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
    );
  }

  Widget _buildBudgetField(bool isDark) {
    return TextFormField(
      controller: _budgetController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: TextStyle(color: Colors.grey[500]),
        suffixText: 'MRU',
        suffixStyle: TextStyle(
          color: ThemeColors.primaryColor,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ThemeColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: isDark ? ThemeColors.darkSurface : Colors.grey[50],
        contentPadding: EdgeInsets.all(16),
      ),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Budget requis';
        }
        final budget = int.tryParse(value);
        if (budget == null || budget <= 0) {
          return 'Budget invalide';
        }
        if (budget < 500) {
          return 'Min 500 MRU';
        }
        return null;
      },
    );
  }

  Widget _buildUrgentSwitch(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marquer comme urgent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (_isUrgent) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.priority_high, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'URGENT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: _isUrgent,
          onChanged: (value) => setState(() => _isUrgent = value),
          activeColor: Colors.red,
          activeTrackColor: Colors.red.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildLocationSelector(bool isDark) {
    return Column(
      children: [
        // Current Location Card
        _buildCurrentLocationCard(isDark),
        SizedBox(height: 16),

        // Divider with "OU"
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OU',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        SizedBox(height: 16),

        // Zone Selection
        DropdownButtonFormField<String>(
          value: _selectedLocation,
          decoration: InputDecoration(
            hintText: 'Choisir une zone',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ThemeColors.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: _isUsingCurrentLocation
                ? Colors.grey[100]
                : (isDark ? ThemeColors.darkSurface : Colors.grey[50]),
            contentPadding: EdgeInsets.all(16),
          ),
          dropdownColor: isDark ? ThemeColors.darkCardBackground : Colors.white,
          style: TextStyle(
            color: _isUsingCurrentLocation
                ? Colors.grey[500]
                : (isDark ? Colors.white : Colors.black87),
            fontSize: 16,
          ),
          onChanged: _isUsingCurrentLocation
              ? null
              : (String? newValue) {
                  setState(() => _selectedLocation = newValue!);
                },
          items: _nouakchottAreas.map<DropdownMenuItem<String>>((String area) {
            return DropdownMenuItem<String>(
              value: area,
              child: Text(area),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCurrentLocationCard(bool isDark) {
    return GestureDetector(
      onTap: _handleCurrentLocationTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isUsingCurrentLocation
              ? ThemeColors.primaryColor.withOpacity(0.1)
              : (isDark ? ThemeColors.darkSurface : Colors.grey[50]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isUsingCurrentLocation
                ? ThemeColors.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: _isUsingCurrentLocation ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isUsingCurrentLocation
                    ? ThemeColors.primaryColor
                    : ThemeColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.my_location,
                color: _isUsingCurrentLocation
                    ? Colors.white
                    : ThemeColors.primaryColor,
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ma position actuelle',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isUsingCurrentLocation
                          ? ThemeColors.primaryColor
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  if (_isUsingCurrentLocation &&
                      _currentLocationAddress != null)
                    Text(
                      _currentLocationAddress!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            if (_isUsingCurrentLocation)
              Icon(Icons.check_circle,
                  color: ThemeColors.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(bool isDark) {
    return Container(
      height: 200,
      child: Row(
        children: [
          // Hours
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  'Heure',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedHour = index + 1;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 12,
                      builder: (context, index) {
                        final hour = index + 1;
                        final isSelected = hour == _selectedHour;
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ThemeColors.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            hour.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: isSelected ? 20 : 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? ThemeColors.primaryColor
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Minutes
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  'Minute',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedMinute = index * 5;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 12,
                      builder: (context, index) {
                        final minute = index * 5;
                        final isSelected = minute == _selectedMinute;
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ThemeColors.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            minute.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: isSelected ? 20 : 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? ThemeColors.primaryColor
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // AM/PM
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(
                  'Période',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isAM = true),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: _isAM
                                ? ThemeColors.primaryColor
                                : (isDark
                                    ? ThemeColors.darkSurface
                                    : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'AM',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _isAM
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => setState(() => _isAM = false),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: !_isAM
                                ? ThemeColors.primaryColor
                                : (isDark
                                    ? ThemeColors.darkSurface
                                    : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PM',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: !_isAM
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDescription(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedTimeDescription,
      decoration: InputDecoration(
        hintText: 'Choisir quand',
        prefixIcon: Icon(
          Icons.schedule,
          color: ThemeColors.primaryColor,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ThemeColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: isDark ? ThemeColors.darkSurface : Colors.grey[50],
        contentPadding: EdgeInsets.all(16),
      ),
      dropdownColor: isDark ? ThemeColors.darkCardBackground : Colors.white,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() => _selectedTimeDescription = newValue);
        }
      },
      items:
          _timeDescriptions.map<DropdownMenuItem<String>>((String description) {
        return DropdownMenuItem<String>(
          value: description,
          child: Row(
            children: [
              Icon(
                _getTimeDescriptionIcon(description),
                color: ThemeColors.primaryColor,
                size: 18,
              ),
              SizedBox(width: 12),
              Text(
                description,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getTimeDescriptionIcon(String description) {
    switch (description) {
      case 'Ce matin':
      case 'Demain matin':
        return Icons.wb_sunny;
      case 'Cet après-midi':
      case 'Demain après-midi':
        return Icons.wb_sunny_outlined;
      case 'Ce soir':
      case 'Demain soir':
        return Icons.nights_stay;
      case 'Cette semaine':
        return Icons.calendar_today;
      case 'Le week-end':
        return Icons.weekend;
      case 'Quand vous voulez':
        return Icons.schedule;
      default:
        return Icons.access_time;
    }
  }

  Widget _buildFloatingActionButton(bool isEditing, bool isDark) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: ThemeColors.primaryColor.withOpacity(0.3),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isEditing ? Icons.save : Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text(
                    isEditing ? 'Sauvegarder' : 'Créer la tâche',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _handleCurrentLocationTap() async {
    if (_isUsingCurrentLocation) {
      setState(() {
        _isUsingCurrentLocation = false;
        _currentLocationAddress = null;
        _selectedCoordinates = null;
      });
      return;
    }

    // عرض واجهة طلب إذن الموقع للعميل
    final bool? locationGranted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ClientLocationPermissionScreen(),
      ),
    );

    if (locationGranted == true) {
      // فتح شاشة اختيار الموقع على الخريطة
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPickerScreen(),
        ),
      );

      if (result != null) {
        final LatLng coordinates = result['coordinates'];
        final String address = result['address'];

        setState(() {
          _isUsingCurrentLocation = true;
          _currentLocationAddress = address;
          _selectedCoordinates = coordinates;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Position sélectionnée: ${address}'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  String _getFormattedTime() {
    final period = _isAM ? 'AM' : 'PM';
    return '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} $period';
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 2));

    final isEditing = widget.taskToEdit != null;
    final String fullLocation =
        _isUsingCurrentLocation && _currentLocationAddress != null
            ? _currentLocationAddress!
            : '$_selectedLocation, Nouakchott';

    final taskData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'serviceType': _selectedServiceType,
      'budget': int.parse(_budgetController.text),
      'location': fullLocation,
      'coordinates': _selectedCoordinates != null
          ? {
              'latitude': _selectedCoordinates!.latitude,
              'longitude': _selectedCoordinates!.longitude
            }
          : null,
      'preferredTime': _getFormattedTime(),
      'timeDescription': _selectedTimeDescription,
      'isUsingCurrentLocation': _isUsingCurrentLocation,
      'isUrgent': _isUrgent,
    };

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing
            ? 'Tâche modifiée avec succès!'
            : 'Tâche créée avec succès!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Supprimer la tâche'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer cette tâche? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tâche supprimée'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}
