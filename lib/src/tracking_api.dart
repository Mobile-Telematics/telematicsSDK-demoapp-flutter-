import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:telematics_sdk/src/data/accident_detection_sensitivity.dart';
import 'package:telematics_sdk/src/data/api_language.dart';
import 'package:telematics_sdk/src/data/future_track_tag_result.dart';
import 'package:telematics_sdk/src/data/tracking_mode.dart';
import 'package:telematics_sdk/src/data/models/device_id_registration_state.dart';
import 'package:telematics_sdk/src/data/models/permission_wizard_result.dart';
import 'package:telematics_sdk/src/data/models/speed_violation.dart';
import 'package:telematics_sdk/src/data/models/track_location.dart';
import 'package:telematics_sdk/src/data/models/tracking_state.dart';
import 'package:telematics_sdk/src/native_call_handler.dart';

/// High-level Flutter API for interacting with the native Telematics SDK.
///
/// `TrackingApi` is a thin wrapper around a platform `MethodChannel` and exposes:
/// - **Commands** (methods) to control SDK lifecycle and tracking.
/// - **Streams** to receive asynchronous events emitted by the native SDK.
///
/// Most methods forward to the underlying platform implementation.
/// Platform-specific methods will throw an [UnsupportedError] when called on the wrong platform.
///
/// Typical usage:
/// 1. Ensure the SDK is initialized on the native side.
/// 2. Call [setDeviceID] to set the virtual device token/device id.
/// 3. Start tracking with [startManualTracking] or [startTrackAsPersistent].
/// 4. Listen to streams like [trackingStateChanged], [locationChanged], and
///    iOS-specific signals such as [iOSWrongAccuracyAuthorization].
class TrackingApi {
  static const _channel = MethodChannel('telematics_sdk');
  final NativeCallHandler _handler = NativeCallHandler();

  TrackingApi() {
    _channel.setMethodCallHandler(_handler.handle);
  }

  /// Emits when the native permission wizard flow is closed.
  ///
  /// The event contains the final wizard result/state.
  Stream<PermissionWizardResult> get onPermissionWizardClose =>
      _handler.onPermissionWizardClose;

  /// Emits `true` when the device enters Low Power Mode and `false` when it exits.
  Stream<bool> get lowPowerMode => _handler.lowPowerMode;

  /// Emits location updates produced by the native SDK while tracking is active.
  ///
  /// The stream is driven by the native side and may pause/resume depending on
  /// permissions, tracking state, and OS constraints.
  Stream<TrackLocation> get locationChanged => _handler.locationChanged;

  /// Emits tracking state changes (`true` = tracking started, `false` = tracking stopped).
  Stream<bool> get trackingStateChanged => _handler.trackingStateChanged;

  /// iOS only: emits when the SDK detects that precise location is not available
  /// (e.g., the user granted Reduced Accuracy).
  ///
  /// Use this to prompt the user to enable Precise Location in system settings.
  ///
  /// Throws [UnsupportedError] if called on a non-iOS platform.
  Stream<void> get iOSWrongAccuracyAuthorization =>
      _handler.iOSWrongAccuracyAuthorization;

  /// iOS only: emits when RTLD (real-time data logging) has collected a data chunk.
  ///
  /// Throws [UnsupportedError] if called on a non-iOS platform.
  Stream<void> get iOSRTLDDataCollected => _handler.iOSRTLDDataCollected;

  /// Emits speed violation events produced by the native SDK.
  ///
  /// Configure monitoring via [registerSpeedViolations].
  Stream<SpeedViolation> get speedViolation => _handler.speedViolation;

  /// Emits the native SDK result for [addFutureTrackTag].
  Stream<FutureTrackTagAddResult> get futureTrackTagAdded =>
      _handler.futureTrackTagAdded;

  /// Emits the native SDK result for [removeFutureTrackTag].
  Stream<FutureTrackTagRemoveResult> get futureTrackTagRemoved =>
      _handler.futureTrackTagRemoved;

  /// Emits the native SDK result for [removeAllFutureTrackTags].
  Stream<FutureTrackTagsRemoveResult> get allFutureTrackTagsRemoved =>
      _handler.allFutureTrackTagsRemoved;

