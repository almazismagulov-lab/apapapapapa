// Это "главный" файл, который собирает все части API
library api;

import 'package:dio/dio.dart';
import 'api/auth_api.dart';
import 'api/profile_api.dart'; // <-- 1. ИМПОРТИРУЕМ НОВЫЙ ФАЙЛ

// Экспортируем все наши модели
export 'model/login_request.dart';
export 'model/auth_response.dart';
export 'model/user_dto.dart';
export 'model/refresh_token_request.dart';
export 'model/logout_request.dart';

// TODO: Экспортируйте здесь будущие модели (MapPoint, Achievement и т.д.)


// Главный класс API, который будет использовать ApiService
class NomadGisApi {
  final Dio _dio;
  late final AuthApi auth;
  late final ProfileApi profile; // <-- 2. ДОБАВЛЯЕМ PROFILE API
  // TODO: Добавьте здесь PointsApi, GameApi и т.д.

  NomadGisApi(this._dio) {
    // Инициализируем все API-секции
    auth = AuthApi(_dio);
    profile = ProfileApi(_dio); // <-- 3. ИНИЦИАЛИЗИРУЕМ ЕГО
    // points = PointsApi(_dio);
    // game = GameApi(_dio);
  }
}