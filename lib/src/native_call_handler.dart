import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:telematics_sdk/src/data/future_track_tag_result.dart';
import 'package:telematics_sdk/src/data/models/speed_violation.dart';
import 'package:telematics_sdk/src/data/models/tag.dart';
import 'package:telematics_sdk/src/data/models/status.dart';
import 'package:telematics_sdk/src/data/models/permission_wizard_result.dart';
import 'package:telematics_sdk/src/data/models/track_location.dart';

class NativeCallHandler {
  Stream<PermissionWizardResult> get onPermissionWizardClose =>
      _onPermissionWizardClose.stream;
  Stream<bool> get lowPowerMode => _onLowPowerMode.stream;
  Stream<TrackLocation> get locationChanged => _onLocationChanged.stream;
  Stream<bool> get trackingStateChanged => _onTrackingStateChanged.stream;
  Stream<void> get iOSWrongAccuracyAuthorization =>
      _onIOSWrongAccuracyAuthorization.stream;
  Stream<void> get iOSRTLDDataCollected => _onIOSRTLDDataCollected.stream;
  Stream<SpeedViolation> get speedViolation => _onSpeedViolation.stream;
  Stream<FutureTrackTagAddResult> get futureTrackTagAdded =>
      _onFutureTrackTagAdded.stream;
  Stream<FutureTrackTagRemoveResult> get futureTrackTagRemoved =>
      _onFutureTrackTagRemoved.stream;
  Stream<FutureTrackTagsRemoveResult> get allFutureTrackTagsRemoved =>
      _onAllFutureTrackTagsRemoved.stream;
  Stream<FutureTrackTagsResult> get futureTrackTagsReceived =>
      _onFutureTrackTagsReceived.stream;

  Future<Object> handle(MethodCall call) async {
    switch (call.method) {
      case 'onTrackingStateChanged':
        _onTrackingStateChangedHandler(call);
        break;
      case 'onPermissionWizardResult':
        _onPermissionWizardResult(call);
        break;
      case 'onLowPowerMode':
        _onLowPowerModeHandler(call);
        break;
      case 'onLocationChanged':
        _onLocationChangedHandler(call);
        break;
      case 'onWrongAccuracyAuthorization':
        _onIOSWrongAccuracyAuthorizationHandler(call);
        break;
      case 'onRTLDCollectedData':
        _onIOSRTLDCollectedDataHandler(call);
      case 'onSpeedViolation':
        _onSpeedViolationHandler(call);
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
  final _onLowPowerMode = StreamController<bool>.broadcast();
  final _onLocationChanged = StreamController<TrackLocation>.broadcast();
  final _onTrackingStateChanged = StreamController<bool>.broadcast();
  final _onIOSWrongAccuracyAuthorization = StreamController<void>.broadcast();
  final _onIOSRTLDDataCollected = StreamController<void>.broadcast();
  final _onSpeedViolation = StreamController<SpeedViolation>.broadcast();
  final _onFutureTrackTagAdded =
      StreamController<FutureTrackTagAddResult>.broadcast();
  final _onFutureTrackTagRemoved =
      StreamController<FutureTrackTagRemoveResult>.broadcast();
  final _onAllFutureTrackTagsRemoved =
      StreamController<FutureTrackTagsRemoveResult>.broadcast();
  final _onFutureTrackTagsReceived =
      StreamController<FutureTrackTagsResult>.broadcast();

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

  void _onTrackingStateChangedHandler(MethodCall call) {
    final state = call.arguments as bool;
    _onTrackingStateChanged.add(state);
  }

  void _onLowPowerModeHandler(MethodCall call) {
    final state = call.arguments as bool;
    _onLowPowerMode.add(state);
  }

  void _onIOSWrongAccuracyAuthorizationHandler(MethodCall call) {
    _onIOSWrongAccuracyAuthorization.add(null);
  }

  void _onIOSRTLDCollectedDataHandler(MethodCall call) {
    _onIOSRTLDDataCollected.add(null);
  }

  void _onLocationChangedHandler(MethodCall call) {
    final latitude = call.arguments['latitude'] as double;
    final longitude = call.arguments['longitude'] as double;
    final location = TrackLocation(latitude: latitude, longitude: longitude);
    _onLocationChanged.add(location);
  }

  void _onSpeedViolationHandler(MethodCall call) {
    final date = call.arguments['date'] as int;
    final latitude = call.arguments['latitude'] as double;
    final longitude = call.arguments['longitude'] as double;
    final speed = call.arguments['speed'] as double;
    final speedLimit = call.arguments['speedLimit'] as double;
    final speedViolation = SpeedViolation(
      date: date,
      latitude: latitude,
      longitude: longitude,
      speed: speed,
      speedLimit: speedLimit,
    );
    _onSpeedViolation.add(speedViolation);
  }

  void _onTagAdd(MethodCall call) {
    final _status = call.arguments['status'] as String;
    final _tagString = call.arguments['tag'] as String;

    final _tag = jsonDecode(_tagString) as Map<String, dynamic>;

    final status = Status.fromString(_status);
    final tag = Tag.fromJson(_tag);
    final activationTime = call.arguments['activationTime'] as int;

    _onFutureTrackTagAdded.add(
      FutureTrackTagAddResult(
        status: status,
        tag: tag,
        activationTime: activationTime,
      ),
    );
  }

  void _onTagRemove(MethodCall call) {
    final _status = call.arguments['status'] as String;
    final _tagString = call.arguments['tag'] as String;

    final _tag = jsonDecode(_tagString) as Map<String, dynamic>;

    final status = Status.fromString(_status);
    final tag = Tag.fromJson(_tag);
    final deactivationTime = call.arguments['deactivationTime'] as int;

    _onFutureTrackTagRemoved.add(
      FutureTrackTagRemoveResult(
        status: status,
        tag: tag,
        deactivationTime: deactivationTime,
      ),
    );
  }

  void _onAllTagsRemove(MethodCall call) {
    final _status = call.arguments['status'] as String;

    final status = Status.fromString(_status);
    final time = call.arguments['time'] as int;

    _onAllFutureTrackTagsRemoved.add(
      FutureTrackTagsRemoveResult(status: status, time: time),
    );
  }

  void _onGetTags(MethodCall call) {
    final _status = call.arguments['status'] as String;
    final _tagStrings = (call.arguments['tags'] as List?)?.cast<String>();

    final status = Status.fromString(_status);
    final tags = _tagStrings
        ?.map((e) => Tag.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    final time = call.arguments['time'] as int;

    _onFutureTrackTagsReceived.add(
      FutureTrackTagsResult(status: status, tags: tags, time: time),
    );
  }
}
