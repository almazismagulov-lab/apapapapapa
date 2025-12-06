import 'dart:async';
import 'package:astana_explorer/data/mock_data.dart';
import 'package:astana_explorer/models/landmark.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- 1. ИМПОРТИРУЕМ API ---
import 'package:astana_explorer/services/api_service.dart';
import 'package:astana_explorer/api_client/lib/api.dart';
// -----------------------

class GameProvider with ChangeNotifier {
  // -- КОНСТАНТЫ --
  static const double detectionRadius = 200; // 200 метров

  // -- 2. ДОБАВЛЯЕМ ПЕРЕМЕННУЮ ДЛЯ РЕАЛЬНОГО ПРОФИЛЯ --
  UserDto? _currentUser; 
  // ---------------------------------------------

  // -- СТАРЫЕ (ЛОКАЛЬНЫЕ) ДАННЫЕ (мы их больше не используем для профиля) --
  int _points = 0;
  Set<String> _discoveredLandmarkIds = {};
  Set<String> _unlockedAchievementIds = {};

  // -- СОСТОЯНИЕ КАРТЫ И GPS --
  Position? _currentPosition;
  bool _isLoading = true;
  StreamSubscription<Position>? _positionStream;
  final Distance _distance = const Distance();

  // -- 3. ОБНОВЛЯЕМ ГЕТТЕРЫ (для доступа из UI) --
  // Они будут использовать данные из API, если они есть
  int get points => _currentUser?.experience ?? _points;
  int get level => _currentUser?.level ?? (_points / 500).floor() + 1;
  String get username => _currentUser?.username ?? 'Исследователь';
  String? get avatarUrl => _currentUser?.avatarUrl;
  // ------------------------------------------

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  Set<String> get discoveredLandmarkIds => _discoveredLandmarkIds;

  List<LatLng> get discoveredHoleCenters {
    return _discoveredLandmarkIds.map((id) {
      return allLandmarks.firstWhere((lm) => lm.id == id).coordinates;
    }).toList();
  }

  bool isLandmarkDiscovered(String id) => _discoveredLandmarkIds.contains(id);
  bool isAchievementUnlocked(String id) => _unlockedAchievementIds.contains(id);
  int get discoveredLandmarksCount => _discoveredLandmarkIds.length;
  Set<String> get unlockedAchievementIds => _unlockedAchievementIds;

  // -- ИНИЦИАЛИЗАЦИЯ --
  GameProvider() {
    _init();
  }

  Future<void> _init() async {
    await _checkPermissions();
    startLocationTracking();
    // Загружаем и ФЕЙКОВЫЕ данные, и РЕАЛЬНЫЕ из API
    await loadProgress(); // Загружает локальные ачивки/точки (пока что)
    //await fetchUserProfile(); // <-- Этот вызов мы убрали
  }

  // --- 5. НОВАЯ ФУНКЦИЯ ЗАГРУЗКИ ПРОФИЛЯ ---
  Future<void> fetchUserProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Вызываем метод API, который мы создали
      final response = await ApiService.instance.api.profile.getMe();
      _currentUser = response.data; // Сохраняем реального пользователя
      print("Профиль успешно загружен: ${_currentUser?.username}");
    } catch (e) {
      print("Ошибка загрузки профиля: $e");
      // Здесь можно обработать ошибку, например, разлогинить пользователя
    }
    _isLoading = false;
    notifyListeners();
  }
  // ------------------------------------

  // -- ЛОГИКА GPS --
  Future<void> _checkPermissions() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }
  Future<void> manuallyRefreshPosition() async {
    _isLoading = true;
    notifyListeners();

    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      print("Ручное обновление позиции: $position");

      // TODO: Заменить эту логику на вызов API /api/v1/game/check-location
      _checkDiscoveredLandmarks(position);

    } catch (e) {
      print("Ошибка при ручном обновлении позиции: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void startLocationTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      print("Новая позиция: $position");

      // TODO: Заменить эту логику на вызов API /api/v1/game/check-location
      _checkDiscoveredLandmarks(position);
      notifyListeners();
    });
  }

  // -- ЛОГИКА ИГРЫ (ОБНАРУЖЕНИЕ) --
  // TODO: ЭТО ВСЕ НУЖНО БУДЕТ ЗАМЕНИТЬ НА ВЫЗОВЫ API
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
    _points += landmark.points; // Обновляем фейковые очки (для UI до перезагрузки)

    print("ОТКРЫТО: ${landmark.name}");

    _checkAchievements(landmark);
    _saveProgress();
    notifyListeners();
  }

  void _checkAchievements(Landmark discoveredLandmark) {
    if (_discoveredLandmarkIds.length == 1 && !isAchievementUnlocked('first_step')) {
      _unlockAchievement('first_step');
    }

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
  }

  // -- ЛОГИКА СОХРАНЕНИЯ/ЗАГРУЗКИ --
  // TODO: Это будет загружать только ачивки/точки, пока мы не перенесем и их на API
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('discoveredLandmarkIds', _discoveredLandmarkIds.toList());
    await prefs.setStringList('unlockedAchievementIds', _unlockedAchievementIds.toList());
    // await prefs.setInt('userPoints', _points); // Больше не сохраняем очки локально
    print("Локальный прогресс (ачивки/точки) сохранен!");
  }

  Future<void> loadProgress() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _discoveredLandmarkIds = Set.from(prefs.getStringList('discoveredLandmarkIds') ?? []);
    _unlockedAchievementIds = Set.from(prefs.getStringList('unlockedAchievementIds') ?? []);
    // _points = prefs.getInt('userPoints') ?? 0; // Больше не загружаем очки

    _isLoading = false;
    print("Локальный прогресс (ачивки/точки) загружен!");
    notifyListeners();
  }

  // --- НОВЫЙ МЕТОД ЗДЕСЬ ---
  // Метод для полного выхода и очистки
  Future<void> logoutAndClear() async {
    try {
      await ApiService.instance.logout(); // Вызываем API и стираем токены
    } catch (e) {
      print("Ошибка при вызове /logout (но мы все равно выходим): $e");
    } finally {
      _currentUser = null; // Стираем локальный кэш профиля
      _points = 0; // (если используете фейковые очки, тоже сбросьте)
      
      // Очищаем и другие локальные данные
      _discoveredLandmarkIds.clear();
      _unlockedAchievementIds.clear();
      await _saveProgress(); // Сохраняем "пустоту"

      notifyListeners(); // Уведомляем UI, что пользователя больше нет
    }
  }
  // --- КОНЕЦ НОВОГО МЕТОДА ---

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
