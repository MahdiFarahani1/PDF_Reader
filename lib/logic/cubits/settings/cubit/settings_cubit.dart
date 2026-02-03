import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/core/services/storage_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final StorageService storageService;

  static const _themeKey = 'theme_mode';
  static const _readingModeKey = 'reading_mode_vertical';
  static const _languageKey = 'language_code';

  SettingsCubit(this.storageService) : super(SettingsState.initial()) {
    _loadSettings();
  }

  void _loadSettings() {
    final int? themeIndex = storageService.read(_themeKey);
    final bool isVertical = storageService.read(_readingModeKey) ?? true;
    final String language = storageService.read(_languageKey) ?? 'fa';

    emit(
      state.copyWith(
        themeMode: themeIndex != null
            ? ThemeMode.values[themeIndex]
            : ThemeMode.system,
        isVerticalMode: isVertical,
        languageCode: language,
      ),
    );
  }

  /// 🎨 تغییر تم (IconButton + RadioListTile)
  void toggleTheme(ThemeMode mode) {
    storageService.write(_themeKey, mode.index);
    emit(state.copyWith(themeMode: mode));
  }

  /// 📖 تغییر حالت خواندن
  void toggleReadingMode() {
    final newValue = !state.isVerticalMode;
    storageService.write(_readingModeKey, newValue);
    emit(state.copyWith(isVerticalMode: newValue));
  }

  /// 🌍 تغییر زبان برنامه
  void changeLanguage(String code) {
    storageService.write(_languageKey, code);
    emit(state.copyWith(languageCode: code));
  }
}
