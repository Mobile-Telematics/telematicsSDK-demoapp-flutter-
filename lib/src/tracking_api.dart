import 'dart:async';

import 'package:flutter/services.dart';
import 'package:telematics_sdk/src/permission_wizard_result.dart';

class TrackingApi {
  TrackingApi() {
    _channel.setMethodCallHandler(_nativeCallsHandler);
  }

  static const _channel = MethodChannel('telematics_sdk');

  final _onPermissionWizardClose =
      StreamController<PermissionWizardResult>.broadcast();

  Stream<PermissionWizardResult> get onPermissionWizardClose =>
      _onPermissionWizardClose.stream;

  Future<void> clearDeviceID() => _channel.invokeMethod('clearDeviceID');

  Future<String?> getDeviceId() => _channel.invokeMethod('getDeviceId');

  Future<bool?> isAllRequiredPermissionsAndSensorsGranted() =>
      _channel.invokeMethod('isAllRequiredPermissionsAndSensorsGranted');

  Future<bool?> isSdkEnabled() => _channel.invokeMethod('isSdkEnabled');

  Future<bool?> isTracking() => _channel.invokeMethod('isTracking');

  Future<void> setDeviceID({required String deviceId}) =>
      _channel.invokeMethod('setDeviceID', {'deviceId': deviceId});

  Future<void> setEnableSdk({required bool enable}) =>
      _channel.invokeMethod('setEnableSdk', {'enable': enable});

  Future<bool?> startTracking() => _channel.invokeMethod('startTracking');

  Future<bool?> stopTracking() => _channel.invokeMethod('stopTracking');

  Future<void> showPermissionWizard(
          {required bool enableAggressivePermissionsWizard,
          required bool enableAggressivePermissionsWizardPage}) =>
      _channel.invokeMethod('showPermissionWizard', {
        'enableAggressivePermissionsWizard': enableAggressivePermissionsWizard,
        'enableAggressivePermissionsWizardPage':
            enableAggressivePermissionsWizardPage,
      });

  Future<Object> _nativeCallsHandler(MethodCall call) async {
    if (call.method == 'onPermissionWizardResult') {
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

    return Object();
  }
}
