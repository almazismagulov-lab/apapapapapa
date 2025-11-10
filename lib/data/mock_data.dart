import 'package:astana_explorer/models/achievement.dart';
import 'package:astana_explorer/models/landmark.dart';
import 'package:latlong2/latlong.dart';

final List<Landmark> allLandmarks = [
  Landmark(
    id: 'bayterek',
    name: 'Монумент "Байтерек"',
    description: 'Главный символ Астаны, олицетворяющий древо жизни.',
    category: 'architecture',
    coordinates: LatLng(51.1282, 71.4315),
    imageUrl: 'url_to_image',
    points: 100,
  ),
  Landmark(
    id: 'khan_shatyr',
    name: 'Хан Шатыр',
    description: 'Крупнейший шатёр в мире, торгово-развлекательный центр.',
    category: 'architecture',
    coordinates: LatLng(51.1330, 71.4039),
    imageUrl: 'url_to_image',
    points: 80,
  ),
  Landmark(
    id: 'hazret_sultan',
    name: 'Мечеть "Хазрет Султан"',
    description: 'Крупнейшая мечеть в Центральной Азии.',
    category: 'culture',
    coordinates: LatLng(51.1227, 71.4190),
    imageUrl: 'url_to_image',
    points: 90,
  ),
];

final List<Achievement> allAchievements = [
  Achievement(
    id: 'first_step',
    title: 'Первый шаг',
    description: 'Посетить первую достопримечательность.',
    icon: 'footprint', // Имя иконки
    pointsReward: 50,
    type: AchievementType.firstVisit,
  ),
  Achievement(
    id: 'arch_enthusiast',
    title: 'Архитектурный энтузиаст',
    description: 'Открыть 2 архитектурных объекта.',
    icon: 'building',
    pointsReward: 100,
    type: AchievementType.categoryComplete,
  ),
];