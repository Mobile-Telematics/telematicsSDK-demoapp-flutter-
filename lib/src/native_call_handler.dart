import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:telematics_sdk/src/data/models/tag.dart';
import 'package:telematics_sdk/src/data/models/status.dart';
import 'package:telematics_sdk/src/data/future_track_callbacks.dart';
import 'package:telematics_sdk/src/data/models/permission_wizard_result.dart';
import 'package:telematics_sdk/src/data/models/track_location.dart';

class NativeCallHandler {
  OnTagAddCallback? onTagAdd;
  OnTagRemoveCallback? onTagRemove;
  OnAllTagsRemoveCallback? onAllTagsRemove;
  OnGetTagsCallback? onGetTags;

  Stream<PermissionWizardResult> get onPermissionWizardClose =>
      _onPermissionWizardClose.stream;
  Stream<bool> get lowPowerMode => _onLowPowerMode.stream;
  Stream<TrackLocation> get locationChanged => _onLocationChanged.stream;
  Stream<bool> get trackingStateChanged => _onTrackingStateChanged.stream;
  Stream<void> get iOSWrongAccuracyAuthorization => _onIOSWrongAccuracyAuthorization.stream;
  Stream<void> get iOSRTLDDataCollected => _onIOSRTLDDataCollected.stream;

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
    final time = call.arguments['time'] as int;

    onAllTagsRemove?.call(status, time);
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
