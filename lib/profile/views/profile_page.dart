import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF3F51B5)),
              title: const Text('Select from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF3F51B5)),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_imageFile != null || _isEditing)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        title: Text(
          _isEditing ? 'Edit Profile' : 'Profile',
          style: const TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3F51B5)),
          onPressed: () {
            if (_isEditing) {
              // Show confirmation before discarding changes
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Discard Changes?'),
                  content: const Text('Any unsaved changes will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
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
                      child: const Text('DISCARD'),
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
              style: const TextStyle(
                color: Color(0xFF3F51B5),
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
                        backgroundColor:
                            const Color(0xFF3F51B5).withOpacity(0.2),
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!) as ImageProvider
                            : const AssetImage('assets/default_avatar.png'),
                        child: _imageFile == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFF3F51B5),
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
                            decoration: const BoxDecoration(
                              color: Color(0xFF3F51B5),
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
                    title: const Text(
                      'Change Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Switch(
                      activeColor: const Color(0xFF3F51B5),
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

                const SizedBox(height: 40),

                // Logout button (shown only in view mode)
                if (!_isEditing)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
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
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: readOnly ? Colors.transparent : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: readOnly
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
          color: readOnly ? Colors.grey.shade700 : Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: readOnly ? Colors.grey.shade500 : const Color(0xFF3F51B5),
          ),
          suffixIcon: toggleObscureText != null
              ? IconButton(
                  onPressed: toggleObscureText,
                  icon: Icon(
                    isObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade600,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          counterStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
