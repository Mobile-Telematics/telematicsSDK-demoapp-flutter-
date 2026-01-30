import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:telematics_sdk/src/native_call_handler.dart';
import 'package:telematics_sdk/src/data/future_track_callbacks.dart';
import 'package:telematics_sdk/telematics_sdk.dart';

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
  Stream<bool> get lowPowerMode => _handler.lowPowerMode;
  Stream<TrackLocation> get locationChanged => _handler.locationChanged;
  Stream<bool> get trackingStateChanged => _handler.trackingStateChanged;
  Stream<void> get iOSWrongAccuracyAuthorization => _handler.iOSWrongAccuracyAuthorization;
  Stream<void> get iOSRTLDDataCollected => _handler.iOSRTLDDataCollected;
  Stream<SpeedViolation> get speedViolation => _handler.speedViolation;

  Future<bool?> isInitialized() => _channel.invokeMethod('isInitialized');

  Future<String?> getDeviceId() => _channel.invokeMethod('getDeviceId');

  Future<void> setDeviceID({required String deviceId}) =>
      _channel.invokeMethod('setDeviceID', {'deviceId': deviceId});

  Future<void> logout() => _channel.invokeMethod('logout');

  Future<bool?> isAllRequiredPermissionsAndSensorsGranted() =>
      _channel.invokeMethod('isAllRequiredPermissionsAndSensorsGranted');

  Future<bool?> isSdkEnabled() => _channel.invokeMethod('isSdkEnabled');

  Future<bool?> isTracking() => _channel.invokeMethod('isTracking');

  Future<void> setEnableSdk({required bool enable}) {
    return _channel.invokeMethod('setEnableSdk', {'enable': enable});
  }

  Future<bool?> startManualTracking() => _channel.invokeMethod('startManualTracking');

  Future<bool?> startManualPersistentTracking() => _channel.invokeMethod('startManualPersistentTracking');

  Future<bool?> stopManualTracking() => _channel.invokeMethod('stopManualTracking');

  Future<void> uploadUnsentTrips() => _channel.invokeMethod('uploadUnsentTrips');

  Future<int?> getUnsentTripCount() => _channel.invokeMethod('getUnsentTripCount');

  Future<void> sendCustomHeartbeats({required String reason}) {
    return _channel.invokeMethod('sendCustomHeartbeats', {'reason': reason});
  }

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

  ///FutureTrackTags
  Future<void> getFutureTrackTags() => _channel.invokeMethod('getFutureTrackTags');

  Future<void> addFutureTrackTag({required String tag, required String source}) {
    return _channel.invokeMethod('addFutureTrackTag', {'tag': tag, 'source': source});
  }

  Future<void> removeFutureTrackTag({required String tag}) {
    return _channel.invokeMethod('removeFutureTrackTag', {'tag': tag});
  }

  Future<void> removeAllFutureTrackTags() =>
      _channel.invokeMethod('removeAllFutureTrackTags');

  Future<void> setAccidentDetectionSensitivity({required AccidentDetectionSensitivity sensitivity}) {
    int value = 0;
    switch (sensitivity) {
      case AccidentDetectionSensitivity.normal:
        value = 0;
      case AccidentDetectionSensitivity.sensitive:
        value = 1;
      case AccidentDetectionSensitivity.tough:
        value = 2;
    }
    return _channel
        .invokeMethod('setAccidentDetectionSensitivity', {'accidentDetectionSensitivity': value});
  }

  Future<bool?> isRTLDEnabled() => _channel.invokeMethod('isRTLDEnabled');

  Future<void> enableAccidents({required bool value}) =>
      _channel.invokeMethod('enableAccidents', {'enableAccidents': value});

  Future<bool?> isEnabledAccidents() =>
      _channel.invokeMethod('isEnabledAccidents');

  Future<void> registerSpeedViolations({required double speedLimitKmH, required int speedLimitTimeout}) {
    return _channel.invokeMethod('registerSpeedViolations', {'speedLimitKmH': speedLimitKmH, 'speedLimitTimeout': speedLimitTimeout});
  }

/// iOS Specific methods
  Future<ApiLanguage?> getApiLanguage() {
    _ensureIOS();
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
    _ensureIOS();
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

  /// `SDK can work in two modes`:
  /// `Aggressive` - heartbeats are sent every 20 minutes and SDK never sleeps.
  /// `Normal` - heartbeats are sent every 20 minutes but when system suspends SDK,
  ///  it gees to a sleep mode and will restore work only in trip start time.
  Future<bool?> isAggressiveHeartbeat() {
    _ensureIOS();
    return _channel.invokeMethod('isAggressiveHeartbeat');
  }

  Future<void> setAggressiveHeartbeats({required bool value}) {
    _ensureIOS();
    return _channel.invokeMethod('setAggressiveHeartbeats', {'value': value});
  }

  Future<void> setDisableTracking({required bool value}) {
    _ensureIOS();
    return _channel.invokeMethod('setDisableTracking', {'value': value});
  }

  Future<bool?> isDisableTracking() {
    _ensureIOS();
    return _channel.invokeMethod('isDisableTracking');
  }

  Future<bool?> isWrongAccuracyState() {
    _ensureIOS();
    return _channel.invokeMethod('isWrongAccuracyState');
  }

  Future<bool?> requestIOSLocationAlwaysPermission() {
    _ensureIOS();
    return _channel.invokeMethod('requestIOSLocationAlwaysPermission');
  }

  Future<bool?> requestIOSMotionPermission() {
    _ensureIOS();
    return _channel.invokeMethod('requestIOSMotionPermission');
  }

  ///Android specific
  Future<void> setAndroidAutoStartEnabled({required bool enable, required bool permanent}) {
    _ensureAndroid();
    return _channel.invokeMethod('setAndroidAutoStartEnabled', {'enable': enable, 'permanent': permanent});
  }

  Future<bool?> isAndroidAutoStartEnabled() {
    _ensureAndroid();
    return _channel.invokeMethod('isAndroidAutoStartEnabled');
  }

  void _ensureIOS() {
    if (!Platform.isIOS) {
      throw UnsupportedError('This method is only available on iOS.');
    }
  }

  void _ensureAndroid() {
    if (!Platform.isAndroid) {
      throw UnsupportedError('This method is only available on Android.');
    }
  }
}
