import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(preferencesServiceProvider);
    return prefs.locale;
  }

  Future<void> setLocale(String langCode) async {
    state = Locale(langCode);
    final prefs = ref.read(preferencesServiceProvider);
    await prefs.setLocale(langCode);
  }

  Future<void> toggleLocale() async {
    final newLang = state.languageCode == 'bn' ? 'en' : 'bn';
    await setLocale(newLang);
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);
