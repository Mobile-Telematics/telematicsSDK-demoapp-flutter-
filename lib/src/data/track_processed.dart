
class TrackProcessed {
  final DateTime startDate;
  final DateTime endDate;

  /// The start address.
  final String addressStart;

  /// The end address.
  final String addressEnd;

  /// The count of sharp acceleration.
  final int accelerationCount;

  /// The count of sharp braking.
  final int decelerationCount;

  /// The trip rating.
  final double rating;

  /// The trip rating.
  final double rating100;

  /// The trip сornering rating.
  final double ratingCornering;

  /// The trip сornering rating.
  final double ratingCornering100;

  /// The trip acceleration rating.
  final double ratingAcceleration;

  /// The trip acceleration rating.
  final double ratingAcceleration100;

  /// The trip braking rating.
  final double ratingBraking;

  /// The trip braking rating.
  final double ratingBraking100;

  /// The trip speeding rating.
  final double ratingSpeeding;

  /// The trip speeding rating.
  final double ratingSpeeding100;

  /// The trip phone usage rating.
  final double ratingPhoneUsage;

  /// The trip phone usage rating.
  final double ratingPhoneUsage100;

  /// The trip time of day rating.
  final double ratingTimeOfDay;

  /// The trip reason rating.
  final String ratingReason;

  /// The trip reason rating.
  final AddressParts addressStartParts;

  /// The trip reason rating.
  final AddressParts addressFinishParts;

  final List<InnerTag> tags;

  /// The trip phone usage minutes.
  final double phoneUsage;

  /// The distance trip in km.
  final double distance;

  /// The duration trip in horse.
  final double duration;

  /// Total distance travelled(in km) while exceeding speed limit over for 20 km/h or more.
  final double highOverSpeedMileage;

  /// Total distance travelled(in km) while exceeding speed limit over for 10 to 20 km/h.
  final double midOverSpeedMileage;

  /// The trip type has changed.
  final bool originChanged;

  /// The trip type.
  final String trackOriginCode;

  /// Track token.
  final String trackToken;

  /// Sharing type (ex: Shared).
  final String shareType;

  /// Start point city name.
  final String cityStart;

  /// End point city name.
  final String cityFinish;

  /// Array of track points
  final List<TrackPointProcessed> points;
  final double dateUpdated;

  const TrackProcessed({
    required this.startDate,
    required this.endDate,
    required this.addressStart,
    required this.addressEnd,
    required this.accelerationCount,
    required this.decelerationCount,
    required this.rating,
    required this.rating100,
    required this.ratingCornering,
    required this.ratingCornering100,
    required this.ratingAcceleration,
    required this.ratingAcceleration100,
    required this.ratingBraking,
    required this.ratingBraking100,
    required this.ratingSpeeding,
    required this.ratingSpeeding100,
    required this.ratingPhoneUsage,
    required this.ratingPhoneUsage100,
    required this.ratingTimeOfDay,
    required this.ratingReason,
    required this.addressStartParts,
    required this.addressFinishParts,
    required this.tags,
    required this.phoneUsage,
    required this.distance,
    required this.duration,
    required this.highOverSpeedMileage,
    required this.midOverSpeedMileage,
    required this.originChanged,
    required this.trackOriginCode,
    required this.trackToken,
    required this.shareType,
    required this.cityStart,
    required this.cityFinish,
    required this.points,
    required this.dateUpdated,
  });

