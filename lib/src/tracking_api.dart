import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:telematics_sdk/src/data/api_language.dart';
import 'package:telematics_sdk/src/data/heartbeat_type.dart';
import 'package:telematics_sdk/src/data/track_tag.dart';
import 'package:telematics_sdk/src/native_call_handler.dart';
import 'package:telematics_sdk/src/data/future_track_callbacks.dart';
import 'package:telematics_sdk/src/data/permission_wizard_result.dart';
import 'package:telematics_sdk/src/data/track_processed.dart';

import 'data/delegates_callbacks.dart';
import 'data/track_location.dart';

class TrackingApi {
  static const _channel = MethodChannel('telematics_sdk');
  final NativeCallHandler _handler = NativeCallHandler();

  OnTagAddCallback? onTagAdd;
  OnTagRemoveCallback? onTagRemove;
  OnAllTagsRemoveCallback? onAllTagsRemove;
  OnGetTagsCallback? onGetTags;

  TrackingApi() {
    _handler
      ..onTagAdd = onTagAdd
      ..onTagRemove = onTagRemove
      ..onAllTagsRemove = onAllTagsRemove
      ..onGetTags = onGetTags;

    _channel.setMethodCallHandler(_handler.handle);
  }

  Stream<PermissionWizardResult> get onPermissionWizardClose =>
      _handler.onPermissionWizardClose;
  Stream<bool> get lowerPowerMode => _handler.lowerPowerMode;
  Stream<TrackLocation> get locationChanged => _handler.locationChanged;
  //Stream<bool> get newEvents => _handler.newEvents; //TO DO
  // Stream<bool> get wrongAccuracyAuthorization =>   //TO DO
  //     _handler.wrongAccuracyAuthorization;
  Stream<bool> get trackingStateChanged => _handler.trackingStateChanged;
  Stream<String> get logEvent => _handler.logEvent;
  Stream<String> get logWarning => _handler.logWarning;
  Stream<SpeedLimitNotificationResult> get speedLimitNotification =>
      _handler.speedLimitNotification;
  Stream<HeartbeatSentResult> get heartbeatSent => _handler.heartbeatSent;
  Stream<bool> get rtldCollectedData => _handler.rtldCollectedData;

  /*
  Initializes new RPEntry class instance with specified device ID. Must be the first method calling from RaxelPulse SDK.
  withRequestingPermissions Indicates whether the SDK should request system permissions.
  */
  Future<void> initializeSdk({required bool withRequestingPermissions}) =>
      _channel
          .invokeMethod('initializeSdk', {'value': withRequestingPermissions});

  Future<String?> getSdkVersion() => _channel.invokeMethod('getSdkVersion');

  Future<String?> getDeviceId() => _channel.invokeMethod('getDeviceId');

  Future<void> clearDeviceID() => _channel.invokeMethod('clearDeviceID');

  Future<void> setDeviceID({required String deviceId}) =>
      _channel.invokeMethod('setDeviceID', {'deviceId': deviceId});

  Future<ApiLanguage?> getApiLanguage() {
    return _channel.invokeMethod<String>('getApiLanguage').then((value) {
      if (value == "None") {
        return ApiLanguage.none;
      } else if (value == "English") {
        return ApiLanguage.english;
      } else if (value == "Russian") {
        return ApiLanguage.russian;
      } else if (value == "Portuguese") {
        return ApiLanguage.portuguese;
      } else if (value == "Spanish") {
        return ApiLanguage.spanish;
      } else {
        return null;
      }
    });
  }

  Future<void> setApiLanguage({required ApiLanguage language}) {
    var apiLanguage = '';
    switch (language) {
      case ApiLanguage.none:
        apiLanguage = 'None';
      case ApiLanguage.english:
        apiLanguage = 'English';
      case ApiLanguage.russian:
        apiLanguage = 'Russian';
      case ApiLanguage.portuguese:
        apiLanguage = 'Portuguese';
      case ApiLanguage.spanish:
        apiLanguage = 'Spanish';
    }
    return _channel
        .invokeMethod('setApiLanguage', {'apiLanguage': apiLanguage});
  }

  Future<bool?> isWrongAccuracyState() =>
      _channel.invokeMethod('isWrongAccuracyState');

  Future<void> setWrongAccuracyState({required bool state}) =>
      _channel.invokeMethod('setWrongAccuracyState', {'value': state});

  Future<bool?> isAllRequiredPermissionsAndSensorsGranted() =>
      _channel.invokeMethod('isAllRequiredPermissionsAndSensorsGranted');

  Future<bool?> isSdkEnabled() => _channel.invokeMethod('isSdkEnabled');

  Future<bool?> isTracking() => _channel.invokeMethod('isTracking');

  /// If [enable] set to `false` and [uploadBeforeDisabling] is `true`,
  /// SDK will wait until all tracks will be uploaded and only after that
  /// it will be disabled. Otherwise SDK will be just enabled or disabled
  /// depending on [enable] value.
  Future<void> setEnableSdk({
    required bool enable,
    bool uploadBeforeDisabling = false,
  }) =>
      _channel.invokeMethod('setEnableSdk', {
        'enable': enable,
        'uploadBeforeDisabling': uploadBeforeDisabling,
      });

  Future<bool?> startTracking() => _channel.invokeMethod('startTracking');

  Future<bool?> stopTracking() => _channel.invokeMethod('stopTracking');

