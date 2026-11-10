import 'package:flutter/material.dart';
import '../models/user.dart';

class AccountScreen extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;
  final int favoritesCount;
  final bool isDarkMode;
  final Function(bool) onThemeChanged;
  final Function(String) onAvatarChanged;

  const AccountScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.favoritesCount,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onAvatarChanged,
  });

  void _showAvatarDialog(BuildContext context) {
    final urlController = TextEditingController(text: user.avatarUrl);
    // Предустановленные красивые аватарки для быстрого выбора в один клик
    final presetAvatars = [
      'https://img.magnific.com/premium-psd/3d-avatar-character_975163-707.jpg?semt=ais_hybrid&w=740',
      'https://img.magnific.com/premium-psd/3d-avatar-character_975163-673.jpg?semt=ais_test_b&w=740&q=80',
      'https://public.bnbstatic.com/image/pgc/202511/787c7a444ceba74b07be43244546fa4f.png',
      'https://i.pinimg.com/736x/a8/db/05/a8db051510897ed1426d9ea20a70b269.jpg',
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Установить аватарку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Выберите готовую:', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: presetAvatars.map((url) {
                return GestureDetector(
                  onTap: () {
                    onAvatarChanged(url);
                    Navigator.pop(ctx);
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(url),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            const Text('Или вставьте ссылку (URL):', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'https://...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              onAvatarChanged(urlController.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Аватарка с кнопкой редактирования
            GestureDetector(
              onTap: () => _showAvatarDialog(context),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFFFF4081)]),
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: const Color(0xFF1E1E2C),
                      backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                      child: user.avatarUrl.isEmpty
                          ? const Icon(Icons.person_rounded, size: 54, color: Colors.white)
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFF7C4DFF), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(user.username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user.role, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),

            // Статистика
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        favoritesCount.toString(),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF4081)),
                      ),
                      const SizedBox(height: 4),
                      const Text('В избранном', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
                  Column(
                    children: [
                      Text(
                        user.id,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF)),
                      ),
                      const SizedBox(height: 4),
                      const Text('ID аккаунта', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Переключатель светлой / темной темы
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10),
                ],
              ),
              child: SwitchListTile(
                title: const Text('Темная тема', style: TextStyle(fontWeight: FontWeight.w600)),
                secondary: Icon(
                  isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: const Color(0xFF7C4DFF),
                ),
                value: isDarkMode,
                activeThumbColor: const Color(0xFF7C4DFF),
                onChanged: onThemeChanged,
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Выйти из аккаунта', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