  factory TrackProcessed.fromJson(Map<String, dynamic> json) {
    final startDateString = json['startDate'] as String;
    final endDateString = json['endDate'] as String;
    final startDate = DateTime.parse(startDateString); //TO DO check
    final endDate = DateTime.parse(endDateString); //TO DO check
    final addressStart = json['addressStart'] as String;
    final addressEnd = json['addressEnd'] as String;
    final accelerationCount = json['accelerationCount'] as int;
    final decelerationCount = json['decelerationCount'] as int;
    final rating = json['rating'] as double;
    final rating100 = json['rating100'] as double;
    final ratingCornering = json['ratingCornering'] as double;
    final ratingCornering100 = json['ratingCornering100'] as double;
    final ratingAcceleration = json['ratingAcceleration'] as double;
    final ratingAcceleration100 = json['ratingAcceleration100'] as double;
    final ratingBraking = json['ratingBraking'] as double;
    final ratingBraking100 = json['ratingBraking100'] as double;
    final ratingSpeeding = json['ratingSpeeding'] as double;
    final ratingSpeeding100 = json['ratingSpeeding100'] as double;
    final ratingPhoneUsage = json['ratingPhoneUsage'] as double;
    final ratingPhoneUsage100 = json['ratingPhoneUsage100'] as double;
    final ratingTimeOfDay = json['ratingTimeOfDay'] as double;
    final ratingReason = json['ratingReason'] as String;
    final addressStartPartsJson = json['addressStartParts'];
    final addressStartParts =
        AddressParts.fromJson(addressStartPartsJson); //TO DO check
    final addressFinishPartsJson = json['addressFinishParts'];
    final addressFinishParts =
        AddressParts.fromJson(addressFinishPartsJson); //TO DO check
    final tagsList = json['tags'] as List;
    final tags = tagsList
        .map<InnerTag>((json) => InnerTag.fromJson(json))
        .toList(); //TO DO check
    final phoneUsage = json['phoneUsage'] as double;
    final distance = json['distance'] as double;
    final duration = json['duration'] as double;
    final highOverSpeedMileage = json['highOverSpeedMileage'] as double;
    final midOverSpeedMileage = json['midOverSpeedMileage'] as double;
    final originChanged = json['originChanged'] as bool;
    final trackOriginCode = json['trackOriginCode'] as String;
    final trackToken = json['trackToken'] as String;
    final shareType = json['shareType'] as String;
    final cityStart = json['cityStart'] as String;
    final cityFinish = json['cityFinish'] as String;
    final pointsList = json['points'] as List;
    final points = pointsList
        .map<TrackPointProcessed>((json) => TrackPointProcessed.fromJson(json))
        .toList(); //TO DO check
    final dateUpdated = json['dateUpdated'] as double;

    return TrackProcessed(
      startDate: startDate,
      endDate: endDate,
      addressStart: addressStart,
      addressEnd: addressEnd,
      accelerationCount: accelerationCount,
      decelerationCount: decelerationCount,
      rating: rating,
      rating100: rating100,
      ratingCornering: ratingCornering,
      ratingCornering100: ratingCornering100,
      ratingAcceleration: ratingAcceleration,
      ratingAcceleration100: ratingAcceleration100,
      ratingBraking: ratingBraking,
      ratingBraking100: ratingBraking100,
      ratingSpeeding: ratingSpeeding,
      ratingSpeeding100: ratingSpeeding100,
      ratingPhoneUsage: ratingPhoneUsage,
      ratingPhoneUsage100: ratingPhoneUsage100,
      ratingTimeOfDay: ratingTimeOfDay,
      ratingReason: ratingReason,
      addressStartParts: addressStartParts,
      addressFinishParts: addressFinishParts,
      tags: tags,
      phoneUsage: phoneUsage,
      distance: distance,
      duration: duration,
      highOverSpeedMileage: highOverSpeedMileage,
      midOverSpeedMileage: midOverSpeedMileage,
      originChanged: originChanged,
      trackOriginCode: trackOriginCode,
      trackToken: trackToken,
      shareType: shareType,
      cityStart: cityStart,
      cityFinish: cityFinish,
      points: points,
      dateUpdated: dateUpdated,
    );
  }
}

class AddressParts {
  /// The country code of address.
  final String countryCode;

  /// The country of address.
  final String country;

  /// The county of address.
  final String county;

  /// The postal code of address.
  final String postalCode;

  /// The state of address.
  final String state;

  /// The city of address.
  final String city;

  /// The district of address.
  final String district;

  /// The street of address.
  final String street;

  /// The house of address.
  final String house;

  const AddressParts({
    required this.countryCode,
    required this.country,
    required this.county,
    required this.postalCode,
    required this.state,
    required this.city,
    required this.district,
    required this.street,
    required this.house,
  });

