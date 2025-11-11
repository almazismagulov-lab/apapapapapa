// Это "главный" файл, который собирает все части API
library api;

import 'package:dio/dio.dart';
import 'api/auth_api.dart';

// Экспортируем все наши модели, чтобы их можно было импортировать из одного места
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
  // TODO: Добавьте здесь PointsApi, ProfileApi и т.д.

  NomadGisApi(this._dio) {
    // Инициализируем все API-секции
    auth = AuthApi(_dio);
    // points = PointsApi(_dio);
    // profile = ProfileApi(_dio);
  }
}