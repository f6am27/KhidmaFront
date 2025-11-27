import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:micro_emploi_app/constants/colors.dart';
import 'package:micro_emploi_app/constants/text_styles.dart';
import 'package:micro_emploi_app/routes/app_routes.dart';
import '../../services/auth_api.dart';
import '../../core/storage/token_storage.dart';
import '../../services/category_service.dart';
import '../../services/profile_service.dart';
import '../../models/models.dart';
import '../../services/auth_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerOnboardingScreen extends StatefulWidget {
  @override
  State<WorkerOnboardingScreen> createState() => _WorkerOnboardingScreenState();
}

class _WorkerOnboardingScreenState extends State<WorkerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  // البيانات
  // removed old String? _selectedCategory and string list; replaced with model types below

  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descController = TextEditingController();

  // Days (updated)
  final List<String> _days = const [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];
  final List<String> _dayLabels = const [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim'
  ];
  final Set<String> _selectedDays = {
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday'
  };

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  File? _avatarFile;

  // === NEW variables (after avatar) ===
  // Controllers للاسم
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  // Data from Backend
  List<ServiceCategory> _categories = [];
  List<NouakchottArea> _areas = [];
  ServiceCategory? _selectedCategory;
  NouakchottArea? _selectedArea;

  // Services instances (so methods below can call them)
  final categoryService = CategoryService();
  final profileService = ProfileService();

  // Loading states
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // إضافة method لتحميل البيانات
  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoadingData = true);
      final result = await categoryService.getCombinedData();

      if (result['ok'] == true) {
        setState(() {
          _categories = (result['categories'] as List<dynamic>?)
                  ?.cast<ServiceCategory>() ??
              [];
          _areas =
              (result['areas'] as List<dynamic>?)?.cast<NouakchottArea>() ?? [];
          _isLoadingData = false;
        });
      } else {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                result['error'] ?? 'Erreur lors du chargement des données'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------- Helpers بسيطة ونظيفة ----------
  InputDecoration _dec(String label, {IconData? icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppTextStyles.bodyText.copyWith(color: AppColors.mediumGray),
      hintStyle: AppTextStyles.bodyText
          .copyWith(color: AppColors.mediumGray.withOpacity(.7)),
      prefixIcon: icon != null ? Icon(icon, color: AppColors.mediumGray) : null,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.red, width: 2),
      ),
    );
  }

  String _fmtTime(TimeOfDay? t) {
    if (t == null) return '--:--';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // === NEW method ===
  String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final x =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (x != null) setState(() => _avatarFile = File(x.path));
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Impossible d\'ouvrir la galerie: ${e.message ?? ''}')),
      );
    }
  }

  Future<void> _pickTime({required bool start}) async {
    final init = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? (_startTime ?? init) : (_endTime ?? init),
      confirmText: 'OK',
      cancelText: 'Annuler',
      helpText: start ? 'Heure de début' : 'Heure de fin',
    );
    if (picked != null)
      setState(() => start ? _startTime = picked : _endTime = picked);
  }

  // === UPDATED _submit method ===
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une catégorie')),
      );
      return;
    }

    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une zone de service')),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez sélectionner vos jours disponibles')),
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir votre plage horaire')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_avatarFile != null) {
        final imageResult =
            await profileService.uploadProfileImage(_avatarFile!);
        if (imageResult['ok'] != true) {
          print('Image upload failed: ${imageResult['error']}');
        }
      }

      final result = await profileService.completeWorkerOnboarding(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        bio: _descController.text.trim(),
        serviceArea: _selectedArea!.name,
        serviceCategory: _selectedCategory!.name,
        basePrice: double.parse(_priceController.text.trim()),
        availableDays: _selectedDays.toList(),
        workStartTime: _timeToString(_startTime!),
        workEndTime: _timeToString(_endTime!),
        // optionally pass imageUrl if your service expects it
      );

      if (result['ok'] == true) {
        final completeResult = await AuthApi().completeWorkerOnboarding();

        if (completeResult['ok'] == true) {
          final json = completeResult['json'] ?? {};
          final user = json['user'] ?? {};
          await TokenStorage.saveUserData(user);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil créé avec succès!')),
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('worker_nav_index', 0);
          await prefs.remove('worker_nav_index');

          Navigator.pushReplacementNamed(
            context,
            AppRoutes.home,
            arguments: {'role': 'worker'},
          );
        } else {
          throw Exception(completeResult['json']?['detail'] ??
              'Failed to complete onboarding');
        }
      } else {
        throw Exception(result['error'] ?? 'Failed to create profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // >>> END REPLACE

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 20),

                      // العنوان والوصف
                      Text(
                        'Complétez votre profil',
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ne vous inquiétez pas, vous seul pouvez voir vos\ndonnées personnelles. Personne d\'autre ne pourra les voir.',
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: 14,
                          color: AppColors.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // صورة الملف الشخصي
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFF3F4F6),
                              backgroundImage: _avatarFile != null
                                  ? FileImage(_avatarFile!)
                                  : null,
                              child: _avatarFile == null
                                  ? Icon(Icons.person,
                                      size: 50, color: AppColors.mediumGray)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickAvatar,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryPurple,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // === NEW Personal Info Section ===
                            _buildSectionTitle('Informations personnelles'),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstNameController,
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Prénom requis'
                                            : null,
                                    decoration: _dec('Prénom'),
                                    style: AppTextStyles.bodyText,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _lastNameController,
                                    decoration: _dec('Nom de famille'),
                                    style: AppTextStyles.bodyText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Catégorie
                            Text(
                              'Catégorie de service',
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<ServiceCategory>(
                              value: _selectedCategory,
                              items: _categories
                                  .map((category) =>
                                      DropdownMenuItem<ServiceCategory>(
                                        value: category,
                                        child: Text(category.name),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCategory = v),
                              decoration: _dec('Sélectionner une catégorie'),
                              style: AppTextStyles.bodyText,
                              validator: (v) =>
                                  v == null ? 'Catégorie requise' : null,
                            ),
                            const SizedBox(height: 24),

                            // === NEW Service Area Dropdown ===
                            _buildSectionTitle('Zone d\'intervention'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<NouakchottArea>(
                              value: _selectedArea,
                              items: _areas
                                  .map((area) =>
                                      DropdownMenuItem<NouakchottArea>(
                                        value: area,
                                        child: Text(area.displayName),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedArea = v),
                              decoration: _dec('Sélectionner une zone'),
                              style: AppTextStyles.bodyText,
                              validator: (v) =>
                                  v == null ? 'Zone requise' : null,
                            ),
                            const SizedBox(height: 24),

                            // Tarif
                            Text(
                              'Tarif habituel',
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+([.,]\d{0,2})?$')),
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Veuillez entrer un tarif';
                                return null;
                              },
                              decoration: _dec('ex: 150.00'),
                              style: AppTextStyles.bodyText,
                            ),
                            const SizedBox(height: 24),

                            // Jours disponibles
                            Text(
                              'Jours disponibles',
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: List.generate(_days.length, (index) {
                                final day = _days[index];
                                final label = _dayLabels[index];
                                final selected = _selectedDays.contains(day);

                                return FilterChip(
                                  label: Text(label),
                                  selected: selected,
                                  onSelected: (s) => setState(() {
                                    s
                                        ? _selectedDays.add(day)
                                        : _selectedDays.remove(day);
                                  }),
                                  showCheckmark: false,
                                  selectedColor:
                                      AppColors.primaryPurple.withOpacity(.12),
                                  side: const BorderSide(
                                      color: Color(0xFFE5E7EB)),
                                  labelStyle: AppTextStyles.bodyText.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? AppColors.primaryPurple
                                        : Colors.black87,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),

                            // Heures de travail
                            Text(
                              'Heures de travail',
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),

                            GestureDetector(
                              onTap: () => _pickTime(start: true),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.schedule_outlined,
                                        color: AppColors.mediumGray),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Heure de début',
                                      style: AppTextStyles.bodyText.copyWith(
                                          color: AppColors.mediumGray),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _fmtTime(_startTime),
                                      style: AppTextStyles.bodyText.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _startTime != null
                                            ? AppColors.textPrimary
                                            : AppColors.mediumGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            GestureDetector(
                              onTap: () => _pickTime(start: false),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.schedule_outlined,
                                        color: AppColors.mediumGray),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Heure de fin',
                                      style: AppTextStyles.bodyText.copyWith(
                                          color: AppColors.mediumGray),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _fmtTime(_endTime),
                                      style: AppTextStyles.bodyText.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _endTime != null
                                            ? AppColors.textPrimary
                                            : AppColors.mediumGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Description
                            Text(
                              'Description du service',
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descController,
                              maxLines: 4,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Veuillez décrire votre service';
                                }
                                return null;
                              },
                              decoration: _dec('Décrivez votre service'),
                              style: AppTextStyles.bodyText,
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // زر إكمال الملف الشخصي في الأسفل
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Créer mon profil',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // === NEW helper ===
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyText.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
