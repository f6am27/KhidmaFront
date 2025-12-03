import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/theme_colors.dart';
import '../../../models/models.dart';
import '../../../services/task_service.dart';
import '../../../services/category_service.dart';
import '../../../services/service_category_mapper.dart';
import '../../../services/payment_service.dart';
import '../../shared_screens/dialogs/subscription_prompt_dialog.dart';
import '../onboarding/client_location_permission_screen.dart';
import 'location_picker_screen.dart';
import 'widgets/saved_locations_screen.dart';

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
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  String _selectedServiceType = '';
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
  List<ServiceCategory> _categories = [];
  List<NouakchottArea> _areas = [];
  bool _isLoadingData = true;

  // Compteur de tâches (soft-lock)
  int? _tasksUsed;
  int? _tasksRemaining;
  bool _needsSubscription = false;

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

    _hourController =
        FixedExtentScrollController(initialItem: _selectedHour - 1);
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinute ~/ 5);

    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadCategories(),
      _loadAreas(),
      _loadTaskCounter(), // Charger le compteur pour l’affichage (optionnel)
    ]);

    if (widget.taskToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fillFormWithTaskData();
      });
    }
  }

  Future<void> _loadCategories() async {
    final result = await categoryService.getServiceCategories();
    if (result['ok'] && mounted) {
      setState(() {
        _categories = result['categories'] as List<ServiceCategory>;
        ServiceCategoryMapper.initialize(_categories);

        // ✅ السماح بعدم اختيار تصنيف
// لا نختار تصنيف افتراضي
      });
    }
  }

  Future<void> _loadAreas() async {
    final result = await categoryService.getNouakchottAreas(simple: true);
    if (result['ok'] && mounted) {
      setState(() {
        _areas = result['areas'] as List<NouakchottArea>;
        if (_areas.isNotEmpty && _selectedLocation.isEmpty) {
          _selectedLocation = _areas.first.name;
        }
        _isLoadingData = false;
      });
    }
  }

  Future<void> _loadTaskCounter() async {
    final result = await paymentService.checkTaskLimit();
    if (!mounted) return;

    if (result['ok'] == true && result['counter'] != null) {
      final counter = result['counter'];
      setState(() {
        _tasksUsed = counter.tasksUsed; // ✅ صحيح
        _tasksRemaining = counter.tasksRemaining;
        _needsSubscription = counter.needsSubscription;
      });
    }
  }

  void _fillFormWithTaskData() {
    final task = widget.taskToEdit!;

    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _budgetController.text = task.budget.toString();

    // ✅ Extraire le nom de la zone
    String locationText = task.location;

    if (locationText.contains('(')) {
      _selectedLocation = locationText.split('(')[0].trim();
    } else if (locationText.contains(',')) {
      _selectedLocation = locationText.split(',')[0].trim();
    } else {
      _selectedLocation = locationText.trim();
    }

    print('📍 Raw location: ${task.location}');
    print('📍 Extracted location: $_selectedLocation');

    if (!_areas.any((area) => area.name == _selectedLocation)) {
      print('⚠️ Location "$_selectedLocation" not found in areas list!');
      print('⚠️ Available areas: ${_areas.map((a) => a.name).toList()}');

      if (_areas.isNotEmpty) {
        _selectedLocation = _areas.first.name;
        print('✅ Using default area: $_selectedLocation');
      }
    }

    // ✅ Type de service - correspondance souple
// ✅ Type de service - معالجة "Non classifié"
    if (task.serviceType.toLowerCase() == "non classifié" ||
        task.serviceType.toLowerCase() == "non classifie") {
      // ✅ مهمة غير مصنفة
      _selectedServiceType = '';
      print('✅ Task is unclassified, serviceType set to empty');
    } else if (_categories.any((cat) => cat.name == task.serviceType)) {
      // ✅ تطابق تام
      _selectedServiceType = task.serviceType;
      print('✅ Service type exact match: $_selectedServiceType');
    } else {
      // ✅ محاولة المطابقة بالكلمة الأولى
      final firstWord = task.serviceType.split(' ').first;
      print(
          '🔍 Trying to match: "${task.serviceType}" → first word: "$firstWord"');

      try {
        final match = _categories.firstWhere(
          (cat) => cat.name.startsWith(firstWord),
        );
        _selectedServiceType = match.name;
        print('✅ Service type matched: "$_selectedServiceType"');
      } catch (e) {
        // ✅ إذا لم يُعثر على مطابقة، اتركها غير مصنفة
        _selectedServiceType = '';
        print('⚠️ No match found, setting as unclassified');
      }
    }

    // Urgence
    _isUrgent = task.isUrgent;
    print('✅ IsUrgent filled: $_isUrgent');

    // Coordonnées
    _selectedCoordinates = task.coordinates;

    if (task.coordinates != null) {
      _isUsingCurrentLocation = true;
      _currentLocationAddress = task.location;
    }

    // Heure
    if (task.preferredTime.isNotEmpty) {
      try {
        final timeParts = task.preferredTime.trim().split(' ');
        if (timeParts.length == 2) {
          final hourMinute = timeParts[0].split(':');
          if (hourMinute.length == 2) {
            int hour = int.parse(hourMinute[0]);
            int minute = int.parse(hourMinute[1]);
            String period = timeParts[1].toUpperCase();

            _isAM = (period == 'AM');
            _selectedHour = (hour == 0) ? 12 : ((hour > 12) ? hour - 12 : hour);
            _selectedMinute = (minute ~/ 5) * 5;

            _hourController.jumpToItem(_selectedHour - 1);
            _minuteController.jumpToItem(_selectedMinute ~/ 5);

            print(
                '✅ Time filled: $_selectedHour:$_selectedMinute ${_isAM ? "AM" : "PM"}');
          }
        }
      } catch (e) {
        print('⚠️ Error parsing time: $e');
      }
    }

    // Description du moment
    if (task.timeDescription != null &&
        _timeDescriptions.contains(task.timeDescription)) {
      _selectedTimeDescription = task.timeDescription!;
      print('✅ TimeDescription filled: $_selectedTimeDescription');
    } else {
      print('⚠️ timeDescription is null or not in list, using default');
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      backgroundColor:
          isDark ? ThemeColors.darkBackground : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? ThemeColors.darkCardBackground : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back,
              size: 25,
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
          if (isEditing && widget.taskToEdit?.status == TaskStatus.published)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.red, size: 18),
              ),
              onPressed: () => _showDeleteConfirmation(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            if (!isEditing && _tasksUsed != null && _tasksRemaining != null)
              _buildCounterBanner(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServiceTypeChips(isDark),
                    const SizedBox(height: 24),
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Titre de la tâche',
                      child: _buildTitleField(isDark),
                    ),
                    const SizedBox(height: 20),
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Description',
                      child: _buildDescriptionField(isDark),
                    ),
                    const SizedBox(height: 20),
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Budget',
                      child: _buildBudgetField(isDark),
                    ),
                    const SizedBox(height: 20),
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Priorité',
                      child: _buildUrgentSwitch(isDark),
                    ),
                    const SizedBox(height: 20),
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Localisation',
                      child: _buildLocationSelector(isDark),
                    ),
                    const SizedBox(height: 20),
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Horaire',
                      child: _buildTimePicker(isDark),
                    ),
                    const SizedBox(height: 20),
                    _buildModernCard(
                      isDark: isDark,
                      title: 'Quand',
                      child: _buildTimeDescription(isDark),
                    ),
                    const SizedBox(height: 100),
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

  Widget _buildCounterBanner(bool isDark) {
    final remaining = _tasksRemaining ?? 0;
    final used = _tasksUsed ?? 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _needsSubscription
            ? Colors.red.withOpacity(0.08)
            : ThemeColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _needsSubscription ? Colors.redAccent : ThemeColors.primaryColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _needsSubscription ? Icons.lock_outline : Icons.info_outline,
            color: _needsSubscription
                ? Colors.redAccent
                : ThemeColors.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _needsSubscription
                  ? 'Vous avez atteint la limite de tâches gratuites.'
                  : 'Vous avez utilisé $used tâche(s). Il vous reste $remaining tâche(s) gratuite(s).',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required bool isDark,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
          const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length + 1, // ✅ +1 لخيار "غير مصنف"
            itemBuilder: (context, index) {
              // ✅ الخيار الأول: "Non classifié"
              if (index == 0) {
                final isSelected = _selectedServiceType.isEmpty;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedServiceType = ''),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.orange.withOpacity(0.15)
                            : (isDark
                                ? ThemeColors.darkCardBackground
                                : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.orange
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.help_outline, // ✅ أيقونة علامة استفهام
                            color:
                                isSelected ? Colors.orange : Colors.grey[600],
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Non\nclassifié',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.orange
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
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
              }

              // ✅ باقي التصنيفات (index - 1)
              final category = _categories[index - 1];
              // final category = _categories[index];
              final isSelected = _selectedServiceType == category.name;
              final serviceColor = _getCategoryColor(category.name);

              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedServiceType = category.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    padding: const EdgeInsets.all(8),
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
                          _getCategoryIcon(category.icon),
                          color: isSelected ? serviceColor : Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.name,
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
        contentPadding: const EdgeInsets.all(16),
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
        contentPadding: const EdgeInsets.all(16),
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
        contentPadding: const EdgeInsets.all(16),
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
        if (budget < 50) {
          return 'Min 50 MRU';
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
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
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
        // 🗂️ زر للوصول إلى المواقع المحفوظة
        GestureDetector(
          onTap: _openSavedLocationsScreen,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? ThemeColors.darkSurface : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Choisir un emplacement fréquent',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildCurrentLocationCard(isDark),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
        const SizedBox(height: 16),
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
            contentPadding: const EdgeInsets.all(16),
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
                  if (newValue != null) {
                    setState(() => _selectedLocation = newValue);
                  }
                },
          items: _areas.map<DropdownMenuItem<String>>((area) {
            return DropdownMenuItem<String>(
              value: area.name,
              child: Text(area.name),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.all(8),
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
            const SizedBox(width: 12),
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
    return SizedBox(
      height: 200,
      child: Row(
        children: [
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
                const SizedBox(height: 8),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: _hourController,
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
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
                const SizedBox(height: 8),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: _minuteController,
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
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
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isAM = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
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
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => setState(() => _isAM = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
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
        contentPadding: const EdgeInsets.all(16),
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
              const SizedBox(width: 12),
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            ? const SizedBox(
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
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Sauvegarder' : 'Créer la tâche',
                    style: const TextStyle(
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

    final bool? locationGranted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ClientLocationPermissionScreen(),
      ),
    );

    if (locationGranted == true) {
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
                const Icon(Icons.location_on, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Position sélectionnée: $address'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // 🗂️ فتح صفحة المواقع المحفوظة
  void _openSavedLocationsScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => SavedLocationsScreen(),
      ),
    );

    if (result != null) {
      final LatLng coordinates = result['coordinates'];
      final String address = result['address'];
      final String? name = result['name'];

      setState(() {
        _isUsingCurrentLocation = true;
        _currentLocationAddress = name != null ? '$name - $address' : address;
        _selectedCoordinates = coordinates;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Emplacement sélectionné: ${name ?? address}'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  String _getFormattedTime() {
    final period = _isAM ? 'AM' : 'PM';
    return '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} $period';
  }

  Future<bool> _checkSoftLockBeforeCreate() async {
    // Vérification "temps réel" avant la création
    final result = await paymentService.checkTaskLimit();

    if (result['ok'] == true && result['counter'] != null) {
      final counter = result['counter'];
      final needsSubscription = counter.needsSubscription;

      if (needsSubscription) {
        await SubscriptionPromptDialog.show(
          context,
          role: 'client',
          tasksUsed: counter.tasksUsed,
          tasksRemaining: counter.tasksRemaining,
          errorMessage: result['error']?.toString(),
        );
        return false;
      }
      return true;
    }

    // En cas d’erreur de réseau, on laisse passer mais on informe l’utilisateur
    if (mounted && result['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'].toString()),
          backgroundColor: Colors.orange,
        ),
      );
    }
    return true;
  }

  void _submitForm() async {
    print('🔵 _submitForm called');

    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }
    // ✅ تحذير إذا لم يختر تصنيف
    if (_selectedServiceType.isEmpty) {
      final confirmed = await _showUnclassifiedWarning();
      if (!confirmed) {
        print('⚠️ User chose to select a category');
        return;
      }
    }

    final isEditing = widget.taskToEdit != null;

    // ✅ Soft-lock : uniquement pour la création, pas pour la modification
    if (!isEditing) {
      final allowed = await _checkSoftLockBeforeCreate();
      if (!allowed) {
        print('⛔ Création bloquée par la limite de tâches');
        return;
      }
    }

    print('✅ Form validation passed');
    setState(() => _isLoading = true);

    final String fullLocation =
        _isUsingCurrentLocation && _currentLocationAddress != null
            ? _currentLocationAddress!
            : '$_selectedLocation, Nouakchott';

    try {
      Map<String, dynamic> result;

      if (isEditing) {
        result = await taskService.updateTask(
          taskId: widget.taskToEdit!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          serviceType: _selectedServiceType.isNotEmpty
              ? _selectedServiceType
              : null, // ✅ null إذا فارغ
          budget: int.parse(_budgetController.text),
          location: fullLocation,
          preferredTime: _getFormattedTime(),
          isUrgent: _isUrgent,
          latitude: _selectedCoordinates?.latitude,
          longitude: _selectedCoordinates?.longitude,
        );
      } else {
        result = await taskService.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          serviceType: _selectedServiceType,
          budget: int.parse(_budgetController.text),
          location: fullLocation,
          preferredTime: _getFormattedTime(),
          isUrgent: _isUrgent,
          latitude: _selectedCoordinates?.latitude,
          longitude: _selectedCoordinates?.longitude,
          timeDescription: _selectedTimeDescription,
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['ok'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing
                  ? 'Tâche modifiée avec succès!'
                  : 'Tâche créée avec succès!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Une erreur est survenue'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Annuler la tâche'),
        content: const Text(
            'Êtes-vous sûr de vouloir annuler cette tâche ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => _performDelete(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, annuler',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete() async {
    Navigator.pop(context);

    // L’ancien appel TaskService.updateTaskStatus() n’est plus disponible.
    // Pour l’instant, on affiche simplement un message.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'L’annulation de tâche sera bientôt disponible dans la nouvelle version.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<bool> _showUnclassifiedWarning() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text('Attention'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vous n\'avez pas sélectionné de catégorie.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Text(
                  'Votre tâche sera publiée comme "Non classifié", ce qui peut:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                _buildWarningItem('⚠️', 'Réduire le nombre de candidatures'),
                _buildWarningItem('⚠️', 'Rendre la recherche plus difficile'),
                _buildWarningItem('⚠️', 'Limiter la visibilité'),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Nous vous recommandons de choisir une catégorie appropriée.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Choisir une catégorie'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text('Continuer sans catégorie'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildWarningItem(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    final colors = {
      'Nettoyage Maison': Colors.blue,
      'Nettoyage Tapis': Colors.lightBlue,
      'Plomberie': Colors.indigo,
      'Électricité': Colors.amber,
      'Jardinage': Colors.green,
      'Peinture': Colors.purple,
      'Déménagement': Colors.orange,
      'Réparation Téléphone': Colors.red,
      'Cuisine Quotidienne': Colors.brown,
    };
    return colors[categoryName] ?? Colors.grey;
  }

  IconData _getCategoryIcon(String icon) {
    final icons = {
      'cleaning_services': Icons.cleaning_services,
      'local_laundry_service': Icons.local_laundry_service,
      'grass': Icons.grass,
      'pets': Icons.pets,
      'child_care': Icons.child_care,
      'school': Icons.school,
      'plumbing': Icons.plumbing,
      'electrical_services': Icons.electrical_services,
      'ac_unit': Icons.ac_unit,
      'phone_android': Icons.phone_android,
      'computer': Icons.computer,
      'build': Icons.build,
      'format_paint': Icons.format_paint,
      'construction': Icons.construction,
      'carpenter': Icons.carpenter,
      'delivery_dining': Icons.delivery_dining,
      'local_shipping': Icons.local_shipping,
      'drive_eta': Icons.drive_eta,
      'flight': Icons.flight,
      'restaurant': Icons.restaurant,
      'cake': Icons.cake,
      'celebration': Icons.celebration,
      'handyman': Icons.handyman,
      'content_cut': Icons.content_cut,
      'face': Icons.face,
      'brush': Icons.brush,
      'photo_camera': Icons.photo_camera,
      'video_call': Icons.video_call,
      'web': Icons.web,
      'support': Icons.support,
    };
    return icons[icon] ?? Icons.work_outline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}
