import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool isVerticalMode;
  final String languageCode;

  const SettingsState({
    required this.themeMode,
    required this.isVerticalMode,
    required this.languageCode,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      themeMode: ThemeMode.system,
      isVerticalMode: true,
      languageCode: 'fa',
    );
  }

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? isVerticalMode,
    String? languageCode,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      isVerticalMode: isVerticalMode ?? this.isVerticalMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
