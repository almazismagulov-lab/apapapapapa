import 'package:astana_explorer/screens/login_screen.dart';
import 'package:astana_explorer/providers/game_provider.dart';
import 'package:astana_explorer/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Убедимся, что все биндинги инициализированы до запуска
  WidgetsFlutterBinding.ensureInitialized();
  
  // Создаем экземпляр провайдера
  final gameProvider = GameProvider();
  
  // Загружаем сохраненный прогресс ДО того, как приложflutter runение запустится
  await gameProvider.loadProgress();

  runApp(
    // Внедряем провайдер в дерево виджетов
    ChangeNotifierProvider(
      create: (context) => gameProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astana Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // --- ИСПРАВЛЕНИЕ ЗДЕСЬ ---
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark, // <-- ДОБАВЬТЕ ЭТУ СТРОКУ
        ),
        // --------------------------
        useMaterial3: true,
        // (Вам больше не нужен `brightness: Brightness.dark,` здесь,
        // так как он будет взят из colorScheme, но можно и оставить)
      ),
      home: const LoginScreen(),
    );
  }
}