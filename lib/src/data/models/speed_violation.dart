class SpeedViolation {
  final int date;
  final double latitude;
  final double longitude;
  final double speed;
  final double speedLimit;

  const SpeedViolation({
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.speedLimit
  });

  factory SpeedViolation.fromJson(Map<String, dynamic> json) {
    final date = json['date'] as int;
    final latitude = json['latitude'] as double;
    final longitude = json['longitude'] as double;
    final speed = json['speed'] as double;
    final speedLimit = json['speedLimit'] as double;

    return SpeedViolation(
      date: date,
      latitude: latitude,
      longitude: longitude,
      speed: speed,
      speedLimit: speedLimit
    );
  }
}
