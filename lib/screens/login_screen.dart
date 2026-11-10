import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(User) onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _obscurePassword = true;
  bool _isRegisterMode = false; // Переключатель Вход / Регистрация
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    final login = _loginController.text;
    final pass = _passwordController.text;

    if (_isRegisterMode) {
      final newUser = await AuthService.register(login, pass);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (newUser != null) {
        widget.onLoginSuccess(newUser);
      } else {
        setState(() => _errorMessage = 'Логин занят или поля пустые');
      }
    } else {
      final user = await AuthService.login(login, pass);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        widget.onLoginSuccess(user);
      } else {
        setState(() => _errorMessage = 'Неверный логин или пароль');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade200;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)]),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.movie_filter_rounded, size: 54, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Movies Live',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegisterMode ? 'Создание нового аккаунта' : 'Войдите в свой кинозал',
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _loginController,
                  decoration: InputDecoration(
                    labelText: 'Логин',
                    hintText: _isRegisterMode ? 'Придумайте логин' : 'admin',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: fieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    hintText: _isRegisterMode ? 'Придумайте пароль' : 'admin',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: fieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      _isRegisterMode ? 'Зарегистрироваться' : 'Войти',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegisterMode = !_isRegisterMode;
                      _errorMessage = '';
                    });
                  },
                  child: Text(
                    _isRegisterMode ? 'Уже есть аккаунт? Войти' : 'Нет аккаунта? Зарегистрироваться',
                    style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
