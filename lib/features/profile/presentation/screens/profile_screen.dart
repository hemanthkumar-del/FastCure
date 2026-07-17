import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isEditing = false;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  // Personal Information controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController(text: 'Male');
  final _dobController = TextEditingController(text: '14 May 1992');
  final _bloodGroupController = TextEditingController(text: 'O Positive (O+)');

  // Medical Information controllers
  final _heightController = TextEditingController(text: '178 cm');
  final _weightController = TextEditingController(text: '74 kg');
  final _allergiesController = TextEditingController(text: 'Penicillin, Peanuts');
  final _emergencyContactController = TextEditingController(text: '+1 (555) 019-5829');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    // Populate initial data from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        _nameController.text = user.fullName;
        if (user.phoneNumber != null) {
          _phoneController.text = user.phoneNumber!;
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _bloodGroupController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    final memberSince = user?.createdAt != null
        ? DateFormat('MMMM yyyy').format(user!.createdAt!)
        : 'July 2026';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded, color: const Color(0xFF2563EB)),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Save state action
                  _isEditing = false;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  _isEditing = true;
                }
              });
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header (User Photo, Name, Email, Member Since)
                Center(
                  child: Column(
                    children: [
                      UserAvatar(
                        photoUrl: user?.photoUrl,
                        radius: 54,
                        name: user?.fullName ?? 'U',
                        showCameraIcon: true,
                        heroTag: 'profile_picture_hero',
                        onTap: _showAvatarOptions,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.fullName ?? 'John Doe',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'johndoe@fastcure.app',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Member since: $memberSince',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Personal Information Card
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildEditableItem('Full Name', _nameController, Icons.person_outline_rounded, isDark),
                        const Divider(height: 24),
                        _buildStaticItem('Email Address', user?.email ?? 'johndoe@fastcure.app', Icons.email_outlined, isDark),
                        const Divider(height: 24),
                        _buildEditableItem('Phone Number', _phoneController, Icons.phone_outlined, isDark),
                        const Divider(height: 24),
                        _buildEditableItem('Gender', _genderController, Icons.wc_rounded, isDark),
                        const Divider(height: 24),
                        _buildEditableItem('Date of Birth', _dobController, Icons.cake_outlined, isDark),
                        const Divider(height: 24),
                        _buildEditableItem('Blood Group', _bloodGroupController, Icons.bloodtype_outlined, isDark),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Medical Information Card
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medical Profile',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildEditableItem('Height', _heightController, Icons.height_rounded, isDark),
                        const Divider(height: 24),
                        _buildEditableItem('Weight', _weightController, Icons.monitor_weight_outlined, isDark),
                        const Divider(height: 24),
                        _buildEditableItem('Allergies', _allergiesController, Icons.warning_amber_rounded, isDark),
                        const Divider(height: 24),
                        _buildEditableItem('Emergency Contact', _emergencyContactController, Icons.contact_emergency_outlined, isDark),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Settings Card
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings & Preferences',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
                          secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFF2563EB)),
                          value: _notificationsEnabled,
                          onChanged: (val) {
                            setState(() {
                              _notificationsEnabled = val;
                            });
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
                          secondary: const Icon(Icons.dark_mode_outlined, color: Color(0xFF2563EB)),
                          value: _darkModeEnabled,
                          onChanged: (val) {
                            setState(() {
                              _darkModeEnabled = val;
                            });
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Privacy Settings', style: TextStyle(fontWeight: FontWeight.w500)),
                          leading: const Icon(Icons.lock_outline_rounded, color: Color(0xFF2563EB)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Privacy settings are managed by your clinic administrator.')),
                            );
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Security & Logs', style: TextStyle(fontWeight: FontWeight.w500)),
                          leading: const Icon(Icons.security_rounded, color: Color(0xFF2563EB)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Logs and sessions are fully encrypted.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 5. Account Actions Buttons
                if (user?.email != null)
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2563EB)),
                    ),
                    child: TextButton.icon(
                      onPressed: () async {
                        final email = user!.email;
                        final success = await authProvider.sendPasswordReset(email);
                        if (success && context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Password Reset Sent'),
                              content: Text('A verification and password reset email has been dispatched to $email.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.lock_reset_rounded, color: Color(0xFF2563EB)),
                      label: const Text(
                        'Change Password',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                // Real Sign Out button
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.alertCoral),
                  ),
                  child: TextButton.icon(
                    onPressed: () async {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppColors.alertCoral),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.alertCoral,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAvatarOptions() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    final hasPhoto = user?.photoUrl != null && user!.photoUrl!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasPhoto)
                ListTile(
                  leading: const Icon(Icons.photo_outlined),
                  title: const Text('View Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PhotoViewScreen(
                          photoUrl: user.photoUrl!,
                          name: user.fullName,
                          heroTag: 'profile_picture_hero',
                        ),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadImage();
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeImage();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.close_rounded),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage() async {
    final permissionGranted = await _checkAndRequestPermission();
    if (!permissionGranted) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile == null) return;

    // Show progress overlay dialog
    _showUploadProgressDialog();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.uploadProfilePicture(pickedFile.path);

    if (mounted) {
      Navigator.of(context).pop(); // Close progress dialog
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Upload failed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUploadProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final progress = authProvider.uploadProgress ?? 0.0;
            return AlertDialog(
              title: const Text('Uploading Photo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 16),
                  Text('${(progress * 100).toInt()}% uploaded'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _checkAndRequestPermission() async {
    Permission permission = Permission.storage;
    if (Platform.isAndroid) {
      final sdkMatch = RegExp(r'SDK\s+(\d+)').firstMatch(Platform.operatingSystemVersion);
      final sdkInt = sdkMatch != null ? int.tryParse(sdkMatch.group(1) ?? '') : null;
      if (sdkInt != null && sdkInt >= 33) {
        permission = Permission.photos;
      } else {
        permission = Permission.storage;
      }
    } else {
      permission = Permission.photos;
    }

    final status = await permission.status;
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog();
      return false;
    } else {
      final requestStatus = await permission.request();
      if (requestStatus.isGranted) {
        return true;
      } else if (requestStatus.isPermanentlyDenied) {
        _showPermanentlyDeniedDialog();
        return false;
      }
      return false;
    }
  }

  void _showPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'FastCure requires access to your device gallery to select a profile picture. '
            'Please enable this permission in the application settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open App Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeImage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await authProvider.removeProfilePicture();

    if (mounted) {
      Navigator.of(context).pop(); // Close progress dialog
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to remove photo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStaticItem(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableItem(String label, TextEditingController controller, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              const SizedBox(height: 2),
              _isEditing
                  ? TextField(
                      controller: controller,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                        border: InputBorder.none,
                      ),
                    )
                  : Text(
                      controller.text.isNotEmpty ? controller.text : 'Not Specified',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