  factory AddressParts.fromJson(Map<String, dynamic> json) {
    final countryCode = json['countryCode'] as String;
    final country = json['country'] as String;
    final county = json['county'] as String;
    final postalCode = json['postalCode'] as String;
    final state = json['state'] as String;
    final city = json['city'] as String;
    final district = json['district'] as String;
    final street = json['street'] as String;
    final house = json['house'] as String;

    return AddressParts(
      countryCode: countryCode,
      country: country,
      county: county,
      postalCode: postalCode,
      state: state,
      city: city,
      district: district,
      street: street,
      house: house,
    );
  }
}

enum SpeedType { normal, medium, high }

enum AlertType { none, acceleration, deceleration }

class TrackPointProcessed {
  final int number;
  final double totalMeters;
  final double speed;
  final double midSpeed;
  final DateTime pointDate;
  final double latitude;
  final double longitude;
  final double height;
  final double course;
  final double yaw;
  final double lateral;
  final AlertType alertType;
  final double alertValue;
  final SpeedType speedType;
  final double speedLimit;
  final double phoneUsage;
  final bool cornering;

  const TrackPointProcessed({
    required this.number,
    required this.totalMeters,
    required this.speed,
    required this.midSpeed,
    required this.pointDate,
    required this.latitude,
    required this.longitude,
    required this.height,
    required this.course,
    required this.yaw,
    required this.lateral,
    required this.alertType,
    required this.alertValue,
    required this.speedType,
    required this.speedLimit,
    required this.phoneUsage,
    required this.cornering,
  });

  factory TrackPointProcessed.fromJson(Map<String, dynamic> json) {
    final number = json['number'] as int;
    final totalMeters = json['totalMeters'] as double;
    final speed = json['speed'] as double;
    final midSpeed = json['midSpeed'] as double;
    final pointDateString = json['pointDate'] as String; //TO DO check
    final pointDate = DateTime.parse(pointDateString);
    final latitude = json['latitude'] as double;
    final longitude = json['longitude'] as double;
    final height = json['height'] as double;
    final course = json['course'] as double;
    final yaw = json['yaw'] as double;
    final lateral = json['lateral'] as double;

    final alertTypeString = json['alertType'] as String; //TO DO check
    final alertType = alertTypeFrom(alertTypeString);
    final alertValue = json['alertValue'] as double;
    final speedTypeString = json['speedType'] as String; //TO DO check
    final speedType = speedTypeFrom(speedTypeString);
    final speedLimit = json['speedLimit'] as double;
    final phoneUsage = json['phoneUsage'] as double;
    final cornering = json['cornering'] as bool;

    return TrackPointProcessed(
      number: number,
      totalMeters: totalMeters,
      speed: speed,
      midSpeed: midSpeed,
      pointDate: pointDate,
      latitude: latitude,
      longitude: longitude,
      height: height,
      course: course,
      yaw: yaw,
      lateral: lateral,
      alertType: alertType,
      alertValue: alertValue,
      speedType: speedType,
      speedLimit: speedLimit,
      phoneUsage: phoneUsage,
      cornering: cornering,
    );
  }

  static SpeedType speedTypeFrom(String string) {
    if (string == 'normal') {
      return SpeedType.normal;
    }
    if (string == 'medium') {
      return SpeedType.medium;
    }
    if (string == 'high') {
      return SpeedType.high;
    }
    return SpeedType.normal;
  }

  static AlertType alertTypeFrom(String string) {
    if (string == 'none') {
      return AlertType.none;
    }
    if (string == 'acceleration') {
      return AlertType.acceleration;
    }
    if (string == 'deceleration') {
      return AlertType.deceleration;
    }
    return AlertType.none;
  }
}

class InnerTag {
  final String source;
  final String tag;
  final String type;
  final String timestamp;

  const InnerTag({
    required this.source,
    required this.tag,
    required this.type,
    required this.timestamp,
  });

  factory InnerTag.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as String;
    final tag = json['tag'] as String;
    final type = json['type'] as String;
    final timestamp = json['timestamp'] as String;

    return InnerTag(
      source: source,
      tag: tag,
      type: type,
      timestamp: timestamp,
    );
  }
}