  /// `SDK can work in two modes`:
  /// `Aggressive` - heartbeats are sent every 20 minutes and SDK never sleeps.
  /// `Normal` - heartbeats are sent every 20 minutes but when system suspends SDK,
  ///  it gees to a sleep mode and will restore work only in trip start time.
  Future<bool?> isAggressiveHeartbeat() =>
      _channel.invokeMethod('isAggressiveHeartbeat');

  //TO DO - change to return void (check)
  Future<bool?> setAggressiveHeartbeats({required bool value}) =>
      _channel.invokeMethod('setAggressiveHeartbeats', {'value': value});

  Future<void> setHeartbeatType({required HeartbeatType type}) {
    var heartbeatType = 0;
    switch (type) {
      case HeartbeatType.defaultType:
        heartbeatType = 0;
      case HeartbeatType.aggressiveType:
        heartbeatType = 1;
      case HeartbeatType.lowType:
        heartbeatType = 2;
    }
    return _channel
        .invokeMethod('setHeartbeatType', {'heartbeatType': heartbeatType});
  }

  Future<void> enableHF({required bool value}) =>
      _channel.invokeMethod('enableHF', {'enableHF': value});

  Future<void> enableELM({required bool value}) =>
      _channel.invokeMethod('enableHF', {'enableELM': value});

  Future<bool?> isEnabledELM() => _channel.invokeMethod('isEnabledELM');

  Future<void> enableAccidents({required bool value}) =>
      _channel.invokeMethod('enableAccidents', {'enableAccidents': value});

  Future<bool?> isEnabledAccidents() =>
      _channel.invokeMethod('isEnabledAccidents');

  Future<void> enableRTLD({required bool value}) =>
      _channel.invokeMethod('enableRTLD', {'enableRTLD': value});

  Future<bool?> isRTLDEnabled() => _channel.invokeMethod('isRTLDEnabled');

  Future<String?> getRTLDData() => _channel.invokeMethod('getRTLDData');

  Future<double?> getCurrentSpeed() => _channel.invokeMethod('getCurrentSpeed');

  /// If [enableAggressivePermissionsWizard] set to `true` the wizard will be
  /// finished if all required permissions granted (user can’t cancel it with
  /// back button), otherwise if set to `false` the wizard can be finished with
  /// not all granted permissions or cancelled with back button.
  ///
  /// If [enableAggressivePermissionsWizardPage] set to `true` the wizard will
  /// slide to next page if requested permissions granted on current page,
  /// otherwise if set to `false` the wizard can slide with not granted permissions.
  Future<void> showPermissionWizard({
    required bool enableAggressivePermissionsWizard,
    required bool enableAggressivePermissionsWizardPage,
  }) =>
      _channel.invokeMethod('showPermissionWizard', {
        'enableAggressivePermissionsWizard': enableAggressivePermissionsWizard,
        'enableAggressivePermissionsWizardPage':
            enableAggressivePermissionsWizardPage,
      });

  ///Tracks

  //Requests all tracks with specified offset and limit. Can be filtered by passing non-nil start & end dates.

  //TO DO - add getTracks function to SwiftTelematicsSDKPlugin
  Future<Iterable<TrackProcessed>?> getTracks({
    required UnsignedInt offset,
    required UnsignedInt limit,
    DateTime? startDate,
    DateTime? endDate
  }) => _channel.invokeMethod<Iterable<String>>('getTracks', {
    'offset': offset,
    'limit': limit,
    'startDate': startDate?.toUtc().toIso8601String(),
    'endDate': endDate?.toUtc().toIso8601String()
  }).then(
        (value) => value?.map(
          (e) => TrackProcessed.fromJson(jsonDecode(e) as Map<String, dynamic>),
    ),
  );

  ///TrackTags
  Future<Iterable<TrackTag>?> getTrackTags({required String trackId}) =>
      _channel.invokeMethod<Iterable<String>>('getTrackTags', {
        'trackId': trackId,
      }).then(
        (value) => value?.map(
          (e) => TrackTag.fromJson(jsonDecode(e) as Map<String, dynamic>),
        ),
      );

  Future<Iterable<TrackTag>?> addTrackTags({
    required String trackId,
    required Iterable<TrackTag> tags,
  }) =>
      _channel.invokeMethod<Iterable<String>>('addTrackTags', {
        'trackId': trackId,
        'tags': tags.map((it) => jsonEncode(it.toJson))
      }).then(
        (value) => value?.map(
          (e) => TrackTag.fromJson(jsonDecode(e) as Map<String, dynamic>),
        ),
      );

  Future<Iterable<TrackTag>?> removeTrackTags({
    required String trackId,
    required Iterable<TrackTag> tags,
  }) =>
      _channel.invokeMethod<Iterable<String>>('removeTrackTags', {
        'trackId': trackId,
        'tags': tags.map((it) => jsonEncode(it.toJson))
      }).then(
        (value) => value?.map(
          (e) => TrackTag.fromJson(jsonDecode(e) as Map<String, dynamic>),
        ),
      );

  ///FutureTrackTags
  Future<void> getFutureTrackTags() =>
      _channel.invokeMethod('getFutureTrackTags');

  Future<void> addFutureTrackTag({
    required String tag,
    required String source,
  }) =>
      _channel.invokeMethod('addFutureTrackTag', {
        'tag': tag,
        'source': source,
      });

  Future<void> removeFutureTrackTag({required String tag}) =>
      _channel.invokeMethod('removeFutureTrackTag', {'tag': tag});

  /// TODO: check iOS
  Future<void> removeAllFutureTrackTags() =>
      _channel.invokeMethod('removeAllFutureTrackTags');
}
