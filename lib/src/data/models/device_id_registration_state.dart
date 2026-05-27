import 'package:flutter/foundation.dart';

enum DeviceIdRegistrationStatus { notSet, unknown, registered, notRegistered }

@immutable
class DeviceIdRegistrationState {
  const DeviceIdRegistrationState({
    required this.status,
    required this.checkedAtMillis,
  });

  final DeviceIdRegistrationStatus status;
  final int checkedAtMillis;

  factory DeviceIdRegistrationState.fromJson(Map<dynamic, dynamic> json) {
    return DeviceIdRegistrationState(
      status: _deviceIdRegistrationStatusFromJson(json['status']),
      checkedAtMillis: _intFromJson(json['checkedAtMillis']),
    );
  }
}

DeviceIdRegistrationStatus _deviceIdRegistrationStatusFromJson(Object? value) {
  if (value is int) {
    return switch (value) {
      0 => DeviceIdRegistrationStatus.notSet,
      1 => DeviceIdRegistrationStatus.unknown,
      2 => DeviceIdRegistrationStatus.registered,
      3 => DeviceIdRegistrationStatus.notRegistered,
      _ => DeviceIdRegistrationStatus.unknown,
    };
  }

  return switch (value?.toString()) {
    'NOT_SET' => DeviceIdRegistrationStatus.notSet,
    'UNKNOWN' => DeviceIdRegistrationStatus.unknown,
    'REGISTERED' => DeviceIdRegistrationStatus.registered,
    'NOT_REGISTERED' => DeviceIdRegistrationStatus.notRegistered,
    _ => DeviceIdRegistrationStatus.unknown,
  };
}

int _intFromJson(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return 0;
}
