import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

class PreferencesService {
  static const String _boxName = 'app_preferences';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _themeModeKey = 'theme_mode';
  static const String _localeKey = 'app_locale';
  static const String _targetBatchKey = 'target_batch';
  static const String _hapticEnabledKey = 'haptic_enabled';
  static const String _katexEnabledKey = 'katex_enabled';

  Box? _box;

  Future<void> init() async {
    _box ??= await Hive.openBox(_boxName);
  }

  Box get box {
    if (_box == null) {
      throw StateError('PreferencesService must be initialized before use.');
    }
    return _box!;
  }

  // Onboarding
  bool get hasSeenOnboarding {
    if (_box == null || !_box!.isOpen) return false;
    return _box!.get(_hasSeenOnboardingKey, defaultValue: false) as bool;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await _ensureBox();
    await _box!.put(_hasSeenOnboardingKey, value);
  }

  // Theme Mode ('system', 'light', 'dark')
  ThemeMode get themeMode {
    if (_box == null || !_box!.isOpen) return ThemeMode.system;
    final val = _box!.get(_themeModeKey, defaultValue: 'system') as String;
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _ensureBox();
    String val = 'system';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.dark) val = 'dark';
    await _box!.put(_themeModeKey, val);
  }

  // Locale ('bn' or 'en')
  Locale get locale {
    if (_box == null || !_box!.isOpen) return const Locale('bn');
    final val = _box!.get(_localeKey, defaultValue: 'bn') as String;
    return Locale(val);
  }

  Future<void> setLocale(String langCode) async {
    await _ensureBox();
    await _box!.put(_localeKey, langCode);
  }

  // Target BCS Batch
  String get targetBatch {
    if (_box == null || !_box!.isOpen) return '47th-bcs';
    return _box!.get(_targetBatchKey, defaultValue: '47th-bcs') as String;
  }

  Future<void> setTargetBatch(String batch) async {
    await _ensureBox();
    await _box!.put(_targetBatchKey, batch);
  }

  // Haptic feedback
  bool get hapticEnabled {
    if (_box == null || !_box!.isOpen) return true;
    return _box!.get(_hapticEnabledKey, defaultValue: true) as bool;
  }

  Future<void> setHapticEnabled(bool enabled) async {
    await _ensureBox();
    await _box!.put(_hapticEnabledKey, enabled);
  }

  // KaTeX Math Rendering
  bool get katexEnabled {
    if (_box == null || !_box!.isOpen) return true;
    return _box!.get(_katexEnabledKey, defaultValue: true) as bool;
  }

  Future<void> setKatexEnabled(bool enabled) async {
    await _ensureBox();
    await _box!.put(_katexEnabledKey, enabled);
  }

  // Clear Cache
  Future<void> clearAll() async {
    await _ensureBox();
    await _box!.clear();
  }

  Future<void> _ensureBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }
}