  /// Emits the native SDK result for [getFutureTrackTags].
  Stream<FutureTrackTagsResult> get futureTrackTagsReceived =>
      _handler.futureTrackTagsReceived;

  /// Returns whether the native SDK is initialized.
  ///
  /// Returns `true` if the SDK has been initialized on the native side; otherwise `false`.
  Future<bool?> isInitialized() => _channel.invokeMethod('isInitialized');

  /// Returns the current virtual device identifier (token) configured in the native SDK.
  ///
  /// The value is platform-defined and may be `null` if not set.
  Future<String?> getDeviceId() => _channel.invokeMethod('getDeviceId');

  /// Returns the latest known device identifier registration state.
  ///
  /// [DeviceIdRegistrationState.checkedAtMillis] is a Unix timestamp in
  /// milliseconds. A value of `0` means the registration state has not been
  /// checked yet.
  Future<DeviceIdRegistrationState> getDeviceIdRegistrationState() {
    return _channel
        .invokeMapMethod<dynamic, dynamic>('getDeviceIdRegistrationState')
        .then((value) => DeviceIdRegistrationState.fromJson(value ?? const {}));
  }

  /// Returns the current automatic and manual tracking availability state.
  ///
  Future<TrackingState> getTrackingState() {
    return _channel
        .invokeMapMethod<dynamic, dynamic>('getTrackingState')
        .then((value) => TrackingState.fromJson(value ?? const {}));
  }

  /// Sets the virtual device identifier (token) used by the native SDK.
  ///
  /// Passing a non-empty value typically associates the SDK session with a backend user/device.
  ///
  /// - Parameter deviceId: The virtual device token/identifier.
  Future<void> setDeviceID({required String deviceId}) =>
      _channel.invokeMethod('setDeviceID', {'deviceId': deviceId});

  /// Performs a full logout on the native SDK.
  ///
  /// Typically disables the SDK and clears the stored device token.
  Future<void> logout() => _channel.invokeMethod('logout');

  /// Checks whether all required permissions and sensors are granted/available.
  ///
  /// This usually includes Location + Motion (and other platform-specific requirements).
  Future<bool?> isAllRequiredPermissionsAndSensorsGranted() =>
      _channel.invokeMethod('isAllRequiredPermissionsAndSensorsGranted');

  /// Returns whether the native SDK is currently enabled.
  Future<bool?> isSdkEnabled() => _channel.invokeMethod('isSdkEnabled');

  /// Returns whether tracking is currently active on the native side.
  Future<bool?> isTracking() => _channel.invokeMethod('isTracking');

  /// Enables or disables the native SDK globally.
  ///
  /// Disabling the SDK typically stops tracking and background activity.
  ///
  /// - Parameter enable: `true` to enable, `false` to disable.
  Future<void> setEnableSdk({required bool enable}) {
    return _channel.invokeMethod('setEnableSdk', {'enable': enable});
  }

  /// Starts tracking manually.
  ///
  /// Returns `true` if tracking was started, `false` if it was already running,
  /// or `null` if the platform did not provide a result.
  Future<bool?> startManualTracking() =>
      _channel.invokeMethod('startManualTracking');

  /// Starts persistent tracking manually (continues across background/app restarts).
  ///
  /// Returns `true` if tracking was started, `false` if it was already running,
  /// or `null` if the platform did not provide a result.
  Future<bool?> startTrackAsPersistent() =>
      _channel.invokeMethod('startTrackAsPersistent');

  /// Stops tracking manually.
  ///
  /// Returns `true` if tracking was stopped, `false` if it was not running,
  /// or `null` if the platform did not provide a result.
  Future<bool?> stopManualTracking() =>
      _channel.invokeMethod('stopManualTracking');

  /// Sets the maximum duration for a single persistent tracking session.
  ///
  /// The value is expressed in minutes. Native SDKs allow values from 5 to 600.
  Future<void> setMaxPersistentTrackingInterval({required int minutes}) {
    return _channel.invokeMethod('setMaxPersistentTrackingInterval', {
      'minutes': minutes,
    });
  }

  /// Returns the maximum duration, in minutes, for a single persistent tracking session.
  Future<int?> getMaxPersistentTrackingInterval() {
    return _channel.invokeMethod<int>('getMaxPersistentTrackingInterval');
  }

