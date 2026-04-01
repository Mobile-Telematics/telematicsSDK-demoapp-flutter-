# Changelog

## 1.0.4

### Android updates
* Motion detection algorithms update 
* Implemented continuation of track recording after SDK reboot 
* Added database protection against corruption 
* Enhance SDK Logging 
* All Bluetooth-related permissions will be removed from the SDK:
  android.permission.BLUETOOTH_CONNECT
  android.permission.BLUETOOTH_SCAN
  android.permission.BLUETOOTH
  android.permission.BLUETOOTH_ADMIN
  android.permission.FOREGROUND_SERVICE_CONNECTED_DEVICE 
* All health-related permissions will be removed from the SDK:
  android.permission.FOREGROUND_SERVICE_HEALTH
  So you don't need to remove anything else from your app-level manifest.
  And all our Foreground services will run with only one type: location 
* Other changes related to improving reliability and stability

## 1.0.3

* Fix setAccidentDetectionEnabled api

## 1.0.2

* Rename public APIs

## 1.0.1

* Update README

## 1.0.0

* Sync all public APIs between native SDK and flutter plugin

## 0.4.1

* Added Support SceneDelegate support for iOS module of telematics_sdk plugin. To add UISceneDelegate adoption follow guide: https://docs.flutter.dev/release/breaking-changes/uiscenedelegate
* Dropped support for flutter versions below 3.38.0

## 0.4.0

* Updated iOS sdk version to 7.0.3
* Updated Android sdk version to 3.2.0

## 0.3.4

* Updated iOS sdk version to 7.0.2

## 0.3.3

* Updated Gradle version to 8.13
* Updated Android Gradle Plugin version to 8.12.0
* Updated Android sdk version to 3.1.1

## 0.3.2

* Updated Android Gradle version to 8.7
* Update Android targetSdkVersion to 35

## 0.3.1

* Updated iOS sdk version to 7.0.1
* Updated Android sdk version to 3.1.0

## 0.3.0

* Updated iOS sdk version to 7.0.0
* Updated Android sdk version to 3.0.0

## 0.2.7

* Fixed android SDK crash

## 0.2.6

* Updated iOS sdk version to 6.0.6

## 0.2.5

* Updated iOS sdk version to 6.0.5
* Updated Android sdk version to 2.2.263

## 0.2.4

* Updated iOS sdk version to 6.0.4
* Updated Android sdk version to 2.2.262

## 0.2.3

* Updated iOS sdk version to 6.0.3

## 0.2.2

* Updated iOS sdk version to 6.0.2

## 0.2.1

* Update Wrapper to support Flutter 3.22

## 0.2.0

* Migrate to dart 3+
* Updated Android sdk version to 2.2.260
* Updated iOS sdk version to 6.0.0

## 0.1.1

* Updated Android sdk version to 2.2.253

## 0.1.0

* Add `deviceID` methods: `setDeviceID`, `getDeviceID`, `clearDeviceID`.
* Add permissions check method: `isAllRequiredPermissionsAndSensorsGranted`.
* Add SDK status manipulation: `isSdkEnabled`, `setEnableSdk`.
* Add tracking manipulation: `isTracking`, `startTracking`, `stopTracking`.
* Add tags manipulation: `getTrackTags`, `addTrackTags`, `removeTrackTags`.
* Add future tag manipulation: `getFutureTrackTags`, `addFutureTrackTag`, `removeFutureTrackTag`, `removeAllFutureTrackTags`.
* Add PermissionWizard methods.
* iOS: add `lowerPowerMode`.
* iOS: add `setAggressiveHeartbeats` with brief documentation.

## 0.0.1

* Initial version
