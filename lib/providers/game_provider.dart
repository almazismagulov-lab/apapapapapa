import 'dart:async';
import 'package:astana_explorer/data/mock_data.dart';
import 'package:astana_explorer/models/landmark.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameProvider with ChangeNotifier {
  // -- КОНСТАНТЫ --
  static const double detectionRadius = 200; // 200 метров

  // -- СОСТОЯНИЕ ИГРЫ --
  int _points = 0;
  Set<String> _discoveredLandmarkIds = {};
  Set<String> _unlockedAchievementIds = {};
  
  // -- СОСТОЯНИЕ КАРТЫ И GPS --
  Position? _currentPosition;
  bool _isLoading = true;
  StreamSubscription<Position>? _positionStream;
  final Distance _distance = const Distance();

  // -- ГЕТТЕРЫ (для доступа из UI) --
  int get points => _points;
  int get level => (_points / 500).floor() + 1; // 500 очков = 1 уровень
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  Set<String> get discoveredLandmarkIds => _discoveredLandmarkIds;

  // Геттер для "тумана войны" - возвращает центры открытых зон
  List<LatLng> get discoveredHoleCenters {
    return _discoveredLandmarkIds.map((id) {
      return allLandmarks.firstWhere((lm) => lm.id == id).coordinates;
    }).toList();
  }

  // Методы проверки
  bool isLandmarkDiscovered(String id) => _discoveredLandmarkIds.contains(id);
  bool isAchievementUnlocked(String id) => _unlockedAchievementIds.contains(id);
  int get discoveredLandmarksCount => _discoveredLandmarkIds.length;
  
  // <--- ВОТ ИСПРАВЛЕНИЕ: Мы делаем _unlockedAchievementIds "публичным"
  Set<String> get unlockedAchievementIds => _unlockedAchievementIds;

  // -- ИНИЦИАЛИЗАЦИЯ --
  GameProvider() {
    // Вызывается при создании провайдера
    _init();
  }

  Future<void> _init() async {
    await _checkPermissions();
    startLocationTracking();
    // Загрузка уже вызвана в main.dart
    // await loadProgress();
  }

  // -- ЛОГИКА GPS --
  Future<void> _checkPermissions() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }
  Future<void> manuallyRefreshPosition() async {
    // Показываем индикатор загрузки на карте
    _isLoading = true;
    notifyListeners();

    try {
      // Запрашиваем одну позицию с высокой точностью
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _currentPosition = position;
      print("Ручное обновление позиции: $position");
      
      // Проверяем, не открыли ли мы что-то
      _checkDiscoveredLandmarks(position);

    } catch (e) {
      print("Ошибка при ручном обновлении позиции: $e");
      // Если у пользователя выключен GPS, он получит ошибку здесь
      // Можно показать SnackBar с ошибкой
    }

    // Убираем индикатор загрузки
    _isLoading = false;
    notifyListeners();
  }
  // 👆 --- КОНЕЦ НОВОЙ ФУНКЦИИ --- 👆

  void startLocationTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20, // Обновлять каждые 20 метров
      ),
    ).listen((Position position) {
      _currentPosition = position;
      print("Новая позиция: $position");
      _checkDiscoveredLandmarks(position);
      notifyListeners(); // Уведомить UI о новой позиции
    });
  }

  // -- ЛОГИКА ИГРЫ (ОБНАРУЖЕНИЕ) --
  void _checkDiscoveredLandmarks(Position position) {
    final userLocation = LatLng(position.latitude, position.longitude);

    for (final landmark in allLandmarks) {
      if (!isLandmarkDiscovered(landmark.id)) {
        final double dist = _distance.as(
          LengthUnit.Meter,
          userLocation,
          landmark.coordinates,
        );

        if (dist <= detectionRadius) {
          _discoverLandmark(landmark);
        }
      }
    }
  }

  void _discoverLandmark(Landmark landmark) {
    _discoveredLandmarkIds.add(landmark.id);
    _points += landmark.points;

    print("ОТКРЫТО: ${landmark.name}");
    // TODO: Показать локальное уведомление
    
    _checkAchievements(landmark);
    _saveProgress();
    notifyListeners(); // Уведомить UI о новом открытии
  }

  void _checkAchievements(Landmark discoveredLandmark) {
    // "Первый шаг"
    if (_discoveredLandmarkIds.length == 1 && !isAchievementUnlocked('first_step')) {
      _unlockAchievement('first_step');
    }

    // "Архитектурный энтузиаст"
    int archCount = _discoveredLandmarkIds.where((id) {
      final lm = allLandmarks.firstWhere((lm) => lm.id == id);
      return lm.category == 'architecture';
    }).length;

    if (archCount >= 2 && !isAchievementUnlocked('arch_enthusiast')) {
      _unlockAchievement('arch_enthusiast');
    }
  }

  void _unlockAchievement(String id) {
    final ach = allAchievements.firstWhere((a) => a.id == id);
    _unlockedAchievementIds.add(id);
    _points += ach.pointsReward;
    print("ДОСТИЖЕНИЕ: ${ach.title}");
    // TODO: Показать уведомление
  }

  // -- ЛОГИКА СОХРАНЕНИЯ/ЗАГРУЗКИ --
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('discoveredLandmarkIds', _discoveredLandmarkIds.toList());
    await prefs.setStringList('unlockedAchievementIds', _unlockedAchievementIds.toList());
    await prefs.setInt('userPoints', _points);
    print("Прогресс сохранен!");
  }

  Future<void> loadProgress() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _discoveredLandmarkIds = Set.from(prefs.getStringList('discoveredLandmarkIds') ?? []);
    _unlockedAchievementIds = Set.from(prefs.getStringList('unlockedAchievementIds') ?? []);
    _points = prefs.getInt('userPoints') ?? 0;
    
    _isLoading = false;
    print("Прогресс загружен!");
    notifyListeners();
  }

  // Очистка при выходе
  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}