  /// Sets whether SDK-started and manually-started tracking runs in standard or persistent mode.
  Future<void> setTrackingMode({required TrackingMode trackingMode}) {
    return _channel.invokeMethod('setTrackingMode', {
      'trackingMode': _trackingModeToValue(trackingMode),
    });
  }

  /// Returns the current tracking mode.
  Future<TrackingMode?> getTrackingMode() {
    return _channel
        .invokeMethod<int>('getTrackingMode')
        .then(_trackingModeFromValue);
  }

  /// Triggers upload of locally stored, unsent trips if any.
  Future<void> uploadUnsentTrips() =>
      _channel.invokeMethod('uploadUnsentTrips');

  /// Returns the number of unsent trips currently stored locally by the native SDK.
  Future<int?> getUnsentTripCount() =>
      _channel.invokeMethod('getUnsentTripCount');

  /// Sends a custom heartbeat to the native SDK with an application-defined reason.
  ///
  /// - Parameter reason: A string used for analytics on the backend.
  Future<void> sendCustomHeartbeats({required String reason}) {
    return _channel.invokeMethod('sendCustomHeartbeats', {'reason': reason});
  }

  /// Shows the native permissions wizard UI.
  /// - Parameter enableAggressivePermissionsWizard: If `true`, the wizard finishes only
  ///   when all required permissions are granted.
  /// - Parameter enableAggressivePermissionsWizardPage: If `true`, the wizard auto-advances
  ///   when permissions are granted on the current page.
  Future<void> showPermissionWizard({
    required bool enableAggressivePermissionsWizard,
    required bool enableAggressivePermissionsWizardPage,
  }) => _channel.invokeMethod('showPermissionWizard', {
    'enableAggressivePermissionsWizard': enableAggressivePermissionsWizard,
    'enableAggressivePermissionsWizardPage':
        enableAggressivePermissionsWizardPage,
  });

  /// Requests the current list of Future Track tags from the native SDK.
  ///
  /// Results are delivered via [futureTrackTagsReceived].
  Future<void> getFutureTrackTags() =>
      _channel.invokeMethod('getFutureTrackTags');

  /// Adds a Future Track tag.
  ///
  /// - Parameter tag: Tag identifier.
  /// - Parameter source: Optional arbitrary source string (e.g. feature/module name).
  Future<void> addFutureTrackTag({required String tag, String? source}) {
    return _channel.invokeMethod('addFutureTrackTag', {
      'tag': tag,
      'source': source,
    });
  }

  /// Removes a Future Track tag.
  ///
  /// - Parameter tag: Tag identifier.
  /// - Parameter source: Optional arbitrary source string. Used by iOS and ignored by Android.
  Future<void> removeFutureTrackTag({required String tag, String? source}) {
    return _channel.invokeMethod('removeFutureTrackTag', {
      'tag': tag,
      'source': source,
    });
  }

  /// Removes all Future Track tags.
  Future<void> removeAllFutureTrackTags() =>
      _channel.invokeMethod('removeAllFutureTrackTags');

  /// Sets accident detection sensitivity in the native SDK.
  ///
  /// Higher sensitivity may detect more events but can increase false positives.
  Future<void> setAccidentDetectionSensitivity({
    required AccidentDetectionSensitivity sensitivity,
  }) {
    int value = 0;
    switch (sensitivity) {
      case AccidentDetectionSensitivity.normal:
        value = 0;
      case AccidentDetectionSensitivity.sensitive:
        value = 1;
      case AccidentDetectionSensitivity.tough:
        value = 2;
    }
    return _channel.invokeMethod('setAccidentDetectionSensitivity', {
      'accidentDetectionSensitivity': value,
    });
  }

  /// Returns whether RTLD (real-time data logging) is enabled in the native SDK.
  Future<bool?> isRTLDEnabled() => _channel.invokeMethod('isRTLDEnabled');

  /// Enables or disables accident detection in the native SDK.
  ///
  /// - Parameter value: `true` to enable, `false` to disable.
  Future<void> setAccidentDetectionEnabled({required bool value}) => _channel
      .invokeMethod('setAccidentDetectionEnabled', {'enableAccidents': value});

  /// Returns whether accident detection is enabled in the native SDK.
  Future<bool?> isAccidentDetectionEnabled() =>
      _channel.invokeMethod('isAccidentDetectionEnabled');

