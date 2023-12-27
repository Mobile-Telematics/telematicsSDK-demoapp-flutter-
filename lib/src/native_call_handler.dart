import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:telematics_sdk/src/data/tag.dart';
import 'package:telematics_sdk/src/data/status.dart';
import 'package:telematics_sdk/src/data/future_track_callbacks.dart';
import 'package:telematics_sdk/src/data/permission_wizard_result.dart';
import 'package:telematics_sdk/src/data/track_location.dart';

import 'data/delegates_callbacks.dart';

class NativeCallHandler {
  OnTagAddCallback? onTagAdd;
  OnTagRemoveCallback? onTagRemove;
  OnAllTagsRemoveCallback? onAllTagsRemove;
  OnGetTagsCallback? onGetTags;

  Stream<PermissionWizardResult> get onPermissionWizardClose =>
      _onPermissionWizardClose.stream;
  Stream<bool> get lowerPowerMode => _onLowerPowerMode.stream;
  Stream<TrackLocation> get locationChanged => _onLocationChanged.stream;
  //Stream<bool> get newEvents => _onNewEvents.stream; //TO DO
  // Stream<void> get wrongAccuracyAuthorization => //TO DO
  //     _onWrongAccuracyAuthorization.stream;
  Stream<bool> get trackingStateChanged => _onTrackingStateChanged.stream;
  Stream<String> get logEvent => _onLogEvent.stream;
  Stream<String> get logWarning => _onLogWarning.stream;
  Stream<SpeedLimitNotificationResult> get speedLimitNotification =>
      _onSpeedLimitNotification.stream;
  Stream<HeartbeatSentResult> get heartbeatSent => _onHeartbeatSent.stream;
  Stream<bool> get rtldCollectedData => _onRtldCollectedData.stream;

  Future<Object> handle(MethodCall call) async {
    switch (call.method) {
      case 'onPermissionWizardResult':
        _onPermissionWizardResult(call);
        break;
      case 'onLowPowerMode':
        _onLowPowerMode(call);
        break;
      case 'onLocationChanged':
        _onLocationChangedHandler(call);
        break;
      case 'onNewEvents':
        _onNewEventsHandler(call);
        break;
      case 'onWrongAccuracyAuthorization':
        _onWrongAccuracyAuthorizationHandler(call);
        break;
      case 'onTrackingStateChanged':
        _onTrackingStateChangedHandler(call);
        break;
      case 'onLogEvent':
        _onLogEventHandler(call);
        break;
      case 'onLogWarning':
        _onLogWarningHandler(call);
        break;
      case 'onSpeedLimitNotification':
        _onSpeedLimitNotificationHandler(call);
        break;
      case 'onHeartbeatSent':
        _onHeartbeatSentHandler(call);
        break;
      case 'onRtldCollectedData':
        _onRtldCollectedDataHandler(call);
        break;

      case 'onTagAdd':
        _onTagAdd(call);
        break;
      case 'onTagRemove':
        _onTagRemove(call);
        break;
      case 'onAllTagsRemove':
        _onAllTagsRemove(call);
        break;
      case 'onGetTags':
        _onGetTags(call);
        break;
    }
    return Object();
  }

  final _onPermissionWizardClose =
      StreamController<PermissionWizardResult>.broadcast();
  final _onLowerPowerMode = StreamController<bool>.broadcast();

  final _onLocationChanged = StreamController<TrackLocation>.broadcast();
  //final _onNewEvents = StreamController<bool>.broadcast(); //TO DO
  //final _onWrongAccuracyAuthorization = StreamController<void>.broadcast(); //TO DO
  final _onTrackingStateChanged = StreamController<bool>.broadcast();
  final _onLogEvent = StreamController<String>.broadcast();
  final _onLogWarning = StreamController<String>.broadcast();
  final _onSpeedLimitNotification =
      StreamController<SpeedLimitNotificationResult>.broadcast();
  final _onHeartbeatSent = StreamController<HeartbeatSentResult>.broadcast();
  final _onRtldCollectedData = StreamController<bool>.broadcast();

