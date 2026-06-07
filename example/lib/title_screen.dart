import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telematics_sdk/telematics_sdk.dart';

const _sizedBoxSpace = SizedBox(height: 24);
const _futureTrackTag = 'MyBestTripTagForRPTest';
const _futureTrackTagSource = 'RPTestSource';

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
  late StreamSubscription<FutureTrackTagAddResult> _onFutureTrackTagAdded;
  late StreamSubscription<FutureTrackTagRemoveResult> _onFutureTrackTagRemoved;
  late StreamSubscription<FutureTrackTagsRemoveResult>
  _onAllFutureTrackTagsRemoved;
  late StreamSubscription<FutureTrackTagsResult> _onFutureTrackTagsReceived;

  /// Current device token as reported by the native SDK ([TrackingApi.getDeviceId]).
  var _sdkDeviceId = '';
  var _isSdkEnabled = false;
  var _isAllRequiredPermissionsGranted = false;
  var _isTracking = true;
  var _isManualTracking = false;
  var _isAggressiveHeartbeats = false;
  TrackingMode? _trackingMode;
  TrackLocation? _location;

  final _tokenEditingController = TextEditingController();
  final _maxPersistentIntervalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _onPermissionWizardStateChanged = _trackingApi.onPermissionWizardClose
        .listen(_onPermissionWizardResult);
    _onLowerPower = _trackingApi.lowPowerMode.listen(_onLowPowerResult);
    _onLocationChanged = _trackingApi.locationChanged.listen(
      _onLocationChangedResult,
    );
    _onFutureTrackTagAdded = _trackingApi.futureTrackTagAdded.listen(
      _onFutureTrackTagAddedResult,
    );
    _onFutureTrackTagRemoved = _trackingApi.futureTrackTagRemoved.listen(
      _onFutureTrackTagRemovedResult,
    );
    _onAllFutureTrackTagsRemoved = _trackingApi.allFutureTrackTagsRemoved
        .listen(_onAllFutureTrackTagsRemovedResult);
    _onFutureTrackTagsReceived = _trackingApi.futureTrackTagsReceived.listen(
      _onFutureTrackTagsReceivedResult,
    );
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final virtualDeviceToken = await _trackingApi.getDeviceId();
    _sdkDeviceId = virtualDeviceToken ?? '-';

    if (_sdkDeviceId.isEmpty) {
      await _trackingApi.setEnableSdk(enable: false);
    }

    _isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;
    _isAllRequiredPermissionsGranted =
        await _trackingApi.isAllRequiredPermissionsAndSensorsGranted() ?? false;

    if (Platform.isIOS) {
      final disableTracking = await _trackingApi.isDisableTracking() ?? false;
      _isTracking = !disableTracking;
      _isAggressiveHeartbeats =
          await _trackingApi.isAggressiveHeartbeats() ?? false;
    }

    _trackingMode = await _trackingApi.getTrackingMode();
    final maxPersistentTrackingInterval = await _trackingApi
        .getMaxPersistentTrackingInterval();
    if (maxPersistentTrackingInterval != null) {
      _maxPersistentIntervalController.text = maxPersistentTrackingInterval
          .toString();
    }

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
      appBar: AppBar(title: const Text('TelematicsSDK_demo')),
      body: ListView(
        shrinkWrap: false,
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Text('SDK status: ${_isSdkEnabled ? 'Enabled' : 'Disabled'}'),
          Text(
            'Permissions: ${_isAllRequiredPermissionsGranted ? 'Granted' : 'Not granted'}',
          ),
          (Platform.isIOS)
              ? Text(
                  'Tracking: ${_isSdkEnabled && _isTracking ? 'Enabled' : 'Disabled'}',
                )
              : SizedBox.shrink(),
          Text(
            'Manual Tracking: ${_isManualTracking ? 'Started' : 'Not stated'}',
          ),
          Text(_getCurrentLocation()),
          Text(
            _sdkDeviceId.isEmpty ? 'Device ID: —' : 'Device ID: $_sdkDeviceId',
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _onShowDeviceIdRegistrationState,
                  child: const Text(
                    'Get Device ID Registration State',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onShowTrackingState,
                  child: const Text(
                    'Get Tracking State',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _maxPersistentIntervalController,
            decoration: const InputDecoration(
              labelText: 'Max persistent interval, minutes',
              hintText: '5-600 minutes',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onSetMaxPersistentTrackingInterval,
              child: const Text('Set Max Persistent Interval'),
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<TrackingMode>(
            segments: const [
              ButtonSegment(
                value: TrackingMode.standard,
                label: Text('Standard'),
              ),
              ButtonSegment(
                value: TrackingMode.persistent,
                label: Text('Persistent'),
              ),
            ],
            selected: _trackingMode == null ? const {} : {_trackingMode!},
            emptySelectionAllowed: true,
            onSelectionChanged: (selection) {
              final trackingMode = selection.firstOrNull;
              if (trackingMode != null) {
                _onSetTrackingMode(trackingMode);
              }
            },
          ),
          const SizedBox(height: 8),
          const Text('Future Track Tags'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _onGetFutureTrackTags,
            child: const Text('Get Future Track Tags'),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _onAddFutureTrackTag,
                  child: const Text(
                    'Add Future Track Tag',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onRemoveFutureTrackTag,
                  child: const Text(
                    'Remove Future Track Tag',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _onRemoveAllFutureTrackTags,
            child: const Text('Remove All Future Track Tags'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _tokenEditingController,
            decoration: const InputDecoration(
              labelText: 'Override device ID',
              hintText: 'Submit to apply a new token',
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.go,
            maxLengthEnforcement: MaxLengthEnforcement.none,
            onFieldSubmitted: (token) async {
              try {
                await _onDeviceTokenUpdated(token: token);
              } on FormatException catch (e) {
                _showSnackBar(e.message);
              }
              if (mounted) {
                FocusScope.of(context).requestFocus(FocusNode());
              }
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
            onPressed: !_isSdkEnabled && _sdkDeviceId.isNotEmpty
                ? _onLogout
                : null,
            child: const Text('Logout'),
          ),
          _sizedBoxSpace,
          ElevatedButton(
            onPressed: () async {
              await _onPermissionsSDK();
            },
            child: const Text('Start Permission Wizard'),
          ),
          _sizedBoxSpace,
          (Platform.isIOS)
              ? Row(
                  children: [
                    Expanded(child: const Text('Aggressive Heartbeats')),
                    Switch.adaptive(
                      value: _isAggressiveHeartbeats,
                      onChanged: _isSdkEnabled ? _onAggressiveHeartbeats : null,
                    ),
                  ],
                )
              : SizedBox.shrink(),
          (Platform.isIOS)
              ? Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSdkEnabled && !_isTracking
                            ? _onTrackingEnabled
                            : null,
                        child: const Text('Enable Tracking'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSdkEnabled && _isTracking
                            ? _onTrackingDisabled
                            : null,
                        child: const Text('Disable Tracking'),
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
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
                  onPressed: !_isManualTracking
                      ? _onStartPersistentManualTracking
                      : null,
                  child: const Text(
                    'Start persistent tracking manually',
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
    _onFutureTrackTagAdded.cancel();
    _onFutureTrackTagRemoved.cancel();
    _onAllFutureTrackTagsRemoved.cancel();
    _onFutureTrackTagsReceived.cancel();
    _maxPersistentIntervalController.dispose();
    _tokenEditingController.dispose();
    super.dispose();
  }

  Future<void> _onDeviceTokenUpdated({required String token}) async {
    await _trackingApi.setDeviceID(deviceId: token);
    final updated = await _trackingApi.getDeviceId();
    if (!mounted) {
      return;
    }
    setState(() {
      _sdkDeviceId = updated ?? '-';
      _tokenEditingController.clear();
    });
  }

  Future<void> _onShowDeviceIdRegistrationState() async {
    try {
      final state = await _trackingApi.getDeviceIdRegistrationState();
      _showSnackBar(
        'Device ID Registration State: '
        'status=${state.status.name}, '
        'checkedAtMillis=${state.checkedAtMillis}',
      );
    } catch (e) {
      _showSnackBar('getDeviceIdRegistrationState failed: $e');
    }
  }

  Future<void> _onShowTrackingState() async {
    try {
      final state = await _trackingApi.getTrackingState();
      _showSnackBar(
        'Tracking State: '
        'automatic=${state.automaticTrackingStatus.name}, '
        'manual=${state.manualTrackingStatus.name}',
      );
    } catch (e) {
      _showSnackBar('getTrackingState failed: $e');
    }
  }

  Future<void> _onSetMaxPersistentTrackingInterval() async {
    final minutes = int.tryParse(_maxPersistentIntervalController.text);
    if (minutes == null) {
      _showSnackBar('Max persistent interval is invalid');
      return;
    }

    try {
      await _trackingApi.setMaxPersistentTrackingInterval(minutes: minutes);
      _showSnackBar('Max Persistent Interval set to $minutes minutes');
    } catch (e) {
      _showSnackBar('setMaxPersistentTrackingInterval failed: $e');
    }
  }

  Future<void> _onSetTrackingMode(TrackingMode trackingMode) async {
    try {
      await _trackingApi.setTrackingMode(trackingMode: trackingMode);
      setState(() {
        _trackingMode = trackingMode;
      });
      _showSnackBar('Tracking Mode set to ${trackingMode.name}');
    } catch (e) {
      _showSnackBar('setTrackingMode failed: $e');
    }
  }

  Future<void> _onGetFutureTrackTags() async {
    try {
      await _trackingApi.getFutureTrackTags();
    } catch (e) {
      _showSnackBar('getFutureTrackTags failed: $e');
    }
  }

  Future<void> _onAddFutureTrackTag() async {
    try {
      await _trackingApi.addFutureTrackTag(
        tag: _futureTrackTag,
        source: _futureTrackTagSource,
      );
    } catch (e) {
      _showSnackBar('addFutureTrackTag failed: $e');
    }
  }

  Future<void> _onRemoveFutureTrackTag() async {
    try {
      await _trackingApi.removeFutureTrackTag(
        tag: _futureTrackTag,
        source: _futureTrackTagSource,
      );
    } catch (e) {
      _showSnackBar('removeFutureTrackTag failed: $e');
    }
  }

  Future<void> _onRemoveAllFutureTrackTags() async {
    try {
      await _trackingApi.removeAllFutureTrackTags();
    } catch (e) {
      _showSnackBar('removeAllFutureTrackTags failed: $e');
    }
  }

  void _onFutureTrackTagAddedResult(FutureTrackTagAddResult result) {
    _showSnackBar(
      'Future Track Tag add result: status=${result.status}, tag=${result.tag.tag}, source=${result.tag.source}, activationTime=${result.activationTime}',
    );
  }

  void _onFutureTrackTagRemovedResult(FutureTrackTagRemoveResult result) {
    _showSnackBar(
      'Future Track Tag remove result: status=${result.status}, tag=${result.tag.tag}, source=${result.tag.source}, deactivationTime=${result.deactivationTime}',
    );
  }

  void _onAllFutureTrackTagsRemovedResult(FutureTrackTagsRemoveResult result) {
    _showSnackBar(
      'Remove all Future Track Tags result: status=${result.status}, time=${result.time}',
    );
  }

  void _onFutureTrackTagsReceivedResult(FutureTrackTagsResult result) {
    final tagsText = result.tags
        ?.map((tag) => '${tag.tag} (${tag.source})')
        .join(', ');
    _showSnackBar(
      'Future Track Tags result: status=${result.status}, tags=${tagsText?.isEmpty ?? true ? 'none' : tagsText}, time=${result.time}',
    );
  }

  Future<void> _onEnableSDK() async {
    final sdkDeviceId = await _trackingApi.getDeviceId();
    if (sdkDeviceId == null || sdkDeviceId.isEmpty) {
      _showSnackBar('SDK device id is empty');
    } else if (!_isAllRequiredPermissionsGranted) {
      _showSnackBar('Please grant all required permissions');
    } else {
      await _trackingApi.setEnableSdk(enable: true);

      _isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;

      if (Platform.isIOS) {
        await _trackingApi.setDisableTracking(value: false);
        final disableTracking = await _trackingApi.isDisableTracking() ?? false;
        _isTracking = !disableTracking;
      }

      setState(() {});
    }
  }

  Future<void> _onDisableSDK() async {
    if (_isManualTracking) {
      await _trackingApi.stopManualTracking();
      _isManualTracking = false;
    }

    if (Platform.isIOS) {
      await _trackingApi.setDisableTracking(value: true);
      final disableTracking = await _trackingApi.isDisableTracking() ?? false;
      _isTracking = !disableTracking;
    }

    await _trackingApi.setEnableSdk(enable: false);
    _isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;
    setState(() {});
  }

  Future<void> _onLogout() async {
    _tokenEditingController.clear();
    await _trackingApi.logout();
    final afterLogout = await _trackingApi.getDeviceId();
    if (!mounted) {
      return;
    }
    setState(() {
      _sdkDeviceId = afterLogout ?? '';
    });
  }

  Future<void> _onAggressiveHeartbeats(bool value) async {
    await _trackingApi.setAggressiveHeartbeats(value: value);
    _isAggressiveHeartbeats =
        await _trackingApi.isAggressiveHeartbeats() ?? false;
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
    if (!Platform.isIOS) {
      return;
    }
    final isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;

    if (!isSdkEnabled) {
      _showSnackBar('Enable SDK first');
      return;
    }

    await _trackingApi.setDisableTracking(value: false);
    final disableTracking = await _trackingApi.isDisableTracking() ?? false;

    setState(() {
      _isTracking = !disableTracking;
    });
  }

  Future<void> _onTrackingDisabled() async {
    if (!Platform.isIOS) {
      return;
    }
    if (_isManualTracking) {
      await _trackingApi.stopManualTracking();
    }

    await _trackingApi.setDisableTracking(value: true);
    final disableTracking = await _trackingApi.isDisableTracking() ?? false;

    setState(() {
      _isTracking = !disableTracking;
      _isManualTracking = false;
    });
  }

  Future<void> _onStartManualTracking() async {
    final isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;
    final sdkDeviceId = await _trackingApi.getDeviceId();

    if (sdkDeviceId == null || sdkDeviceId.isEmpty) {
      _showSnackBar('SDK device id is empty');
      return;
    }

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

  Future<void> _onStartPersistentManualTracking() async {
    final isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;
    final sdkDeviceId = await _trackingApi.getDeviceId();

    if (sdkDeviceId == null || sdkDeviceId.isEmpty) {
      _showSnackBar('SDK device id is empty');
      return;
    }

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

    await _trackingApi.startTrackAsPersistent();
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
    print(
      'location latitude: ${location.latitude}, longitude: ${location.longitude}',
    );
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
