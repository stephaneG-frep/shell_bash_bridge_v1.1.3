import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress.dart';
import '../models/note.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static const String _progressKey = 'user_progress';
  static const String _notesKey = 'user_notes';
  static const String _themeKey = 'theme_mode';
  static const String _textSizeKey = 'text_size';
  static const String _codeSizeKey = 'code_size';
  static const String _guideSeenKey = 'guide_seen';
  static const String _labKey = 'lab_state';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveProgress(UserProgress progress) async {
    await _prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  static UserProgress loadProgress() {
    final data = _prefs.getString(_progressKey);
    if (data == null) return const UserProgress();
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return UserProgress.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('StorageService: progression illisible, ignorée ($e)');
    }
    // Donnée corrompue : on la met de côté au lieu de faire planter l'app.
    _prefs.setString('${_progressKey}_corrupt', data);
    return const UserProgress();
  }

  static Future<void> saveNotes(List<Note> notes) async {
    final jsonList = notes.map((n) => n.toJson()).toList();
    await _prefs.setString(_notesKey, jsonEncode(jsonList));
  }

  static List<Note> loadNotes() {
    final data = _prefs.getString(_notesKey);
    if (data == null) return [];
    try {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        final notes = <Note>[];
        for (final n in decoded) {
          // Une note invalide est ignorée sans perdre les autres.
          if (n is! Map<String, dynamic>) continue;
          try {
            notes.add(Note.fromJson(n));
          } catch (e) {
            debugPrint('StorageService: note illisible, ignorée ($e)');
          }
        }
        return notes;
      }
    } catch (e) {
      debugPrint('StorageService: notes illisibles, ignorées ($e)');
    }
    _prefs.setString('${_notesKey}_corrupt', data);
    return [];
  }

  static Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeKey, mode);
  }

  static String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  static Future<void> setTextSize(double size) async {
    await _prefs.setDouble(_textSizeKey, size);
  }

  static double getTextSize() {
    return _prefs.getDouble(_textSizeKey) ?? 14.0;
  }

  static Future<void> setCodeSize(double size) async {
    await _prefs.setDouble(_codeSizeKey, size);
  }

  static double getCodeSize() {
    return _prefs.getDouble(_codeSizeKey) ?? 13.0;
  }

  static Future<void> setGuideSeen(bool seen) async {
    await _prefs.setBool(_guideSeenKey, seen);
  }

  static bool isGuideSeen() {
    return _prefs.getBool(_guideSeenKey) ?? false;
  }

  static Future<void> saveLabState(Map<String, dynamic> state) async {
    await _prefs.setString(_labKey, jsonEncode(state));
  }

  static Map<String, dynamic>? loadLabState() {
    final data = _prefs.getString(_labKey);
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (e) {
      debugPrint('StorageService: état du Lab illisible, ignoré ($e)');
    }
    return null;
  }

  static Future<void> clearLabState() async {
    await _prefs.remove(_labKey);
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
