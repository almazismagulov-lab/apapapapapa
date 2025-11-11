// Модель для выхода
class LogoutRequest {
  final String userId;
  final String refreshToken;
  final String deviceId;

  LogoutRequest({
    required this.userId,
    required this.refreshToken,
    required this.deviceId,
  });

   Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'refreshToken': refreshToken,
      'deviceId': deviceId,
    };
  }
}