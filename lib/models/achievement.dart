enum AchievementType { firstVisit, categoryComplete, streak, custom }

class Achievement {
  String id;
  String title;
  String description;
  String icon; // (для MVP можно использовать имя иконки)
  int pointsReward;
  AchievementType type;
  // bool isUnlocked; // Это состояние будет в GameProvider

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.pointsReward,
    required this.type,
  });
}