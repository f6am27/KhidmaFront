import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../models/models.dart';
import '../../../../services/profile_service.dart';
import '../../../../services/category_service.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  final CategoryService _categoryService = CategoryService();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  ClientProfile? _clientProfile;
  File? _avatarFile;

  // Form values
  String? _selectedGender;
  String? _selectedAreaName;
  List<NouakchottArea> _areas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load profile and areas in parallel
      final results = await Future.wait([
        _profileService.getClientProfile(),
        _categoryService.getNouakchottAreas(simple: true),
      ]);

      final profileResult = results[0];
      final areasResult = results[1];

      if (profileResult['ok'] == true) {
        _clientProfile = profileResult['clientProfile'] as ClientProfile;
        _populateFormFields();
      } else {
        _showError('Erreur: ${profileResult['error']}');
      }

      if (areasResult['ok'] == true) {
        _areas = areasResult['areas'] as List<NouakchottArea>;
      }
    } catch (e) {
      _showError('Erreur réseau: $e');
    }

    setState(() => _isLoading = false);
  }

  void _populateFormFields() {
    if (_clientProfile == null) return;

    _firstNameController.text = _clientProfile!.firstName ?? '';
    _lastNameController.text = _clientProfile!.lastName ?? '';
    _phoneController.text = _clientProfile!.phone;
    _emergencyContactController.text = _clientProfile!.emergencyContact ?? '';

    _selectedGender = _clientProfile!.gender;
    _selectedAreaName = _clientProfile!.address;
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
        await _loadData();
      } else {
        _showError('Erreur: ${result['error']}');
      }
    } catch (e) {
      _showError('Erreur réseau: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final result = await _profileService.updateClientProfile(
        firstName: _firstNameController.text.trim().isEmpty
            ? null
            : _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        address: _selectedAreaName,
        gender: _selectedGender,
        emergencyContact: _emergencyContactController.text.trim().isEmpty
            ? null
            : _emergencyContactController.text.trim(),
      );

      if (result['ok'] == true) {
        _showSuccess('Profil mis à jour avec succès');
        Navigator.pop(context, true);
      } else {
        if (result['needsLogin'] == true) {
          _showError('Veuillez vous reconnecter');
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
                    'Chargement...',
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
                    children: [
                      SizedBox(height: 20),
                      _buildProfilePhoto(context, isDark),
                      SizedBox(height: 40),
                      _buildFormFields(context, isDark),
                      SizedBox(height: 40),
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
                : (_clientProfile?.profileImageUrl != null
                    ? NetworkImage(_clientProfile!.profileImageUrl!)
                    : null) as ImageProvider?,
            child:
                (_avatarFile == null && _clientProfile?.profileImageUrl == null)
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
                child: Icon(Icons.edit, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, 'Prénom'),
        SizedBox(height: 8),
        _buildTextField(
          controller: _firstNameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le prénom est requis';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        _buildFieldLabel(context, 'Nom de famille'),
        SizedBox(height: 8),
        _buildTextField(controller: _lastNameController),
        SizedBox(height: 20),
        _buildFieldLabel(context, 'Numéro de téléphone'),
        SizedBox(height: 8),
        _buildPhoneField(),
        SizedBox(height: 20),
        _buildFieldLabel(context, 'Adresse (Zone)'),
        SizedBox(height: 8),
        _buildAreaDropdown(isDark),
        SizedBox(height: 20),
        _buildFieldLabel(context, 'Genre'),
        SizedBox(height: 8),
        _buildGenderDropdown(isDark),
        SizedBox(height: 20),
        _buildFieldLabel(context, 'Contact d\'urgence'),
        SizedBox(height: 8),
        _buildTextField(
          controller: _emergencyContactController,
          keyboardType: TextInputType.phone,
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
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
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
          borderSide: BorderSide(color: ThemeColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ThemeColors.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ThemeColors.errorColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: Theme.of(context).textTheme.bodyLarge,
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.lock_outline, color: Colors.grey, size: 20),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildGenderDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: [
        DropdownMenuItem(value: 'male', child: Text('Homme')),
        DropdownMenuItem(value: 'female', child: Text('Femme')),
      ],
      onChanged: (value) => setState(() => _selectedGender = value),
    );
  }

  Widget _buildAreaDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedAreaName,
      decoration: InputDecoration(
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      hint: Text('Sélectionner une zone'),
      items: _areas
          .map((area) => DropdownMenuItem(
                value: area.name,
                child: Text(area.name),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedAreaName = value),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
                  Text('Mise à jour...',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              )
            : Text('Mettre à jour',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
