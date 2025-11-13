import 'package:dio/dio.dart';
import '../model/login_request.dart';
import '../model/auth_response.dart';
import '../model/refresh_token_request.dart';
import '../model/logout_request.dart';

// Класс, реализующий методы из секции "Auth" вашего swagger.json
class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  // Реализация POST /api/v1/auth/login
  Future<Response<AuthResponse>> postLogin({
    required LoginRequest loginRequest,
  }) async {
    final response = await _dio.post(
      '/api/v1/auth/login',
      data: loginRequest.toJson(),
    );
    // Вручную преобразуем Map<String, dynamic> в наш класс AuthResponse
    final authData = AuthResponse.fromJson(response.data);
    print(authData.accessToken);
    return Response(
      data: authData,
      requestOptions: response.requestOptions,
      statusCode: response.statusCode,
    );
  }

  // Реализация POST /api/v1/auth/refresh
  Future<Response<AuthResponse>> postRefresh({
    required RefreshTokenRequest refreshTokenRequest,
  }) async {
     final response = await _dio.post(
      '/api/v1/auth/refresh',
      data: refreshTokenRequest.toJson(),
    );
     final authData = AuthResponse.fromJson(response.data);
    return Response(
      data: authData,
      requestOptions: response.requestOptions,
      statusCode: response.statusCode,
    );
  }
  
  // Реализация POST /api/v1/auth/logout
  Future<Response> postLogout({
    required LogoutRequest logoutRequest,
  }) async {
     return await _dio.post(
      '/api/v1/auth/logout',
      data: logoutRequest.toJson(),
    );
  }
  
  // Вам нужно будет вручную добавить сюда postRegister, когда он понадобится
}