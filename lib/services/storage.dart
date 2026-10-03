import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Small JSON helpers over SharedPreferences. Bad or missing data reads as the fallback.
class Storage {
  Storage(this._prefs);
  final SharedPreferences _prefs;

  static Future<Storage> open() async => Storage(await SharedPreferences.getInstance());

  List<Object?> readList(String key) {
    try {
      final raw = _prefs.getString(key);
      final value = raw == null ? null : jsonDecode(raw);
      return value is List ? value : const [];
    } catch (_) {
      return const [];
    }
  }

  Future<void> writeList(String key, List<Object?> value) => _prefs.setString(key, jsonEncode(value));

  String? readString(String key) => _prefs.getString(key);
  List<String> readStringList(String key) => _prefs.getStringList(key) ?? const [];
  Future<void> writeString(String key, String value) => _prefs.setString(key, value);

  bool readBool(String key, {bool fallback = false}) => _prefs.getBool(key) ?? fallback;
  Future<void> writeBool(String key, bool value) => _prefs.setBool(key, value);

  int readInt(String key) => _prefs.getInt(key) ?? 0;
  Future<void> writeInt(String key, int value) => _prefs.setInt(key, value);

  Future<void> clear() => _prefs.clear();
}
