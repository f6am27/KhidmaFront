import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Votre Profil'),
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
              children: [
                SizedBox(height: 20),

                // Photo de profil
                _buildProfilePhoto(context, isDark),
                SizedBox(height: 40),

                // Formulaire
                _buildFormFields(context, isDark),
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
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: isDark ? ThemeColors.darkSurface : Colors.grey[200],
          child: Icon(
            Icons.person,
            size: 70,
            color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _showImageSourceDialog(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ThemeColors.primaryColor, // تغيير اللون للبنفسجي
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
    );
  }

  Widget _buildFormFields(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom
        _buildFieldLabel(context, 'Nom'),
        SizedBox(height: 8),
        _buildTextField(
          controller: _nameController,
          hintText: 'Entrez votre nom',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le nom est requis';
            }
            return null;
          },
        ),
        SizedBox(height: 24),

        // Numéro de téléphone
        _buildFieldLabel(context, 'Numéro de téléphone'),
        SizedBox(height: 8),
        _buildPhoneField(),
        SizedBox(height: 24),

        // Email
        _buildFieldLabel(context, 'Email'),
        SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          hintText: 'Entrez votre email',
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
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        // hintText: hintText, // تم حذف الـ placeholder
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? ThemeColors.darkSurface : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // زيادة الـ radius
          borderSide: BorderSide(
            color: isDark ? ThemeColors.darkBorder : ThemeColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // زيادة الـ radius
          borderSide: BorderSide(
            color: isDark ? ThemeColors.darkBorder : ThemeColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // زيادة الـ radius
          borderSide: BorderSide(
            color: ThemeColors.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // زيادة الـ radius
          borderSide: BorderSide(
            color: ThemeColors.errorColor,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // زيادة الـ radius
          borderSide: BorderSide(
            color: ThemeColors.errorColor,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
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
      decoration: InputDecoration(
        // hintText: 'Entrez votre numéro', // تم حذف الـ placeholder
        suffixIcon: TextButton(
          onPressed: () {
            // Action pour changer le numéro
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
        filled: true,
        fillColor: isDark ? ThemeColors.darkSurface : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // زيادة الـ radius
          borderSide: BorderSide(
            color: isDark ? ThemeColors.darkBorder : ThemeColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // زيادة الـ radius
          borderSide: BorderSide(
            color: isDark ? ThemeColors.darkBorder : ThemeColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // زيادة الـ radius
          borderSide: BorderSide(
            color: ThemeColors.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // زيادة الـ radius
          borderSide: BorderSide(
            color: ThemeColors.errorColor,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // زيادة الـ radius
          borderSide: BorderSide(
            color: ThemeColors.errorColor,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColors.primaryColor, // تغيير اللون للبنفسجي
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          'Mettre à jour',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? ThemeColors.darkCardBackground : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Changer la photo de profil',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.camera_alt,
                    label: 'Caméra',
                    onTap: () {
                      Navigator.pop(context);
                      _takePhoto();
                    },
                  ),
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.photo_library,
                    label: 'Galerie',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ThemeColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: ThemeColors.primaryColor,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      // Logique de mise à jour du profil
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

      // Retourner à l'écran précédent
      Navigator.pop(context);
    }
  }

  void _takePhoto() {
    // Logique pour prendre une photo avec la caméra
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fonctionnalité de caméra en cours de développement'),
        backgroundColor: ThemeColors.primaryColor,
      ),
    );
  }

  void _pickImage() {
    // Logique pour choisir une image de la galerie
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fonctionnalité de galerie en cours de développement'),
        backgroundColor: ThemeColors.primaryColor,
      ),
    );
  }
}
