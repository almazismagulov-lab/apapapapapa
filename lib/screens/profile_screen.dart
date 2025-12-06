import 'package:astana_explorer/data/mock_data.dart';
import 'package:astana_explorer/providers/game_provider.dart';
import 'package:astana_explorer/screens/login_screen.dart'; 
import 'package:astana_explorer/services/api_service.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 1. ИМПОРТИРУЕМ ПАКЕТ АВАТАРОК
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      // Вызываем новый метод через Provider
      await Provider.of<GameProvider>(context, listen: false).logoutAndClear();
      
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
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          
          // --- 2. ЭТИ ДАННЫЕ ТЕПЕРЬ БЕРУТСЯ ИЗ API ---
          final int currentLevel = gameProvider.level;
          final int currentPoints = gameProvider.points;
          final String username = gameProvider.username;
          final String? avatarUrl = gameProvider.avatarUrl;
          // ------------------------------------------

          // (Эта логика все еще фейковая, т.к. allLandmarks - локальные)
          // TODO: Заменить '500' на LevelCalculator.GetRequiredExperience(user.Level) из бэкенда
          final int pointsForThisLevel = (currentLevel - 1) * 100; // Используем 100, как в бэкенде
          final int pointsForNextLevel = currentLevel * 100;      // Используем 100, как в бэкенде
          final double levelProgress = (currentPoints - pointsForThisLevel) / (pointsForNextLevel - pointsForThisLevel);
          final int totalLandmarks = allLandmarks.length; // TODO: Заменить на реальное кол-во
          final int discoveredLandmarks = gameProvider.discoveredLandmarksCount; // TODO: Заменить на реальное кол-во
      

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  // --- 3. ОБНОВЛЕННЫЙ АВАТАР ---
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.teal.shade800,
                    // Используем ClipOval, чтобы обрезать виджет
                    child: ClipOval(
                      child: avatarUrl != null
                          ? CachedNetworkImage(
                              imageUrl: avatarUrl,
                              fit: BoxFit.cover, // Растягиваем, чтобы заполнить круг
                              width: 100, // (radius * 2)
                              height: 100, // (radius * 2)
                              
                              // Виджет во время загрузки
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              
                              // Виджет, если произошла ошибка
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error, // Иконка ошибки
                                size: 50,
                                color: Colors.white,
                              ),
                            )
                          : const Icon( // Если URL == null
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  // -----------------------------
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    username, // <-- 4. ИСПОЛЬЗУЕМ РЕАЛЬНОЕ ИМЯ
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Прогресс Уровня
                Text("Прогресс до Уровня ${currentLevel + 1}", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: levelProgress.isNaN ? 0.0 : levelProgress, // Защита от деления на ноль
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 8),
                // Отображаем реальный опыт
                Text("$currentPoints XP"), 
                
                const Divider(height: 40),

                // Статистика (все еще частично фейковая)
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