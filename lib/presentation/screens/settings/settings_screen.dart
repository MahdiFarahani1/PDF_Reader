import 'package:flutter/material.dart';
import 'package:flutter_application_1/logic/cubits/settings/cubit/settings_cubit.dart';
import 'package:flutter_application_1/logic/cubits/settings/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../../logic/cubits/auth/auth_state.dart';
import '../auth/pin_setup_screen.dart';
import '../../../core/utils/app_icons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        children: [
          // Language Section
          _buildSectionHeader(context, loc.language),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return ListTile(
                leading: Image.asset(
                  AppIcons.languagesWorld,
                  width: 24,
                  height: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(loc.language),
                subtitle: Text(
                  state.languageCode == 'en' ? loc.english : loc.persian,
                ),
                trailing: Image.asset(
                  BlocProvider.of<SettingsCubit>(context).state.languageCode ==
                          'fa'
                      ? 'assets/icons/angle-small-left.png'
                      : 'assets/icons/angle-small-right.png',
                  width: 16,
                  height: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onTap: () => _showLanguageDialog(context),
              );
            },
          ),
          const Divider(),

          // Theme Section
          _buildSectionHeader(context, loc.theme),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text(loc.light),
                    value: ThemeMode.light,
                    groupValue: state.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsCubit>().toggleTheme(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(loc.dark),
                    value: ThemeMode.dark,
                    groupValue: state.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsCubit>().toggleTheme(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(loc.system),
                    value: ThemeMode.system,
                    groupValue: state.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsCubit>().toggleTheme(value);
                      }
                    },
                  ),
                ],
              );
            },
          ),
          const Divider(),

          // Security Section
          _buildSectionHeader(context, loc.appLock),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              return Column(
                children: [
                  ListTile(
                    leading: Image.asset(
                      AppIcons.lock,
                      width: 24,
                      height: 24,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Text(
                      authState.isPinSet ? loc.changePin : loc.setPin,
                    ),
                    trailing: Image.asset(
                      BlocProvider.of<SettingsCubit>(
                                context,
                              ).state.languageCode ==
                              'fa'
                          ? 'assets/icons/angle-small-left.png'
                          : 'assets/icons/angle-small-right.png',
                      width: 16,
                      height: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PinSetupScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const Divider(),

          // Reading Preferences
          _buildSectionHeader(context, loc.readingPreferences),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Column(
                children: [
                  SwitchListTile(
                    title: Text(loc.readingMode),
                    subtitle: Text(
                      state.isVerticalMode ? loc.vertical : loc.horizontal,
                    ),
                    value: state.isVerticalMode,
                    onChanged: (_) {
                      context.read<SettingsCubit>().toggleReadingMode();
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settingsCubit = context.read<SettingsCubit>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(loc.english),
              leading: Radio<String>(
                value: 'en',
                groupValue: settingsCubit.state.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    settingsCubit.changeLanguage(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: Text(loc.persian),
              leading: Radio<String>(
                value: 'fa',
                groupValue: settingsCubit.state.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    settingsCubit.changeLanguage(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
