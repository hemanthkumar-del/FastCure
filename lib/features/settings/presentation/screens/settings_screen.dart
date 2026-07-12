import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          // Section: General
          _buildSectionHeader(context, 'Preferences'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: settingsProvider.isDarkMode,
                  onChanged: (value) {
                    settingsProvider.toggleTheme(value);
                  },
                  secondary: Icon(Icons.dark_mode_rounded, color: theme.colorScheme.primary),
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Enable dark theme interface'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: settingsProvider.notificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.toggleNotifications(value);
                  },
                  secondary: Icon(Icons.notifications_rounded, color: theme.colorScheme.primary),
                  title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Receive alerts for appointments & reminders'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Privacy & Security
          _buildSectionHeader(context, 'Privacy & Security'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.security_rounded, color: theme.colorScheme.primary),
                  title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    // Navigate to privacy
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.verified_user_rounded, color: theme.colorScheme.primary),
                  title: const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    // Navigate to terms
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: App Info
          _buildSectionHeader(context, 'About App'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
                  title: const Text('Version', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text('1.0.0 (Build 1)', style: theme.textTheme.bodyMedium),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.support_agent_rounded, color: theme.colorScheme.primary),
                  title: const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    // Navigate to support
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
