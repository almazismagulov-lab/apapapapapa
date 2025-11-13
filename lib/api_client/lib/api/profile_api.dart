import 'package:dio/dio.dart';
import '../model/user_dto.dart'; //

// Класс для эндпоинтов Профиля
class ProfileApi {
  final Dio _dio;
  ProfileApi(this._dio);

  // Реализация GET /api/v1/profile/me
  Future<Response<UserDto>> getMe() async {
    final response = await _dio.get('/api/v1/profile/me');

    // Вручную преобразуем Map<String, dynamic> в наш класс UserDto
    final userData = UserDto.fromJson(response.data);
    return Response(
      data: userData,
      requestOptions: response.requestOptions,
      statusCode: response.statusCode,
    );
  }

  // TODO: Вручную добавьте сюда getMyPoints, getMyAchievements и т.д.
}