import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _profileBoxName = 'fittrack_profile_box';

  final ImagePicker _imagePicker = ImagePicker();

  AppUser? _user;
  String? _profileImagePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await Hive.openBox(_profileBoxName);

    final AppUser? currentUser = AuthService.getCurrentUser();

    if (currentUser == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _user = null;
        _isLoading = false;
      });

      return;
    }

    final Box box = Hive.box(_profileBoxName);

    final dynamic savedPath = box.get(_profileKey(currentUser.id));

    if (!mounted) {
      return;
    }

    setState(() {
      _user = currentUser;
      _profileImagePath = savedPath?.toString();
      _isLoading = false;
    });
  }

  String _profileKey(String userId) {
    return 'profile_image_$userId';
  }

  Future<void> _pickProfileImage() async {
    final AppUser? user = _user;

    if (user == null) {
      return;
    }

    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedImage == null) {
        return;
      }

      final Box box = Hive.box(_profileBoxName);

      await box.put(_profileKey(user.id), pickedImage.path);

      if (!mounted) {
        return;
      }

      setState(() {
        _profileImagePath = pickedImage.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select profile photo.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeProfileImage() async {
    final AppUser? user = _user;

    if (user == null) {
      return;
    }

    final Box box = Hive.box(_profileBoxName);

    await box.delete(_profileKey(user.id));

    if (!mounted) {
      return;
    }

    setState(() {
      _profileImagePath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile photo removed.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPhotoOptions() {
    if (_profileImagePath == null) {
      _pickProfileImage();
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Change Photo'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();

                    _pickProfileImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();

                    _removeProfileImage();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    final String? imagePath = _profileImagePath;

    final bool imageExists =
        imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: imageExists
                ? Image.file(File(imagePath), fit: BoxFit.cover)
                : Container(
                    color: Colors.white.withValues(alpha: 0.18),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 58,
                    ),
                  ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: 0,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              onTap: _showPhotoOptions,
              customBorder: const CircleBorder(),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF526DFF),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF526DFF).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xFF526DFF), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF172033),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final AppUser? user = _user;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: const Center(child: Text('No logged-in user found.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF526DFF), Color(0xFF7B61FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              child: Column(
                children: [
                  _buildProfileAvatar(),

                  const SizedBox(height: 18),

                  Text(
                    user.name.isEmpty ? 'User' : user.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton.icon(
                    onPressed: _showPhotoOptions,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: const Text('Change Profile Photo'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account Information',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172033),
                ),
              ),
            ),

            const SizedBox(height: 14),

            _buildInfoCard(
              icon: Icons.person_outline_rounded,
              title: 'Full Name',
              value: user.name,
            ),

            _buildInfoCard(
              icon: Icons.email_outlined,
              title: 'Email Address',
              value: user.email,
            ),

            _buildInfoCard(
              icon: Icons.fingerprint_rounded,
              title: 'User ID',
              value: user.id,
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF7F1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF2E8B57),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Account Security',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F5E3B),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Your fitness data is linked to your account and is kept separate from other users.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: Color(0xFF4A6B58),
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
      ),
    );
  }
}
