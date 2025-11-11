// Модель запроса на вход
class LoginRequest {
  final String? identifier;
  final String? password;
  final String? deviceId;

  LoginRequest({
    this.identifier,
    this.password,
    this.deviceId,
  });

  // Метод для преобразования в JSON
  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'password': password,
      'deviceId': deviceId,
    };
  }
}