import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../models/models.dart';
import '../../../../services/profile_service.dart';
import '../../../../services/category_service.dart';

class WorkerProfileEditScreen extends StatefulWidget {
  @override
  _WorkerProfileEditScreenState createState() =>
      _WorkerProfileEditScreenState();
}

class _WorkerProfileEditScreenState extends State<WorkerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  final CategoryService _categoryService = CategoryService();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descController = TextEditingController();

  // State variables
  bool _isLoading = true;
  bool _isSaving = false;
  WorkerProfile? _workerProfile;
  List<ServiceCategory> _categories = [];
  List<NouakchottArea> _areas = [];
  File? _avatarFile;

  // Selected values
  int? _selectedCategoryId;
  String? _selectedCategory;
  String? _selectedArea;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final Set<String> _selectedDays = {};

  // Available days mapping for backend compatibility
  final Map<String, String> _dayMapping = {
    'Lun': 'monday',
    'Mar': 'tuesday',
    'Mer': 'wednesday',
    'Jeu': 'thursday',
    'Ven': 'friday',
    'Sam': 'saturday',
    'Dim': 'sunday',
  };

  final List<String> _days = const [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load profile data and categories/areas in parallel
      final results = await Future.wait([
        _profileService.getWorkerProfile(),
        _categoryService.getCombinedData(),
      ]);

      final profileResult = results[0] as Map<String, dynamic>;
      final dataResult = results[1] as Map<String, dynamic>;

      if (profileResult['ok'] == true) {
        _workerProfile = profileResult['workerProfile'] as WorkerProfile;
        _populateFormFields();
      } else {
        _showError(
            'Erreur lors du chargement du profil: ${profileResult['error']}');
      }

      if (dataResult['ok'] == true) {
        _categories = dataResult['categories'] as List<ServiceCategory>;
        _areas = dataResult['areas'] as List<NouakchottArea>;
        _updateCategorySelection();
      } else {
        _showError(
            'Erreur lors du chargement des données: ${dataResult['error']}');
      }
    } catch (e) {
      _showError('Erreur réseau: $e');
    }

    setState(() => _isLoading = false);
  }

  void _populateFormFields() {
    if (_workerProfile == null) return;

    final profile = _workerProfile!;

    _nameController.text =
        '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
    _phoneController.text = profile.phone;
    _priceController.text = profile.basePrice.toString();
    _areaController.text = profile.serviceArea;
    _descController.text = profile.bio;
    _selectedCategory = profile.serviceCategory;
    _selectedArea = profile.serviceArea;

    // Parse work times
    _startTime = _parseTimeString(profile.workStartTime);
    _endTime = _parseTimeString(profile.workEndTime);

    // Parse available days - convert from backend format to display format
    _selectedDays.clear();
    for (final backendDay in profile.availableDays) {
      final displayDay = _dayMapping.entries
          .firstWhere((entry) => entry.value == backendDay,
              orElse: () => const MapEntry('', ''))
          .key;
      if (displayDay.isNotEmpty) {
        _selectedDays.add(displayDay);
      }
    }
  }

  void _updateCategorySelection() {
    if (_selectedCategory != null && _categories.isNotEmpty) {
      final category = _categories.firstWhere(
        (cat) => cat.name == _selectedCategory,
        orElse: () => _categories.first,
      );
      _selectedCategoryId = category.id;
    }
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      print('Error parsing time: $timeStr');
    }
    return null;
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimeForBackend(TimeOfDay? time) {
    if (time == null) return '08:00';
    return _formatTime(time);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initialTime = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isStart ? (_startTime ?? initialTime) : (_endTime ?? initialTime),
      confirmText: 'OK',
      cancelText: 'Annuler',
      helpText: isStart ? 'Heure de début' : 'Heure de fin',
    );
    if (picked != null) {
      setState(() {
        isStart ? _startTime = picked : _endTime = picked;
      });
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() => _avatarFile = File(image.path));
        // Auto-upload the image
        await _uploadProfileImage();
      }
    } on PlatformException catch (e) {
      _showError('Impossible d\'ouvrir la galerie: ${e.message ?? ''}');
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_avatarFile == null) return;

    try {
      final result = await _profileService.uploadProfileImage(_avatarFile!);

      if (result['ok'] == true) {
        _showSuccess('Photo de profil mise à jour');
        // إعادة تحميل البيانات المحدثة من الخادم
        await _loadData();
      } else {
        _showError('Erreur lors du téléchargement: ${result['error']}');
      }
    } catch (e) {
      _showError('Erreur réseau: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      _showError('Veuillez sélectionner vos jours disponibles');
      return;
    }

    if (_startTime == null || _endTime == null) {
      _showError('Veuillez choisir votre plage horaire');
      return;
    }

    if (_selectedCategoryId == null) {
      _showError('Veuillez choisir une catégorie de service');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Parse full name
      final fullName = _nameController.text.trim();
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

      // Convert selected days to backend format
      final backendDays = _selectedDays
          .map((day) => _dayMapping[day])
          .where((day) => day != null)
          .cast<String>()
          .toList();

      final result = await _profileService.updateWorkerProfile(
        firstName: firstName,
        lastName: lastName.isEmpty ? null : lastName,
        bio: _descController.text.trim(),
        serviceArea: _areaController.text.trim(),
        serviceCategory: _selectedCategory,
        basePrice: double.tryParse(_priceController.text.trim()),
        availableDays: backendDays,
        workStartTime: _formatTimeForBackend(_startTime),
        workEndTime: _formatTimeForBackend(_endTime),
        isAvailable: true,
      );

      if (result['ok'] == true) {
        _showSuccess('Profil mis à jour avec succès');
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        if (result['needsLogin'] == true) {
          _showError('Veuillez vous reconnecter');
          // TODO: Navigate to login screen
        } else {
          _showError('Erreur: ${result['error']}');
        }
      }
    } catch (e) {
      _showError('Erreur réseau: $e');
    }

    setState(() => _isSaving = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le Profil'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ThemeColors.primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Chargement du profil...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),

                      // Photo de profil
                      _buildProfilePhoto(context, isDark),
                      SizedBox(height: 30),

                      // Informations personnelles
                      _buildSectionTitle(context, 'Informations personnelles'),
                      SizedBox(height: 16),
                      _buildPersonalInfoFields(context, isDark),
                      SizedBox(height: 30),

                      // Informations professionnelles
                      _buildSectionTitle(
                          context, 'Informations professionnelles'),
                      SizedBox(height: 16),
                      _buildProfessionalInfoFields(context, isDark),
                      SizedBox(height: 30),

                      // Disponibilité
                      _buildSectionTitle(context, 'Disponibilité'),
                      SizedBox(height: 16),
                      _buildAvailabilityFields(context, isDark),
                      SizedBox(height: 40),

                      // Bouton de mise à jour
                      _buildUpdateButton(context),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePhoto(BuildContext context, bool isDark) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor:
                isDark ? ThemeColors.darkSurface : Colors.grey[200],
            backgroundImage: _avatarFile != null
                ? FileImage(_avatarFile!)
                : (_workerProfile?.profileImageUrl != null
                    ? NetworkImage(_workerProfile!.profileImageUrl!)
                    : null) as ImageProvider?,
            child:
                (_avatarFile == null && _workerProfile?.profileImageUrl == null)
                    ? Icon(
                        Icons.person,
                        size: 70,
                        color: isDark
                            ? ThemeColors.darkTextSecondary
                            : Colors.grey[600],
                      )
                    : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ThemeColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? ThemeColors.darkBackground : Colors.white,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
    );
  }

  Widget _buildPersonalInfoFields(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom complet
        _buildFieldLabel(context, 'Nom complet'),
        SizedBox(height: 8),
        _buildTextField(
          controller: _nameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le nom est requis';
            }
            return null;
          },
        ),
        SizedBox(height: 20),

        // Téléphone (read-only)
        _buildFieldLabel(context, 'Numéro de téléphone'),
        SizedBox(height: 8),
        _buildPhoneField(),
      ],
    );
  }

  Widget _buildProfessionalInfoFields(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Catégorie
        _buildFieldLabel(context, 'Catégorie de service'),
        SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedCategoryId,
          items: _categories
              .map((category) => DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
              final category = _categories.firstWhere((cat) => cat.id == value);
              _selectedCategory = category.name;
            });
          },
          decoration: _buildInputDecoration(),
          style: Theme.of(context).textTheme.bodyLarge,
          validator: (value) {
            if (value == null) {
              return 'Veuillez choisir une catégorie';
            }
            return null;
          },
        ),
        SizedBox(height: 20),

        // Tarif
        _buildFieldLabel(context, 'Tarif habituel (MRU)'),
        SizedBox(height: 8),
        _buildTextField(
          controller: _priceController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,]\d{0,2})?$')),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer un tarif';
            }
            final price = double.tryParse(value.replaceAll(',', '.'));
            if (price == null || price <= 0) {
              return 'Tarif invalide';
            }
            return null;
          },
        ),
        SizedBox(height: 20),

