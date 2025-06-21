import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hua/theme/theme_controller.dart';
import 'package:hua/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: 'JohnDoe123');
    _bioController = TextEditingController(
        text:
            'Flutter developer passionate about building beautiful apps. Love to chat and make new connections.');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
    }
  }

  void _showImagePickerOptions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
              title: Text(
                'Select from Gallery',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_camera,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
              title: Text(
                'Take a Photo',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_imageFile != null || _isEditing)
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: isDark ? AppColors.errorDark : AppColors.errorLight,
                ),
                title: Text(
                  'Remove Photo',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imageFile = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _toggleEditing() {
    setState(() {
      if (_isEditing) {
        // Save changes if form is valid
        if (_formKey.currentState!.validate()) {
          // Implement save logic here
          _isEditing = false;
          _changePassword = false;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')));
        }
      } else {
        _isEditing = true;
      }
    });
  }

  Widget _buildThemeSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Card(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      themeProvider.themeModeIcon,
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Current: ${themeProvider.themeModeText}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showThemeDialog(themeProvider);
                      },
                      child: Text(
                        'Change',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemeDialog(ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
          title: Text(
            'Select Theme',
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(
                  'Light',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                subtitle: Text(
                  'Use light theme',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                activeColor:
                    isDark ? AppColors.primaryDark : AppColors.primaryLight,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(
                  'Dark',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                subtitle: Text(
                  'Use dark theme',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                activeColor:
                    isDark ? AppColors.primaryDark : AppColors.primaryLight,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(
                  'System',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                subtitle: Text(
                  'Follow system settings',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                activeColor:
                    isDark ? AppColors.primaryDark : AppColors.primaryLight,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        shadowColor:
            (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                .withOpacity(0.1),
        title: Text(
          _isEditing ? 'Edit Profile' : 'Profile',
          style: TextStyle(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          ),
          onPressed: () {
            if (_isEditing) {
              // Show confirmation before discarding changes
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor:
                      isDark ? AppColors.cardDark : AppColors.cardLight,
                  title: Text(
                    'Discard Changes?',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  content: Text(
                    'Any unsaved changes will be lost.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        setState(() {
                          _isEditing = false;
                          _changePassword = false;
                          // Reset form fields
                          _usernameController.text = 'JohnDoe123';
                          _bioController.text =
                              'Flutter developer passionate about building beautiful apps. Love to chat and make new connections.';
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                        });
                      },
                      child: Text(
                        'DISCARD',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.errorDark
                              : AppColors.errorLight,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: _toggleEditing,
            child: Text(
              _isEditing ? 'SAVE' : 'EDIT',
              style: TextStyle(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: _isEditing ? _showImagePickerOptions : null,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: (isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight)
                            .withOpacity(0.2),
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!) as ImageProvider
                            : const AssetImage('assets/default_avatar.png'),
                        child: _imageFile == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight,
                              )
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Username field
                _buildFormField(
                  label: 'Username',
                  controller: _usernameController,
                  readOnly: !_isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username cannot be empty';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                  prefixIcon: Icons.person_outline,
                ),

                const SizedBox(height: 20),

                // Bio field
                _buildFormField(
                  label: 'Bio',
                  controller: _bioController,
                  readOnly: !_isEditing,
                  maxLines: 3,
                  maxLength: 150,
                  validator: (value) => null, // Bio is optional
                  prefixIcon: Icons.description_outlined,
                ),

                const SizedBox(height: 20),

                // Password section
                if (_isEditing) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Change Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    trailing: Switch(
                      activeColor: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      value: _changePassword,
                      onChanged: (value) {
                        setState(() {
                          _changePassword = value;
                          if (!value) {
                            // Clear password fields when toggling off
                            _currentPasswordController.clear();
                            _newPasswordController.clear();
                            _confirmPasswordController.clear();
                          }
                        });
                      },
                    ),
                  ),
                  if (_changePassword) ...[
                    const SizedBox(height: 10),

                    // Current Password field
                    _buildFormField(
                      label: 'Current Password',
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        // Add actual password validation here
                        return null;
                      },
                      prefixIcon: Icons.lock_outline,
                      toggleObscureText: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                      isObscured: _obscureCurrentPassword,
                    ),

                    const SizedBox(height: 20),

                    // New Password field
                    _buildFormField(
                      label: 'New Password',
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      prefixIcon: Icons.lock_outline,
                      toggleObscureText: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                      isObscured: _obscureNewPassword,
                    ),

                    const SizedBox(height: 20),

                    // Confirm New Password field
                    _buildFormField(
                      label: 'Confirm New Password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      prefixIcon: Icons.lock_outline,
                      toggleObscureText: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      isObscured: _obscureConfirmPassword,
                    ),
                  ],
                ],

                const SizedBox(height: 20),

                // Theme section
                _buildThemeSection(),

                const SizedBox(
                    height: 40), // Logout button (shown only in view mode)
                if (!_isEditing)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.errorDark : AppColors.errorLight,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Implement logout functionality
                        Navigator.pushReplacementNamed(context, '/loginpage');
                      },
                      child: const Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    int? maxLines = 1,
    int? maxLength,
    bool obscureText = false,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    VoidCallback? toggleObscureText,
    bool isObscured = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: readOnly
            ? (isDark ? AppColors.surfaceDark : AppColors.backgroundLight)
            : (isDark ? AppColors.inputFillDark : AppColors.inputFillLight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: readOnly
              ? Colors.transparent
              : (isDark
                  ? AppColors.inputBorderDark
                  : AppColors.inputBorderLight),
          width: 1,
        ),
        boxShadow: readOnly
            ? []
            : [
                BoxShadow(
                  color: (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)
                      .withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        maxLines: maxLines,
        maxLength: maxLength,
        style: TextStyle(
          color: readOnly
              ? (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight)
              : (isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: readOnly
                ? (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight)
                : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
          ),
          suffixIcon: toggleObscureText != null
              ? IconButton(
                  onPressed: toggleObscureText,
                  icon: Icon(
                    isObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          counterStyle: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 12,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
