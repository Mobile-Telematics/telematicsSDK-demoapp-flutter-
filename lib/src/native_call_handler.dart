import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:telematics_sdk/src/data/tag.dart';
import 'package:telematics_sdk/src/data/status.dart';
import 'package:telematics_sdk/src/data/future_track_callbacks.dart';
import 'package:telematics_sdk/src/data/permission_wizard_result.dart';

class NativeCallHandler {
  OnTagAddCallback? onTagAdd;
  OnTagRemoveCallback? onTagRemove;
  OnAllTagsRemoveCallback? onAllTagsRemove;
  OnGetTagsCallback? onGetTags;

  Stream<PermissionWizardResult> get onPermissionWizardClose =>
      _onPermissionWizardClose.stream;
  Stream<bool> get lowerPowerMode => _onLowerPowerMode.stream;

  Future<Object> handle(MethodCall call) async {
    switch (call.method) {
      case 'onPermissionWizardResult':
        _onPermissionWizardResult(call);
        break;
      case 'onLowPowerMode':
        _onLowPowerMode(call);
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