// Zone d'intervention
        _buildFieldLabel(context, 'Zone d\'intervention'),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedArea,
          items: _areas
              .map((area) => DropdownMenuItem<String>(
                    value: area.name,
                    child: Text(area.name),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedArea = value;
              _areaController.text = value ?? '';
            });
          },
          decoration: _buildInputDecoration(),
          style: Theme.of(context).textTheme.bodyLarge,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez choisir une zone';
            }
            return null;
          },
          hint: Text('Sélectionner une zone'),
        ),
        SizedBox(height: 20),

        // Description
        _buildFieldLabel(context, 'Description du service'),
        SizedBox(height: 8),
        _buildTextField(
          controller: _descController,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez décrire votre service';
            }
            if (value.trim().length < 20) {
              return 'La description doit contenir au moins 20 caractères';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAvailabilityFields(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Jours disponibles
        _buildFieldLabel(context, 'Jours disponibles'),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _days.map((day) {
            final selected = _selectedDays.contains(day);
            return FilterChip(
              label: Text(day),
              selected: selected,
              onSelected: (isSelected) => setState(() {
                isSelected ? _selectedDays.add(day) : _selectedDays.remove(day);
              }),
              showCheckmark: false,
              selectedColor: ThemeColors.primaryColor.withOpacity(0.12),
              side: BorderSide(
                  color: isDark ? ThemeColors.darkBorder : Colors.grey[300]!),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? ThemeColors.primaryColor
                        : (isDark ? Colors.white : Colors.black87),
                  ),
            );
          }).toList(),
        ),
        SizedBox(height: 20),

        // Heures de travail
        _buildFieldLabel(context, 'Heures de travail'),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickTime(isStart: true),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? ThemeColors.darkSurface : Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? ThemeColors.darkBorder
                          : ThemeColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        color: isDark
                            ? ThemeColors.darkTextSecondary
                            : Colors.grey[600],
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Début',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? ThemeColors.darkTextSecondary
                                          : Colors.grey[600],
                                    ),
                          ),
                          Text(
                            _formatTime(_startTime),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _startTime != null
                                      ? (isDark ? Colors.white : Colors.black)
                                      : (isDark
                                          ? ThemeColors.darkTextSecondary
                                          : Colors.grey[600]),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => _pickTime(isStart: false),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? ThemeColors.darkSurface : Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? ThemeColors.darkBorder
                          : ThemeColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        color: isDark
                            ? ThemeColors.darkTextSecondary
                            : Colors.grey[600],
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fin',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? ThemeColors.darkTextSecondary
                                          : Colors.grey[600],
                                    ),
                          ),
                          Text(
                            _formatTime(_endTime),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _endTime != null
                                      ? (isDark ? Colors.white : Colors.black)
                                      : (isDark
                                          ? ThemeColors.darkTextSecondary
                                          : Colors.grey[600]),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: _buildInputDecoration(),
    );
  }

  Widget _buildPhoneField() {
    final isDark = Theme.of(context).brightness == Brightness.dark; // ✅ أضف هذا

    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: Theme.of(context).textTheme.bodyLarge,
      readOnly: true,
      decoration: _buildInputDecoration().copyWith(
        suffixIcon: Icon(
          Icons.lock_outline,
          color: isDark ? ThemeColors.darkTextSecondary : Colors.grey,
          size: 20,
        ),
        fillColor: isDark
            ? ThemeColors.darkSurface.withOpacity(0.5)
            : Colors.grey[100],
      ),
    );
  }

  InputDecoration _buildInputDecoration() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      filled: true,
      fillColor: isDark ? ThemeColors.darkSurface : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: isDark ? ThemeColors.darkBorder : ThemeColors.lightBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: isDark ? ThemeColors.darkBorder : ThemeColors.lightBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: ThemeColors.primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: ThemeColors.errorColor,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: ThemeColors.errorColor,
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          disabledBackgroundColor: Colors.grey[400],
        ),
        child: _isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Mise à jour...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'Mettre à jour le profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
