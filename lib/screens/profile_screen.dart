import 'package:astana_explorer/data/mock_data.dart';
import 'package:astana_explorer/providers/game_provider.dart';
import 'package:astana_explorer/screens/login_screen.dart'; // <-- ИМПОРТ ЭКРАНА ВХОДА
import 'package:astana_explorer/services/api_service.dart'; // <-- ИМПОРТ API СЕРВИСА
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await ApiService.instance.logout();
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Ошибка при выходе: ${e.toString()}'))
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль Игрока'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () => _logout(context), // Вызываем нашу функцию
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          
          // ВНИМАНИЕ: Эти данные все еще "фейковые" из mock_data.dart
          // Вам нужно будет обновить GameProvider, чтобы он брал их из API
          final int currentLevel = gameProvider.level;
          final int currentPoints = gameProvider.points;
          final int pointsForThisLevel = (currentLevel - 1) * 500;
          final int pointsForNextLevel = currentLevel * 500;
          final double levelProgress = (currentPoints - pointsForThisLevel) / (pointsForNextLevel - pointsForThisLevel);
          final int totalLandmarks = allLandmarks.length;
          final int discoveredLandmarks = gameProvider.discoveredLandmarksCount;
      

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Text(
                      currentLevel.toString(),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Исследователь', // (Ваш титул)
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 24),
                
                Text("Прогресс до Уровня ${currentLevel + 1}", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: levelProgress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 8),
                Text("$currentPoints / $pointsForNextLevel XP"),
                
                const Divider(height: 40),

                Text("Статистика", style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Text(
                  "Открыто достопримечательностей: $discoveredLandmarks / $totalLandmarks",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  "Получено достижений: ${gameProvider.unlockedAchievementIds.length} / ${allAchievements.length}",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}