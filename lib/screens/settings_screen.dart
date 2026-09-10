import 'package:flutter/material.dart';

import '../screens/fitness_goals_screen.dart';
import '../services/permission_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _trackingEnabled = false;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _loadTrackingStatus();
  }

  Future<void> _loadTrackingStatus() async {
    final bool granted = await PermissionService.isTrackingPermissionGranted();

    if (!mounted) return;

    setState(() {
      _trackingEnabled = granted;
      _isCheckingPermission = false;
    });
  }

  Future<void> _toggleTracking(bool value) async {
    if (!value) {
      setState(() {
        _trackingEnabled = false;
      });
      return;
    }

    final bool granted = await PermissionService.requestTrackingPermissions();

    if (!mounted) return;

    if (granted) {
      setState(() {
        _trackingEnabled = true;
      });

      _showMessage('Tracking permissions enabled.');
    } else {
      setState(() {
        _trackingEnabled = false;
      });

      _showTrackingPermissionDialog();
    }
  }

  void _showTrackingPermissionDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(Icons.location_on_outlined, color: Color(0xFF2563EB)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Permission Required',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: const Text(
            'FitTrack needs location and physical activity permissions for real-time workout tracking, distance and steps.',
            style: TextStyle(color: Color(0xFF667085), height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await PermissionService.openSettings();
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
              ),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openFitnessGoals() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FitnessGoalsScreen()),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'FitTrack',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Ali Zain',
      children: const [
        SizedBox(height: 18),

        Text(
          'A modern fitness tracking application for monitoring activities, workouts, steps, calories and progress.',
          style: TextStyle(color: Color(0xFF667085), height: 1.45),
        ),

        SizedBox(height: 20),

        Divider(),

        SizedBox(height: 18),

        Text(
          'Developed by Ali Zain',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),

        SizedBox(height: 5),

        Text(
          'Flutter Mobile Application Developer',
          style: TextStyle(color: Color(0xFF667085), fontSize: 12),
        ),

        SizedBox(height: 14),

        Text(
          '© 2026 Ali Zain',
          style: TextStyle(
            color: Color(0xFF98A2B3),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color primaryColor = theme.colorScheme.primary;

    final Color backgroundColor = theme.scaffoldBackgroundColor;

    final Color textColor = theme.colorScheme.onSurface;

    final Color secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          _buildSectionTitle('Preferences'),

          _buildSettingsCard(
            context,
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFF7C3AED),
                title: 'Notifications',
                subtitle: 'Receive fitness reminders and updates',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });

                  _showMessage(
                    value
                        ? 'Notifications enabled.'
                        : 'Notifications disabled.',
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 22),

          _buildSectionTitle('Workout & Tracking'),

          _buildSettingsCard(
            context,
            children: [
              _isCheckingPermission
                  ? _buildLoadingTile(context)
                  : _buildSwitchTile(
                      context,
                      icon: Icons.location_on_outlined,
                      iconColor: const Color(0xFF059669),
                      title: 'Activity Tracking',
                      subtitle:
                          'Allow location and activity access for workouts',
                      value: _trackingEnabled,
                      onChanged: _toggleTracking,
                    ),

              Divider(height: 1, color: theme.dividerColor),

              _buildNavigationTile(
                context,
                icon: Icons.flag_outlined,
                iconColor: primaryColor,
                title: 'Fitness Goals',
                subtitle: 'Manage your daily fitness targets',
                onTap: _openFitnessGoals,
              ),
            ],
          ),

          const SizedBox(height: 22),

          _buildSectionTitle('Application'),

          _buildSettingsCard(
            context,
            children: [
              _buildNavigationTile(
                context,
                icon: Icons.info_outline_rounded,
                iconColor: secondaryTextColor,
                title: 'About FitTrack',
                subtitle: 'Version, developer and app details',
                onTap: _showAboutDialog,
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildPrivacyCard(context),

          const SizedBox(height: 20),

          Column(
            children: [
              Text(
                'FitTrack • v1.0.0',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Developed by Ali Zain',
                style: TextStyle(
                  color: secondaryTextColor.withValues(alpha: 0.80),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 9),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF98A2B3),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.12 : 0.025,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          _buildIconContainer(icon, iconColor),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _buildIconContainer(icon, iconColor),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),

          const SizedBox(width: 14),

          Text(
            'Checking tracking permissions...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color iconColor) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: iconColor, size: 21),
    );
  }

  Widget _buildPrivacyCard(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_outlined, color: primaryColor, size: 22),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your data stays private',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'FitTrack displays activity and fitness information for the currently logged-in user only.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
