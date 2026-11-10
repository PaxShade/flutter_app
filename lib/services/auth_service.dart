import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';

class AuthService {
  static Future<File> _getUsersFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/users_db.json');
  }

  // Файл для хранения текущей активной сессии
  static Future<File> _getSessionFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/current_session.json');
  }

  static Future<List<User>> getUsers() async {
    try {
      final file = await _getUsersFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList.map((e) => User.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Ошибка чтения пользователей: $e");
    }

    final defaultUsers = [
      User(id: '1', username: 'admin', password: 'admin', role: 'Администратор'),
    ];
    await _saveUsers(defaultUsers);
    return defaultUsers;
  }

  static Future<void> _saveUsers(List<User> users) async {
    try {
      final file = await _getUsersFile();
      await file.writeAsString(jsonEncode(users.map((u) => u.toJson()).toList()));
    } catch (e) {
      debugPrint("Ошибка сохранения пользователей: $e");
    }
  }

  // Сохранение активного пользователя при входе
  static Future<void> saveSession(User user) async {
    try {
      final file = await _getSessionFile();
      await file.writeAsString(jsonEncode({'userId': user.id}));
    } catch (_) {}
  }

  // Проверка сохраненной сессии при запуске приложения
  static Future<User?> getSavedUser() async {
    try {
      final file = await _getSessionFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        final savedId = data['userId'];
        if (savedId != null) {
          final users = await getUsers();
          return users.firstWhere((u) => u.id == savedId);
        }
      }
    } catch (_) {}
    return null;
  }

  // Очистка сессии при нажатии кнопки "Выйти"
  static Future<void> clearSession() async {
    try {
      final file = await _getSessionFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  static Future<User?> login(String username, String password) async {
    final users = await getUsers();
    try {
      final user = users.firstWhere(
            (u) => u.username.toLowerCase() == username.trim().toLowerCase() && u.password == password,
      );
      await saveSession(user);
      return user;
    } catch (_) {
      return null;
    }
  }

  static Future<User?> register(String username, String password) async {
    final cleanName = username.trim();
    if (cleanName.isEmpty || password.isEmpty) return null;

    final users = await getUsers();
    if (users.any((u) => u.username.toLowerCase() == cleanName.toLowerCase())) {
      return null;
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: cleanName,
      password: password,
      role: 'Киноман',
    );

    users.add(newUser);
    await _saveUsers(users);
    await saveSession(newUser);
    return newUser;
  }

  static Future<void> updateAvatar(String userId, String newAvatarUrl) async {
    final users = await getUsers();
    final index = users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      users[index].avatarUrl = newAvatarUrl;
      await _saveUsers(users);
    }
  }
}
