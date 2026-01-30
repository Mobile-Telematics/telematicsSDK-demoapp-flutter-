class TrackLocation {
  final double latitude;
  final double longitude;

  const TrackLocation({
    required this.latitude,
    required this.longitude,
  });

  factory TrackLocation.fromJson(Map<String, dynamic> json) {
    final latitude = json['latitude'] as double;
    final longitude = json['longitude'] as double;

    return TrackLocation(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
