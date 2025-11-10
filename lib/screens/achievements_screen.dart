import 'package:astana_explorer/data/mock_data.dart';
import 'package:astana_explorer/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  IconData _getIconForName(String name) {
    if (name == 'footprint') return Icons.run_circle_outlined;
    if (name == 'building') return Icons.apartment;
    return Icons.star;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return ListView.builder(
            itemCount: allAchievements.length,
            itemBuilder: (context, index) {
              final ach = allAchievements[index];
              final isUnlocked = gameProvider.isAchievementUnlocked(ach.id);

              return Opacity(
                opacity: isUnlocked ? 1.0 : 0.4,
                child: ListTile(
                  leading: Icon(
                    isUnlocked ? Icons.check_circle : _getIconForName(ach.icon),
                    color: isUnlocked ? Colors.greenAccent : Colors.grey,
                  ),
                  title: Text(ach.title),
                  subtitle: Text(ach.description),
                  trailing: isUnlocked
                      ? Text("+${ach.pointsReward} XP", style: const TextStyle(color: Colors.greenAccent))
                      : const Icon(Icons.lock_outline),
                ),
              );
            },
          );
        },
      ),
    );
  }
}