  void _onPermissionWizardResult(MethodCall call) {
    const wizardResultMapping = {
      'WIZARD_RESULT_ALL_GRANTED': PermissionWizardResult.allGranted,
      'WIZARD_RESULT_NOT_ALL_GRANTED': PermissionWizardResult.notAllGranted,
      'WIZARD_RESULT_CANCELED': PermissionWizardResult.canceled,
    };

    final argument = call.arguments as String;
    if (wizardResultMapping.containsKey(argument)) {
      _onPermissionWizardClose.add(wizardResultMapping[argument]!);
    }
  }

  void _onLowPowerMode(MethodCall call) {
    final state = call.arguments as bool;
    _onLowerPowerMode.add(state);
  }

  void _onLocationChangedHandler(MethodCall call) {
    final latitude = call.arguments['latitude'] as double;
    final longitude = call.arguments['longitude'] as double;
    final location = TrackLocation(latitude: latitude, longitude: longitude);
    _onLocationChanged.add(location);
  }

  void _onNewEventsHandler(MethodCall call) {} //TO DO

  void _onWrongAccuracyAuthorizationHandler(MethodCall call) {} //TO DO

  void _onTrackingStateChangedHandler(MethodCall call) {
    final state = call.arguments as bool;
    _onTrackingStateChanged.add(state);
  }

  void _onLogEventHandler(MethodCall call) {
    final state = call.arguments as String;
    _onLogEvent.add(state);
  }

  void _onLogWarningHandler(MethodCall call) {
    final state = call.arguments as String;
    _onLogWarning.add(state);
  }

  void _onSpeedLimitNotificationHandler(MethodCall call) {
    final speedLimit = call.arguments['speedLimit'] as double;
    final speed = call.arguments['speed'] as double;
    final latitude = call.arguments['latitude'] as double;
    final longitude = call.arguments['longitude'] as double;
    final dateUtc = call.arguments['date'] as String;
    final result = SpeedLimitNotificationResult(
        speedLimit: speedLimit,
        speed: speed,
        latitude: latitude,
        longitude: longitude,
        date: dateUtc);
    _onSpeedLimitNotification.add(result);
  }

  void _onHeartbeatSentHandler(MethodCall call) {
    final state = call.arguments['state'] as bool;
    final success = call.arguments['success'] as bool;
    final result = HeartbeatSentResult(state: state, success: success);
    _onHeartbeatSent.add(result);
  }

  void _onRtldCollectedDataHandler(MethodCall call) {
    final state = call.arguments as bool;
    _onRtldCollectedData.add(state);
  }

  void _onTagAdd(MethodCall call) {
    final _status = call.arguments['status'] as String;
    final _tagString = call.arguments['tag'] as String;

    final _tag = jsonDecode(_tagString) as Map<String, dynamic>;

    final status = Status.fromString(_status);
    final tag = Tag.fromJson(_tag);
    final activationTime = call.arguments['activationTime'] as int;

    onTagAdd?.call(status, tag, activationTime);
  }

  void _onTagRemove(MethodCall call) {
    final _status = call.arguments['status'] as String;
    final _tagString = call.arguments['tag'] as String;

    final _tag = jsonDecode(_tagString) as Map<String, dynamic>;

    final status = Status.fromString(_status);
    final tag = Tag.fromJson(_tag);
    final deactivationTime = call.arguments['deactivationTime'] as int;

    onTagRemove?.call(status, tag, deactivationTime);
  }

  void _onAllTagsRemove(MethodCall call) {
    final _status = call.arguments['status'] as String;

    final status = Status.fromString(_status);
    final deactivatedTagsCount = call.arguments['deactivatedTagsCount'] as int;
    final time = call.arguments['time'] as int;

    onAllTagsRemove?.call(status, deactivatedTagsCount, time);
  }

  void _onGetTags(MethodCall call) {
    final _status = call.arguments['status'] as String;
    final _tags = call.arguments['tags'] as List<String>?;

    final status = Status.fromString(_status);
    final tags = _tags
        ?.map((e) => Tag.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    final time = call.arguments['time'] as int;

    onGetTags?.call(status, tags, time);
  }
}
