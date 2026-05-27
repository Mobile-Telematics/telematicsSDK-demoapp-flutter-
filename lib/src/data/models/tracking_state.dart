import 'package:flutter/foundation.dart';

enum TrackingStatus {
  enabled,
  deviceIdNotSet,
  sdkDisabled,
  disabledBySettings,
  disabledByServer,
  disabledBySchedule,
  unknown,
}

@immutable
class TrackingState {
  const TrackingState({
    required this.automaticTrackingStatus,
    required this.manualTrackingStatus,
  });

  final TrackingStatus automaticTrackingStatus;
  final TrackingStatus manualTrackingStatus;

  factory TrackingState.fromJson(Map<dynamic, dynamic> json) {
    return TrackingState(
      automaticTrackingStatus: _trackingStatusFromJson(
        json['automaticTrackingStatus'],
      ),
      manualTrackingStatus: _trackingStatusFromJson(
        json['manualTrackingStatus'],
      ),
    );
  }
}

TrackingStatus _trackingStatusFromJson(Object? value) {
  if (value is int) {
    return switch (value) {
      0 => TrackingStatus.enabled,
      1 => TrackingStatus.deviceIdNotSet,
      2 => TrackingStatus.sdkDisabled,
      3 => TrackingStatus.disabledBySettings,
      4 => TrackingStatus.disabledByServer,
      5 => TrackingStatus.disabledBySchedule,
      _ => TrackingStatus.unknown,
    };
  }

  return switch (value?.toString()) {
    'ENABLED' => TrackingStatus.enabled,
    'DEVICE_ID_NOT_SET' => TrackingStatus.deviceIdNotSet,
    'SDK_DISABLED' => TrackingStatus.sdkDisabled,
    'DISABLED_BY_SETTINGS' => TrackingStatus.disabledBySettings,
    'DISABLED_BY_SERVER' => TrackingStatus.disabledByServer,
    'DISABLED_BY_SCHEDULE' => TrackingStatus.disabledBySchedule,
    _ => TrackingStatus.unknown,
  };
}
