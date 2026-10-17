import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'odaamsterderm.locale';

/// Owns the app's chosen UI language: restores it from shared_preferences
/// on boot (defaulting to the device locale, falling back to English), and
/// persists it whenever the user switches language.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(null) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale?>(
        (ref) => LocaleController());
