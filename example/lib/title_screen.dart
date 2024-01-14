import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telematics_sdk/telematics_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sizedBoxSpace = SizedBox(height: 24);

class TitleScreen extends StatefulWidget {
  TitleScreen({Key? key}) : super(key: key);

  @override
  _TitleScreenState createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  final _trackingApi = TrackingApi();
  late StreamSubscription<PermissionWizardResult?>
      _onPermissionWizardStateChanged;
  late StreamSubscription<bool> _onLowerPower;
  late StreamSubscription<TrackLocation> _onLocationChanged;

  var _deviceId = '';
  var _isSdkEnabled = false;
  var _isAllRequiredPermissionsGranted = false;
  var _isTracking = false;
  var _isManualTracking = false;
  var _isAggressiveHeartbeats = false;
  TrackLocation? _location;

  late final SharedPreferences _prefs;

  final _tokenEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _onPermissionWizardStateChanged =
        _trackingApi.onPermissionWizardClose.listen(_onPermissionWizardResult);
    _onLowerPower = _trackingApi.lowerPowerMode.listen(_onLowPowerResult);
    _onLocationChanged = _trackingApi.locationChanged.listen(_onLocationChangedResult);
    _tokenEditingController.addListener(_onDeviceTokenChanged);
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _prefs = await SharedPreferences.getInstance();

    final virtualDeviceToken = _prefs.getString('virtualDeviceToken');

    if (virtualDeviceToken != null && virtualDeviceToken.isNotEmpty) {
      _deviceId = virtualDeviceToken;
      _tokenEditingController.text = _deviceId;
    }

    _isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;
    _isAllRequiredPermissionsGranted =
        await _trackingApi.isAllRequiredPermissionsAndSensorsGranted() ?? false;

