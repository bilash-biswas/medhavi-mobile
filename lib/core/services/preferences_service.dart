import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

class PreferencesService {
  static const String _boxName = 'app_preferences';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

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

  bool get hasSeenOnboarding {
    if (_box == null || !_box!.isOpen) return false;
    return _box!.get(_hasSeenOnboardingKey, defaultValue: false) as bool;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
    await _box!.put(_hasSeenOnboardingKey, value);
  }
}
