import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:micro_emploi_app/constants/colors.dart';
import 'package:micro_emploi_app/constants/text_styles.dart';
import 'package:micro_emploi_app/routes/app_routes.dart';
import '../../services/auth_api.dart'; // <<< ADD

class WorkerOnboardingScreen extends StatefulWidget {
  @override
  State<WorkerOnboardingScreen> createState() => _WorkerOnboardingScreenState();
}

class _WorkerOnboardingScreenState extends State<WorkerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  // البيانات
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

  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descController = TextEditingController();

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
  void dispose() {
    _priceController.dispose();
    _areaController.dispose();
    _descController.dispose();
    super.dispose();
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

  // <<< REPLACE: اجعلها async واستدعِ API إكمال الـOnboarding
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une catégorie')),
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

    // TODO: في المرحلة (ج) سنرسل بقية بيانات البروفايل (avatar/category/price/days/time/area/desc)

    // ضبط onboarding_completed=True في الخادم
    final r = await AuthApi().completeWorkerOnboarding();
    if (r['ok'] != true) {
      final err =
          (r['json']?['detail'] ?? 'Échec de la finalisation').toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return; // لا ننتقل للـHome إذا فشل الضبط
    }

    // نجاح: الذهاب إلى Home كعامل
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
      arguments: {'role': 'worker'}, // مهم: نمرر worker
    );
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
      body: Column(
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
                              border: Border.all(color: Colors.white, width: 2),
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
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories
                            .map((c) => DropdownMenuItem<String>(
                                value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v),
                        decoration: _dec('Sélectionner'),
                        style: AppTextStyles.bodyText,
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
                        keyboardType: const TextInputType.numberWithOptions(
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
                        children: _days.map((d) {
                          final selected = _selectedDays.contains(d);
                          return FilterChip(
                            label: Text(d),
                            selected: selected,
                            onSelected: (s) => setState(() {
                              s
                                  ? _selectedDays.add(d)
                                  : _selectedDays.remove(d);
                            }),
                            showCheckmark: false,
                            selectedColor:
                                AppColors.primaryPurple.withOpacity(.12),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
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
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.schedule_outlined,
                                  color: AppColors.mediumGray),
                              const SizedBox(width: 12),
                              Text(
                                'Heure de début',
                                style: AppTextStyles.bodyText
                                    .copyWith(color: AppColors.mediumGray),
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
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.schedule_outlined,
                                  color: AppColors.mediumGray),
                              const SizedBox(width: 12),
                              Text(
                                'Heure de fin',
                                style: AppTextStyles.bodyText
                                    .copyWith(color: AppColors.mediumGray),
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

                      // Zone d'intervention
                      Text(
                        'Zone d\'intervention',
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _areaController,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Veuillez entrer la zone de service';
                          }
                          return null;
                        },
                        decoration: _dec('Ville / Quartier'),
                        style: AppTextStyles.bodyText,
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
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Compléter le profil',
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
}
