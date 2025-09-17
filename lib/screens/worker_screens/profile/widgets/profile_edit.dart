import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme_colors.dart';

class WorkerProfileEditScreen extends StatefulWidget {
  @override
  _WorkerProfileEditScreenState createState() =>
      _WorkerProfileEditScreenState();
}

class _WorkerProfileEditScreenState extends State<WorkerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descController = TextEditingController();

  // Data from WorkerOnboardingScreen
  String? _selectedCategory;
  final List<String> _categories = const [
    'Électricien',
    'Plombier',
    'Peinture',
    'Jardinier',
    'Garde d\'enfants',
    'Ménage',
    'Menuisier',
    'Autre',
  ];

  final List<String> _days = const [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim'
  ];
  final Set<String> _selectedDays = {'Lun', 'Mar', 'Mer', 'Jeu', 'Ven'};

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    // هنا سيتم تحميل البيانات الحالية للعامل
    _nameController.text = 'Mohamed Ould Ahmed';
    _phoneController.text = '32 92 12 88';
    _emailController.text = 'mohamed@example.com';
    _priceController.text = '3000';
    _areaController.text = 'Ksar, Nouakchott';
    _descController.text =
        'Plombier et électricien expérimenté avec plus de 5 ans d\'expérience';
    _selectedCategory = 'Plombier';
    _startTime = TimeOfDay(hour: 8, minute: 0);
    _endTime = TimeOfDay(hour: 18, minute: 0);
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

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
      final image =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image != null) {
        setState(() => _avatarFile = File(image.path));
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'ouvrir la galerie: ${e.message ?? ''}'),
        ),
      );
    }
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
      body: SingleChildScrollView(
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
                _buildSectionTitle(context, 'Informations professionnelles'),
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
            backgroundImage:
                _avatarFile != null ? FileImage(_avatarFile!) : null,
            child: _avatarFile == null
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
        // Nom
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

        // Email
        _buildFieldLabel(context, 'Email'),
        SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'L\'email est requis';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email invalide';
            }
            return null;
          },
        ),
        SizedBox(height: 20),

        // Téléphone
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
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          items: _categories
              .map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
          decoration: _buildInputDecoration(),
          style: Theme.of(context).textTheme.bodyLarge,
          validator: (value) {
            if (value == null || value.isEmpty) {
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
            return null;
          },
        ),
        SizedBox(height: 20),

        // Zone d'intervention
        _buildFieldLabel(context, 'Zone d\'intervention'),
        SizedBox(height: 8),
        _buildTextField(
          controller: _areaController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer la zone de service';
            }
            return null;
          },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: Theme.of(context).textTheme.bodyLarge,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Le numéro de téléphone est requis';
        }
        return null;
      },
      decoration: _buildInputDecoration().copyWith(
        suffixIcon: TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Fonctionnalité de changement en cours de développement'),
                backgroundColor: ThemeColors.primaryColor,
              ),
            );
          },
          child: Text(
            'Changer',
            style: TextStyle(
              color: ThemeColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
        onPressed: _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          'Mettre à jour le profil',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez sélectionner vos jours disponibles'),
            backgroundColor: ThemeColors.errorColor,
          ),
        );
        return;
      }

      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez choisir votre plage horaire'),
            backgroundColor: ThemeColors.errorColor,
          ),
        );
        return;
      }

      // TODO: Ici nous enverrons les données mises à jour au serveur

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: ThemeColors.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context);
    }
  }
}
