import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../screens/all_goals_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/help_support_screen.dart';
import '../screens/contact_us_screen.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  static const String _profileBoxName = 'fittrack_profile_box';

  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final currentUser = AuthService.getCurrentUser();

    if (currentUser == null) {
      return;
    }

    try {
      if (!Hive.isBoxOpen(_profileBoxName)) {
        await Hive.openBox(_profileBoxName);
      }

      final Box box = Hive.box(_profileBoxName);

      final dynamic imagePath = box.get('profile_image_${currentUser.id}');

      if (!mounted) {
        return;
      }

      setState(() {
        _profileImagePath = imagePath?.toString();
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _profileImagePath = null;
      });
    }
  }

  bool get _hasProfileImage {
    if (_profileImagePath == null || _profileImagePath!.trim().isEmpty) {
      return false;
    }

    return File(_profileImagePath!).existsSync();
  }

  // ==================================================
  // NAVIGATION
  // ==================================================

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    ).then((_) {
      _loadProfileImage();
    });
  }

  void _openAllGoals() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AllGoalsScreen()),
    );
  }

  void _openStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StatisticsScreen()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _openHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
    );
  }

  void _openContactUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactUsScreen()),
    );
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.getCurrentUser();

    final ThemeData theme = Theme.of(context);

    final Color primaryColor = theme.colorScheme.primary;

    final Color textColor = theme.colorScheme.onSurface;

    final Color secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    final Color surfaceColor = theme.colorScheme.surface;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.86,

      backgroundColor: theme.scaffoldBackgroundColor,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),

      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(currentUser),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                children: [
                  _buildSectionTitle('Account'),

                  _buildDrawerItem(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: 'Profile',
                    onTap: _openProfile,
                  ),

                  const SizedBox(height: 8),

                  _buildSectionTitle('Fitness'),

                  _buildDrawerItem(
                    context,
                    icon: Icons.flag_outlined,
                    title: 'All Goals',
                    onTap: _openAllGoals,
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.insights_outlined,
                    title: 'Statistics',
                    onTap: _openStatistics,
                  ),

                  const SizedBox(height: 8),

                  _buildSectionTitle('App'),

                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: _openSettings,
                  ),

                  _buildThemeItem(
                    context,
                    primaryColor,
                    textColor,
                    secondaryTextColor,
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    onTap: _openHelpSupport,
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.contact_mail_outlined,
                    title: 'Contact Us',
                    onTap: _openContactUs,
                  ),
                ],
              ),
            ),

            _buildLogoutSection(context, surfaceColor),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // HEADER
  // ==================================================

  Widget _buildHeader(dynamic currentUser) {
    final String name = currentUser?.name ?? 'FitTrack User';

    final String email = currentUser?.email ?? 'No email available';

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileAvatar(),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'FitTrack',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // PROFILE AVATAR
  // ==================================================

  Widget _buildProfileAvatar() {
    return Container(
      width: 72,
      height: 72,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 2,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: ClipOval(
        child: _hasProfileImage
            ? Image.file(
                File(_profileImagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _defaultAvatar();
                },
              )
            : _defaultAvatar(),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: Colors.white.withValues(alpha: 0.17),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 38),
    );
  }

  // ==================================================
  // SECTION TITLE
  // ==================================================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF98A2B3),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
        ),
      ),
    );
  }

  // ==================================================
  // NORMAL DRAWER ITEM
  // ==================================================

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final ThemeData theme = Theme.of(context);

    final Color primaryColor = theme.colorScheme.primary;

    final Color textColor = theme.colorScheme.onSurface;

    final Color secondaryColor = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.14
                          : 0.09,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 22, color: primaryColor),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: secondaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================================================
  // DARK MODE ITEM
  // ==================================================

  Widget _buildThemeItem(
    BuildContext context,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primaryColor.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.14
                      : 0.09,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                ThemeService.darkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: 22,
                color: primaryColor,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ThemeService.darkMode ? 'On' : 'Off',
                    style: TextStyle(color: secondaryTextColor, fontSize: 10),
                  ),
                ],
              ),
            ),

            ValueListenableBuilder<bool>(
              valueListenable: ThemeService.isDarkMode,
              builder: (context, isDarkMode, child) {
                return Switch.adaptive(
                  value: isDarkMode,
                  onChanged: (value) async {
                    await ThemeService.setDarkMode(value);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // LOGOUT
  // ==================================================

  Widget _buildLogoutSection(BuildContext context, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 14),

      decoration: BoxDecoration(
        color: surfaceColor,

        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),

      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _confirmLogout(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDC2626),
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFDC2626),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await AuthService.logout();

    if (!context.mounted) {
      return;
    }

    Navigator.pop(context);

    widget.onLogout();
  }
}
