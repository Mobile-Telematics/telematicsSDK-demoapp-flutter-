class HeartbeatSentResult {
  final bool state;
  final bool success;

  const HeartbeatSentResult({
    required this.state,
    required this.success,
  });

  factory HeartbeatSentResult.fromJson(Map<String, dynamic> json) {
    final state = json['state'] as bool;
    final success = json['success'] as bool;

    return HeartbeatSentResult(
      state: state,
      success: success,
    );
  }
}

class SpeedLimitNotificationResult {
  final double speedLimit;
  final double speed;
  final double latitude;
  final double longitude;
  final String date;

  const SpeedLimitNotificationResult(
      {required this.speedLimit,
      required this.speed,
      required this.latitude,
      required this.longitude,
      required this.date});

  factory SpeedLimitNotificationResult.fromJson(Map<String, dynamic> json) {
    final speedLimit = json['speedLimit'] as double;
    final speed = json['speed'] as double;
    final latitude = json['latitude'] as double;
    final longitude = json['longitude'] as double;
    final date = json['date'] as String;

    return SpeedLimitNotificationResult(
        speedLimit: speedLimit,
        speed: speed,
        latitude: latitude,
        longitude: longitude,
        date: date);
  }
}
