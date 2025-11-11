import 'package:astana_explorer/api_client/lib/api.dart';
import 'package:astana_explorer/screens/home_screen.dart';
import 'package:astana_explorer/services/api_service.dart'; // <-- ТЕПЕРЬ ЭТОТ ИМПОРТ СРАБОТАЕТ
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  final ApiService _apiService = ApiService.instance;
  bool _isLoading = false;
  final String _deviceId = 'test-device'; // Захардкодим для теста

  Future<void> _login() async {
    setState(() { _isLoading = true; });

    final request = LoginRequest(
      identifier: _loginController.text,
      password: _passwordController.text,
      deviceId: _deviceId,
    );

    try {
      final response = await _apiService.api.auth.postLogin(loginRequest: request); //
      
      final AuthResponse? authData = response.data;

      if (authData != null && authData.accessToken.isNotEmpty) {
        await _apiService.saveTokens(authData, _deviceId);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        throw Exception("Ответ сервера не содержит токенов");
      }

    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Неверный логин или пароль';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Произошла ошибка: ${e.toString()}'),
             backgroundColor: Colors.red,
           ),
         );
       }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

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
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(
                labelText: 'Email или Username',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true, 
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Войти'),
                ),
          ],
        ),
      ),
    );
  }
}