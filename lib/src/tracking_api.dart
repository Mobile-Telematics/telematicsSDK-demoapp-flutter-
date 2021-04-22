import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:telematics_sdk/src/data/track_tag.dart';
import 'package:telematics_sdk/src/native_call_handler.dart';
import 'package:telematics_sdk/src/data/future_track_callbacks.dart';
import 'package:telematics_sdk/src/data/permission_wizard_result.dart';

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

  Future<void> clearDeviceID() => _channel.invokeMethod('clearDeviceID');

  Future<String?> getDeviceId() => _channel.invokeMethod('getDeviceId');

  Future<bool?> isAllRequiredPermissionsAndSensorsGranted() =>
      _channel.invokeMethod('isAllRequiredPermissionsAndSensorsGranted');

  Future<bool?> isSdkEnabled() => _channel.invokeMethod('isSdkEnabled');

  Future<bool?> isTracking() => _channel.invokeMethod('isTracking');

  Future<void> setDeviceID({required String deviceId}) =>
      _channel.invokeMethod('setDeviceID', {'deviceId': deviceId});

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
  Future<bool?> setAggressiveHeartbeats({required bool value}) =>
      _channel.invokeMethod('setAggressiveHeartbeats', {'value': value});

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
}
