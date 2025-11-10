import 'package:astana_explorer/data/mock_data.dart';
import 'package:astana_explorer/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль Игрока'),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          
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
                
                // Прогресс Уровня
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

                // Статистика
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