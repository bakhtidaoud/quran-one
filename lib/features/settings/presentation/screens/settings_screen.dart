import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_one/app/router/routes.dart';
import 'package:quran_one/features/auth/domain/entities/session.dart';
import 'package:quran_one/features/auth/presentation/controllers/auth_controller.dart';
import 'package:quran_one/features/settings/presentation/widgets/q_settings_section.dart';
import 'package:quran_one/features/settings/presentation/widgets/q_settings_tile.dart';

/// The settings root: a list of destinations, not a wall of controls.
///
/// Settings is a route tree rather than one long scrolling page. A single
/// page past about fifteen rows cannot be deep-linked, support cannot say
/// "open settings slash notifications", and the back gesture leaves
/// settings entirely instead of going up one level.
///
/// Every subpage renders in guest mode. Appearance, language, prayer,
/// notifications and privacy are device-tier or local-tier and need no
/// account at all.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        // Never clamps textScaler. Coding rule 13, and settings is
        // precisely where large-text users spend their time.
        padding: const EdgeInsetsDirectional.only(bottom: 32),
        children: [
          if (auth is Guest)
            const _SignInOffer()
          else
            QSettingsSection(
              title: 'Account',
              children: [
                QSettingsTile(
                  title: 'Personal information',
                  leading: const Icon(Icons.person_outline),
                  onTap: () => context.push(Routes.settingsAccount),
                ),
                QSettingsTile(
                  title: 'Connected accounts',
                  leading: const Icon(Icons.link),
                  onTap: () => context.push(Routes.settingsConnected),
                ),
                QSettingsTile(
                  title: 'Devices',
                  leading: const Icon(Icons.devices_outlined),
                  onTap: () => context.push(Routes.settingsSessions),
                ),
              ],
            ),
          QSettingsSection(
            title: 'App',
            children: [
              QSettingsTile(
                title: 'Appearance',
                // Theme lives here rather than at the top level. It is the
                // most requested top-level placement and it is wrong:
                // theme is set twice, ever, while notifications are
                // revisited constantly.
                value: 'Light',
                leading: const Icon(Icons.palette_outlined),
                onTap: () => context.push(Routes.settingsAppearance),
              ),
              QSettingsTile(
                title: 'Language',
                // Native name, never the English one. Someone who needs
                // to switch to Urdu is by definition least able to read
                // the word "Urdu" in the language they are stuck in.
                value: 'English',
                leading: const Icon(Icons.translate),
                onTap: () => context.push(Routes.settingsLanguage),
              ),
              QSettingsTile(
                title: 'Prayer times',
                leading: const Icon(Icons.schedule),
                onTap: () => context.push(Routes.settingsPrayer),
              ),
              QSettingsTile(
                title: 'Notifications',
                leading: const Icon(Icons.notifications_outlined),
                onTap: () => context.push(Routes.settingsNotifications),
              ),
              QSettingsTile(
                title: 'Accessibility',
                leading: const Icon(Icons.accessibility_new),
                onTap: () => context.push(Routes.settingsAccessibility),
              ),
            ],
          ),
          QSettingsSection(
            title: 'Privacy and data',
            footnote: 'Your location never leaves this device. What you '
                'read is never sent to us. Analytics is off unless you '
                'turn it on.',
            children: [
              QSettingsTile(
                title: 'Privacy',
                leading: const Icon(Icons.lock_outline),
                onTap: () => context.push(Routes.settingsPrivacy),
              ),
              QSettingsTile(
                title: 'Export or delete your data',
                leading: const Icon(Icons.download_outlined),
                onTap: () => context.push(Routes.settingsData),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Guest mode shows an offer, not a list of greyed-out rows.
///
/// Disabled rows that never explain themselves are worse than absent
/// ones: they advertise a locked door without saying what is behind it.
class _SignInOffer extends StatelessWidget {
  const _SignInOffer();

  @override
  Widget build(BuildContext context) {
    return QSettingsSection(
      title: 'Account',
      footnote: 'An account only adds syncing across devices. Everything '
          'else works without one.',
      children: [
        QSettingsTile(
          title: 'Sign in',
          subtitle: 'Sync bookmarks and memorisation to your other devices',
          leading: const Icon(Icons.login),
          onTap: () => context.push(Routes.login),
        ),
      ],
    );
  }
}
