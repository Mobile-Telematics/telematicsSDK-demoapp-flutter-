import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telematics_sdk/telematics_sdk.dart';

/// Unique user device token
const String virtualDeviceToken = '';

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

  var _deviceId = virtualDeviceToken;

  @override
  void initState() {
    super.initState();

    _onPermissionWizardStateChanged =
        _trackingApi.onPermissionWizardClose.listen(_onPermissionWizardResult);

    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
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
      body: Center(
          child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          TextFormField(
            initialValue: _deviceId,
            decoration: const InputDecoration(
              hintText: 'virtual device token',
              labelText: 'virtual device token',
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            maxLengthEnforcement: MaxLengthEnforcement.none,
            onChanged: (value) {
              setState(() {
                _deviceId = value;
              });
            },
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
          ElevatedButton(
            onPressed: () async {
              if (_deviceId.isEmpty) {
                _showSnackBar('virtual device token is empty');
              } else if (!(await _trackingApi
                      .isAllRequiredPermissionsAndSensorsGranted() ??
                  false)) {
                _showSnackBar('Please grant all required permissions');
              } else {
                await _trackingApi.setDeviceID(deviceId: _deviceId);
                await _trackingApi.setEnableSdk(enable: true);
              }
            },
            child: const Text('Enable SDK'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _trackingApi.setEnableSdk(enable: false);
            },
            child: const Text('Disable SDK'),
          ),
          _sizedBoxSpace,
          ElevatedButton(
            onPressed: () async {
              if (!(await _trackingApi
                      .isAllRequiredPermissionsAndSensorsGranted() ??
                  false)) {
                _trackingApi.showPermissionWizard(
                  enableAggressivePermissionsWizard: false,
                  enableAggressivePermissionsWizardPage: true,
                );
              } else {
                _showSnackBar('All permissions are already granted');
              }
            },
            child: const Text('Start Permission Wizard'),
          ),
          _sizedBoxSpace,
          ElevatedButton(
            onPressed: () async {
              if (!(await _trackingApi.isSdkEnabled() ?? false)) {
                _showSnackBar('Enable SDK first');
              } else if (await _trackingApi.isTracking() ?? false) {
                _showSnackBar('Stop current track first');
              } else {
                _trackingApi.startTracking();
              }
            },
            child: const Text('Start tracking manually'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (await _trackingApi.isTracking() ?? false) {
                _trackingApi.stopTracking();
              } else {
                _showSnackBar('Start tracking first');
              }
            },
            child: const Text('Stop tracking manually'),
          ),
          _sizedBoxSpace,
          ElevatedButton(
            onPressed: () async {
              if (!(await _trackingApi.isSdkEnabled() ?? false)) {
                _showSnackBar('Enable SDK first');
              } else {}
            },
            child: const Text('Dashboard'),
          ),
        ],
      )),
    );
  }

  @override
  void dispose() {
    _onPermissionWizardStateChanged.cancel();

    super.dispose();
  }

  void _onPermissionWizardResult(PermissionWizardResult result) {
    const _wizardResultMapping = {
      PermissionWizardResult.allGranted: 'All permissions was granted',
      PermissionWizardResult.notAllGranted: 'All permissions was not granted',
      PermissionWizardResult.canceled: 'Wizard cancelled',
    };

    _showSnackBar(_wizardResultMapping[result] ?? '');
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
