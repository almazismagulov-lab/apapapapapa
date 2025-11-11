import 'package:astana_explorer/api_client/lib/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Создаем "Синглтон" - единый экземпляр этого сервиса для всего приложения
class ApiService {
  // --- Синглтон ---
  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;
  
  // --- Переменные ---
  late final NomadGisApi api; // Наш вручную созданный клиент
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.joshki.top'));
  final _storage = const FlutterSecureStorage();
  
  // --- Конструктор ---
  ApiService._internal() {
    _setupInterceptors();
    api = NomadGisApi(_dio);
  }

  // --- Главная логика: Перехватчик ---
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        
        // 1. Добавляем токен авторизации к КАЖДОМУ запросу
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options); // Продолжаем запрос
        },

        // 2. Обрабатываем ошибки (здесь магия)
        onError: (DioException e, handler) async {
          // Если ошибка - 401 (Не авторизован) и это НЕ запрос на обновление токена
          if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('refresh')) {
            print("Токен истек, пытаемся обновить...");
            
            // Пытаемся обновить токен
            if (await _refreshToken()) {
              print("Токен обновлен, повторяем запрос...");
              // Повторяем ОРИГИНАЛЬНЫЙ запрос с новым токеном
              return handler.resolve(await _retry(e.requestOptions));
            } else {
              print("Не удалось обновить токен.");
              // Если обновить не удалось, "проваливаем" ошибку дальше
              return handler.next(e);
            }
          }
          // Если это не 401, просто пробрасываем ошибку
          return handler.next(e);
        },
      ),
    );
  }

  // --- 3. Логика обновления токена ---
  Future<bool> _refreshToken() async {
    try {
      // Получаем старые данные из хранилища
      final refreshToken = await _storage.read(key: 'refresh_token');
      final userId = await _storage.read(key: 'user_id');
      final deviceId = await _storage.read(key: 'device_id');

      if (refreshToken == null || userId == null || deviceId == null) {
        return false;
      }
      
      // Создаем запрос на обновление
      final refreshRequest = RefreshTokenRequest(
        refreshToken: refreshToken,
        userId: userId,
        deviceId: deviceId,
      );

      // Создаем НОВЫЙ экземпляр Dio БЕЗ интерсептора
      final refreshDio = Dio(BaseOptions(baseUrl: 'https://api.joshki.top'));
      final response = await refreshDio.post(
        '/api/v1/auth/refresh',
        data: refreshRequest.toJson(),
      );

      if (response.statusCode == 200) {
        final newAuthData = AuthResponse.fromJson(response.data);
        await saveTokens(newAuthData, deviceId); // Сохраняем новые токены
        return true;
      }
      return false;

    } catch (e) {
      print("Ошибка при обновлении токена: $e");
      await _storage.deleteAll();
      return false;
    }
  }

  // Повторяем запрос, который не удался
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // --- 4. Публичные методы для сохранения токенов и выхода ---
  Future<void> saveTokens(AuthResponse authData, String deviceId) async {
    await _storage.write(key: 'auth_token', value: authData.accessToken);
    await _storage.write(key: 'refresh_token', value: authData.refreshToken);
    await _storage.write(key: 'user_id', value: authData.user.id.toString());
    await _storage.write(key: 'device_id', value: deviceId);
  }
  
  Future<void> logout() async {
    try {
       final refreshToken = await _storage.read(key: 'refresh_token');
       final userId = await _storage.read(key: 'user_id');
       final deviceId = await _storage.read(key: 'device_id');

       if (refreshToken == null || userId == null || deviceId == null) return;
       
       final request = LogoutRequest(
        refreshToken: refreshToken,
        userId: userId,
        deviceId: deviceId
       );
       
       // Вызываем logout через наш клиент
       await api.auth.postLogout(logoutRequest: request);

    } catch(e) {
      print("Ошибка при вызове /logout (но мы все равно выходим): $e");
    } finally {
      // В любом случае очищаем хранилище
      await _storage.deleteAll();
    }
  }
}