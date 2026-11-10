import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<File> _getFavoritesFile(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/favorites_$userId.json');
  }

  static Future<List<String>> loadFavorites(String userId) async {
    try {
      final file = await _getFavoritesFile(userId);
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint("Ошибка чтения избранного: $e");
    }
    return [];
  }

  static Future<void> saveFavorites(String userId, List<String> favoriteIds) async {
    try {
      final file = await _getFavoritesFile(userId);
      await file.writeAsString(jsonEncode(favoriteIds));
    } catch (e) {
      debugPrint("Ошибка записи избранного: $e");
    }
  }

  // Сохранение и загрузка темы
  static Future<File> _getThemeFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/app_theme.json');
  }

  static Future<bool> loadIsDarkMode() async {
    try {
      final file = await _getThemeFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        return data['isDark'] ?? true;
      }
    } catch (_) {}
    return true; // По умолчанию темная тема
  }

  static Future<void> saveIsDarkMode(bool isDark) async {
    try {
      final file = await _getThemeFile();
      await file.writeAsString(jsonEncode({'isDark': isDark}));
    } catch (_) {}
  }
}