    _isTracking = _prefs.getBool('isTracking') ?? false;
    _isAggressiveHeartbeats = await _trackingApi.isAggressiveHeartbeat() ?? false;

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TelematicsSDK_demo'),
      ),
      body: ListView(
        shrinkWrap: false,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Text('SDK status: ${_isSdkEnabled ? 'Enabled' : 'Disabled'}'),
          Text(
            'Permissions: ${_isAllRequiredPermissionsGranted ? 'Granted' : 'Not granted'}',
          ),
          (Platform.isIOS) ? Text('Tracking: ${_isTracking ? 'Enabled' : 'Disabled'}') : SizedBox.shrink(),
          Text('Manual Tracking: ${_isManualTracking ? 'Started' : 'Not stated'}'),
          Text(_getCurrentLocation()),
          TextFormField(
            controller: _tokenEditingController,
            decoration: const InputDecoration(
              labelText: 'Virtual device token',
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            maxLengthEnforcement: MaxLengthEnforcement.none,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: !_isSdkEnabled ? _onEnableSDK : null,
                  child: const Text('Enable SDK'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSdkEnabled ? _onDisableSDK : null,
                  child: const Text('Disable SDK'),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _isSdkEnabled ? _onForceDisableSDK : null,
            child: const Text('Force Disable SDK with upload'),
          ),
          ElevatedButton(
            onPressed: !_isSdkEnabled && _deviceId.isNotEmpty ? _onLogout : null,
            child: const Text('Clear Device Token'),
          ),
          _sizedBoxSpace,
          ElevatedButton(
            onPressed: () async {
              await _onPermissionsSDK();
            },
            child: const Text('Start Permission Wizard'),
          ),
          _sizedBoxSpace,
          (Platform.isIOS) ? Row(
            children: [
              Expanded(
                child: const Text('Aggressive Heartbeats'),
              ),
              Switch.adaptive(
                  value: _isAggressiveHeartbeats,
                  onChanged: _isSdkEnabled ? _onAggressiveHeartbeats : null
              )
            ],
          ) : SizedBox.shrink(),
          (Platform.isIOS) ? Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: !_isTracking ? _onTrackingEnabled : null,
                  child: const Text('Enable Tracking'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isTracking ? _onTrackingDisabled : null,
                  child: const Text('Disable Tracking'),
                ),
              ),
            ],
          ) : SizedBox.shrink(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: !_isManualTracking ? _onStartManualTracking : null,
                  child: const Text(
                    'Start tracking manually',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isManualTracking ? _onStopManualTracking : null,
                  child: const Text(
                    'Stop tracking manually',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _onPermissionWizardStateChanged.cancel();
    _onLowerPower.cancel();
    _onLocationChanged.cancel();
    _tokenEditingController.dispose();
    super.dispose();
  }

  Future<void> _onDeviceTokenChanged() async {
    final value = _tokenEditingController.text;
    if (value.isNotEmpty) {
      await _prefs.setString('virtualDeviceToken', value);
    } else {
      await _prefs.remove('virtualDeviceToken');
    }

    _deviceId = value;
    setState(() {});
  }

  Future<void> _onEnableSDK() async {
    if (_deviceId.isEmpty) {
      _showSnackBar('virtual device token is empty');
    } else if (!_isAllRequiredPermissionsGranted) {
      _showSnackBar('Please grant all required permissions');
    } else {
      await _trackingApi.setDeviceID(deviceId: _deviceId);
      await _trackingApi.setEnableSdk(enable: true);

      if (Platform.isIOS) {
        await _trackingApi.enableHF(value: true);
        await _trackingApi.setDisableTracking(value: true);
      }

      _isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;
      setState(() {});
    }
  }

  Future<void> _onDisableSDK() async {
    if (_isManualTracking) {
      await _trackingApi.stopManualTracking();
      _isManualTracking = false;
    }

    if (_isTracking) {
      if (Platform.isIOS) {
        await _trackingApi.setDisableTracking(value: true);
      }
      _prefs.setBool('isTracking', false);
      _isTracking = false;
    }

    await _trackingApi.setEnableSdk(enable: false);
    _isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;
    setState(() {});
  }

  Future<void> _onForceDisableSDK() async {
    if (_isManualTracking) {
      await _trackingApi.stopManualTracking();
      _isManualTracking = false;
    }

    if (_isTracking) {
      if (Platform.isIOS) {
        await _trackingApi.setDisableTracking(value: true);
      }
      _prefs.setBool('isTracking', false);
      _isTracking = false;
    }

    await _trackingApi.setDisableWithUpload();
    _isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;
    setState(() {});
  }

  Future<void> _onLogout() async {
    _tokenEditingController.text = '';
    await _trackingApi.clearDeviceID();
  }

  Future<void> _onAggressiveHeartbeats(bool value) async {
    await _trackingApi.setAggressiveHeartbeats(value: value);
    _isAggressiveHeartbeats = await _trackingApi.isAggressiveHeartbeat() ?? false;
    setState(() {});
  }

  Future<void> _onPermissionsSDK() async {
    if (!_isAllRequiredPermissionsGranted) {
      _trackingApi.showPermissionWizard(
        enableAggressivePermissionsWizard: false,
        enableAggressivePermissionsWizardPage: true,
      );
    } else {
      _showSnackBar('All permissions are already granted');
    }
  }

  void _onPermissionWizardResult(PermissionWizardResult result) {
    const _wizardResultMapping = {
      PermissionWizardResult.allGranted: 'All permissions was granted',
      PermissionWizardResult.notAllGranted: 'All permissions was not granted',
      PermissionWizardResult.canceled: 'Wizard cancelled',
    };

    if (result == PermissionWizardResult.allGranted ||
        result == PermissionWizardResult.notAllGranted) {
      setState(() {
        _isAllRequiredPermissionsGranted =
            result == PermissionWizardResult.allGranted;
      });
    }

    _showSnackBar(_wizardResultMapping[result] ?? '');
  }

  Future<void> _onTrackingEnabled() async {
    final isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;

    if (!isSdkEnabled) {
      _showSnackBar('Enable SDK first');
      return;
    }

    await _trackingApi.setDisableTracking(value: false);
    _prefs.setBool('isTracking', true);

    setState(() {
      _isTracking = true;
    });
  }

  Future<void> _onTrackingDisabled() async {
    if (_isManualTracking) {
      await _trackingApi.stopManualTracking();
    }

    await _trackingApi.setDisableTracking(value: true);
    _prefs.setBool('isTracking', false);

    setState(() {
      _isTracking = false;
      _isManualTracking = false;
    });
  }

  Future<void> _onStartManualTracking() async {
    final isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;

    if (!isSdkEnabled) {
      _showSnackBar('Enable SDK first');
      return;
    }

    if (!_isTracking && Platform.isIOS) {
      _showSnackBar('Enable tracking first');
      return;
    }

    if (_isManualTracking) {
      _showSnackBar('Stop current track first');
      return;
    }

    await _trackingApi.startManualTracking();
    setState(() {
      _isManualTracking = true;
    });
  }

  Future<void> _onStopManualTracking() async {
    if (!_isManualTracking) {
      _showSnackBar('Start tracking first');
      return;
    }

    await _trackingApi.stopManualTracking();
    setState(() {
      _isManualTracking = false;
    });
  }

  void _onLowPowerResult(bool isLowPower) {
    if (isLowPower) {
      _showSnackBar(
        "Low Power Mode.\nYour trips may be not recorded. Please, follow to Settings=>Battery=>Low Power",
      );
    }
  }

  void _onLocationChangedResult(TrackLocation location) {
    print('location latitude: ${location.latitude}, longitude: ${location.longitude}');
    setState(() {
      _location = location;
    });
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _getCurrentLocation() {
    if (_location != null) {
      return 'Location: ${_location!.latitude}, ${_location!.longitude}';
    } else {
      return 'Location: null';
    }
  }
}
