import 'user_dto.dart';

// Модель ответа при входе
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserDto user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: UserDto.fromJson(json['user']),
    );
  }
}