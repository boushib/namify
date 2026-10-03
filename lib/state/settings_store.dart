import 'package:flutter/material.dart';

import '../services/storage.dart';

class SettingsStore extends ChangeNotifier {
  SettingsStore(this._storage) {
    final saved = _storage.readString('theme');
    // The old app saved "dark" or "light"
    _themeMode = ThemeMode.values.where((m) => m.name == saved).firstOrNull ?? ThemeMode.system;
    _haptics = _storage.readBool('haptics', fallback: true);
    _onboarded = _storage.readBool('onboarded');
  }

  final Storage _storage;
  late ThemeMode _themeMode;
  late bool _haptics;
  late bool _onboarded;

  ThemeMode get themeMode => _themeMode;
  bool get haptics => _haptics;
  bool get onboarded => _onboarded;

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _storage.writeString('theme', mode.name);
  }

  void finishOnboarding() {
    _onboarded = true;
    notifyListeners();
    _storage.writeBool('onboarded', true);
  }

  set haptics(bool on) {
    _haptics = on;
    notifyListeners();
    _storage.writeBool('haptics', on);
  }
}
