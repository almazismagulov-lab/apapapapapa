import 'package:astana_explorer/screens/home_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Контроллеры для полей ввода
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    // Получаем текст из полей
    final String login = _loginController.text;
    final String password = _passwordController.text;

    // Ваша проверка (admin / 123456)
    if (login == 'admin' && password == '123456') {
      // Если все верно, переходим на главный экран
      // Используем pushReplacement, чтобы пользователь не мог нажать "Назад"
      // и вернуться на экран входа
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Если ошибка - показываем уведомление
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Неверный логин или пароль'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Не забываем очищать контроллеры
  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Astana Explorer - Вход'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Поле для логина
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(
                labelText: 'Логин',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Поле для пароля
            TextField(
              controller: _passwordController,
              obscureText: true, // Скрывает вводимый пароль
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Кнопка "Войти"
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Кнопка во всю ширину
              ),
              child: const Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }
}