  /// Enables speed limit monitoring and configures speed violation parameters.
  ///
  /// - Parameter speedLimitKmH: Speed limit in km/h.
  /// - Parameter speedLimitTimeout: Timeout in seconds before emitting another violation.
  ///
  /// Speed violation events are delivered via the [speedViolation] stream.
  Future<void> registerSpeedViolations({
    required double speedLimitKmH,
    required int speedLimitTimeout,
  }) {
    return _channel.invokeMethod('registerSpeedViolations', {
      'speedLimitKmH': speedLimitKmH,
      'speedLimitTimeout': speedLimitTimeout,
    });
  }

  /// iOS only: returns the API language configured in the native SDK.
  ///
  /// Throws [UnsupportedError] if called on a non-iOS platform.
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

  /// iOS only: sets the API language used by the native SDK.
  ///
  /// Throws [UnsupportedError] if called on a non-iOS platform.
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
    return _channel.invokeMethod('setApiLanguage', {
      'apiLanguage': apiLanguage,
    });
  }

  /// iOS only: returns whether aggressive heartbeat mode is enabled.
  ///
  /// Throws [UnsupportedError] if called on a non-iOS platform.
  Future<bool?> isAggressiveHeartbeats() {
    _ensureIOS();
    return _channel.invokeMethod('isAggressiveHeartbeats');
  }

  /// iOS only: enables or disables aggressive heartbeat mode.
  ///
  /// Throws [UnsupportedError] if called on a non-iOS platform.
  Future<void> setAggressiveHeartbeats({required bool value}) {
    _ensureIOS();
    return _channel.invokeMethod('setAggressiveHeartbeats', {'value': value});
  }

  /// iOS only: disables or enables user-initiated tracking.
  ///
  /// Throws [UnsupportedError] if called on a non-iOS platform.
  Future<void> setDisableTracking({required bool value}) {
    _ensureIOS();
    return _channel.invokeMethod('setDisableTracking', {'value': value});
  }

  /// iOS only: returns whether user-initiated tracking is disabled.
  ///
  /// Throws [UnsupportedError] if called on a non-iOS platform.
  Future<bool?> isDisableTracking() {
    _ensureIOS();
    return _channel.invokeMethod('isDisableTracking');
  }

  /// iOS only: returns whether the native SDK considers current location accuracy insufficient.
  ///
  /// Throws [UnsupportedError] if called on a non-iOS platform.
  Future<bool?> isWrongAccuracyState() {
    _ensureIOS();
    return _channel.invokeMethod('isWrongAccuracyState');
  }

  /// iOS only: requests "Always" location permission from the system.
  ///
  /// Throws [UnsupportedError] if called on a non-iOS platform.
  Future<bool?> requestIOSLocationAlwaysPermission() {
    _ensureIOS();
    return _channel.invokeMethod('requestIOSLocationAlwaysPermission');
  }

  /// iOS only: requests Motion/Fitness permission from the system.
  ///
  /// Throws [UnsupportedError] if called on a non-iOS platform.
  Future<bool?> requestIOSMotionPermission() {
    _ensureIOS();
    return _channel.invokeMethod('requestIOSMotionPermission');
  }

  /// Android only: enables or disables SDK autostart behavior.
  ///
  /// - Parameter enable: Whether autostart is enabled.
  /// - Parameter permanent: Whether the choice should be persisted permanently.
  ///
  /// Throws [UnsupportedError] if called on a non-Android platform.
  Future<void> setAndroidAutoStartEnabled({
    required bool enable,
    required bool permanent,
  }) {
    _ensureAndroid();
    return _channel.invokeMethod('setAndroidAutoStartEnabled', {
      'enable': enable,
      'permanent': permanent,
    });
  }

  /// Android only: returns whether SDK autostart is enabled.
  ///
  /// Throws [UnsupportedError] if called on a non-Android platform.
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

  int _trackingModeToValue(TrackingMode trackingMode) {
    switch (trackingMode) {
      case TrackingMode.standard:
        return 0;
      case TrackingMode.persistent:
        return 1;
    }
  }

  TrackingMode? _trackingModeFromValue(int? value) {
    switch (value) {
      case 0:
        return TrackingMode.standard;
      case 1:
        return TrackingMode.persistent;
      default:
        return null;
    }
  }
}
