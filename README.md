# Telematics SDK

A flutter plugin for tracking the person's driving behavior such as speeding, turning, braking and several other things on iOS and Android.

__Disclaimer__: This project uses Telematics SDK which belongs to DAMOOV PTE. LTD.  
When using Telematics SDK refer to these [terms of use](https://docs.damoov.com/docs/license)

## AI agent integration skill

**We provide an AI agent skill that helps integrate Damoov TelematicsSDK into Flutter applications.** The skill can guide coding agents such as Claude Code, OpenAI Codex, and other AI coding tools through verified TelematicsSDK integration patterns, including dependency setup, lifecycle forwarding, tracking flows, tags, and migration away from deprecated APIs.

Skill repository: [Mobile-Telematics/telematics-sdk-skills](https://github.com/Mobile-Telematics/telematics-sdk-skills).

## Getting Started

### Initial app setup & credentials

For commercial use, you need create a developer workspace in [DataHub](https://app.damoov.com) and get `InstanceId` and `InstanceKey` auth keys to work with our API.

### Add the plugin to your Flutter app

`pubspec.yaml`

```yaml
dependencies:
  telematics_sdk: ^1.2.0
```

Import it. Now in your Dart code, you can use:

```dart
import 'package:telematics_sdk/telematics_sdk.dart';
```

### Android

#### Please draw attention that Android SDK supports Gradle 8+ versions only.

#### AndroidManifest.xml

add to file ./app/src/main/AndroidManifest.xml props:

1. 'xmlns:tools="http://schemas.android.com/tools"' into __manifest__ tag
2. 'tools:replace="android:label"' into __application tag

as shown below:

```xml
<manifest
    xmlns:tools="http://schemas.android.com/tools">
    <application
        tools:replace="android:label,android:name">
        ...
    </application>
    ...
</manifest>
```

add network permissions

```xml
<manifest>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
</manifest>
```

#### Android Permission Wizard theme

The Android SDK 4.1+ Permission Wizard is an `AppCompatActivity`. Declare the
current wizard activity in the app manifest and assign it an AppCompat-based
theme. This is required even when the wizard is started from Flutter:

```xml
<application>
    <activity
        android:name="com.telematicssdk.tracking.utils.permissions.TrackingPermissionsWizardActivity"
        android:theme="@style/TelematicsPermissionsWizardTheme"
        android:exported="false" />
</application>
```

Create the theme in `android/app/src/main/res/values/styles.xml`:

```xml
<resources>
    <style name="TelematicsPermissionsWizardTheme" parent="Theme.AppCompat.Light.DarkActionBar">
        <item name="android:windowBackground">@android:color/white</item>
        <item name="android:colorBackground">@android:color/white</item>
    </style>
</resources>
```

#### build.gradle

add to file (module)/build.gradle props:

```groovy
    android {
        buildTypes {
            release {
                shrinkResources false
                minifyEnabled false
            }
        }
    }

    dependencies {
        implementation "androidx.appcompat:appcompat:1.6.1"
    }
```

#### Proguard

```markdown
-keep public class com.telematicssdk.tracking.** {*;}
```

### Android Advanced

#### SetTrackingSettings

1. Override application class extends __TelematicsSDKApp__

```kotlin
import com.telematicssdk.TelematicsSDKApp
import com.telematicssdk.tracking.Settings

class App: TelematicsSDKApp() {
    override fun setTelematicsSettings(): Settings =
        Settings()
            .stopTrackingTimeout(Settings.stopTrackingTimeHigh)
            .accuracy(Settings.accuracyHigh)
            .autoStartOn(true)
            .passiveDetectionOn(true)
}
```

`TelematicsSDKApp` initializes `TrackingApi` itself; do not initialize it a
second time in `onCreate`.

2. add to tag __application__ of file ./app/src/main/AndroidManifest.xml this class __name__:

```xml
<application
    android:name=".App">
</application>
```

3. add Telematics SDK repository into (module)/build.gradle
```groovy
dependencies {
    implementation "com.telematicssdk:tracking:4.1.0"
}
```

### iOS

Add permissions in your project's `ios/Runner/Info.plist`:

```xml
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>location</string>
        <string>remote-notification</string>
    </array>
    <key>NSMotionUsageDescription</key>
    <string>Please, provide permissions for this Demo</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Please, provide permissions for this Demo</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>Please, provide permissions for this Demo</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Please, provide permissions for this Demo</string>
    <key>BGTaskSchedulerPermittedIdentifiers</key>
    <array>
        <string>sdk.damoov.apprefreshtaskid</string>
        <string>sdk.damoov.appprocessingtaskid</string>
    </array>
```
Starting from iOS version 15 and above, as well as Flutter 2.0.6, modification of `ios/Runner/AppDelegate.swift` is required 
You must initialize TelematicsSDK before GeneratedPluginRegistrant.

If your app doesn't support SceneDelegate and Flutter version if lower then 3.38, then follow this way:
```swift
import Flutter
import UIKit
import TelematicsSDK

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        RPEntry.initializeSDK()
        RPEntry.instance.application(application, didFinishLaunchingWithOptions: launchOptions)
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```
Otherwise, if Flutter version is 3.38 and higher, then you have to implement UISceneDelegate adoption for the app and follow this way:
```swift
import Flutter
import UIKit
import TelematicsSDK

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        RPEntry.initializeSDK()
        RPEntry.instance.application(application, didFinishLaunchingWithOptions: launchOptions)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: any FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }
}
```
A guide for Flutter iOS developers to adopt Apple's UISceneDelegate protocol is here:
https://docs.flutter.dev/release/breaking-changes/uiscenedelegate

### Enabling and Disabling the SDK

Firstly, create trackingAPI object to interact with SDK
```dart
import 'package:telematics_sdk/telematics_sdk.dart';

final trackingApi = TrackingApi();
```

**Login**
```dart
await trackingApi.setDeviceID(deviceId: 'DEVICE_TOKEN');
```

**Logout**
```dart
await trackingApi.logout();
```

**Enable the SDK**
```dart
await trackingApi.setEnableSdk(enable: true);
```

**Disable the SDK**
```dart
await trackingApi.setEnableSdk(enable: false);
```

---

### Additional Available Methods

**Manual start tracking**
```dart
await trackingApi.startManualTracking();
```

**Manual start persistent tracking**
```dart
await trackingApi.startTrackAsPersistent();
```
**Notes:**
Persistent tracking ignores all stop tracking reasons and continues before 'stopManualTracking' method will be called.
Max persistent tracking duration is 10 hours.

**Manual stop tracking**
```dart
await trackingApi.stopManualTracking();
```

**Check SDK initialization state**
```dart
final initialized = await trackingApi.isInitialized();
```

**Get current device ID**
```dart
final deviceId = await trackingApi.getDeviceId();
```

**Get device ID registration state**

Returns the latest known registration status for the current device ID and the
timestamp of the last check in milliseconds. A `checkedAtMillis` value of `0`
means the registration state has not been checked yet.
```dart
final state = await trackingApi.getDeviceIdRegistrationState();

if (state.status == DeviceIdRegistrationStatus.registered) {
  // Current device ID is registered.
}

final checkedAtMillis = state.checkedAtMillis;
```

**Check all required permissions and sensors**
```dart
final granted = await trackingApi.isAllRequiredPermissionsAndSensorsGranted();
```

**Check SDK enabled state**
```dart
final enabled = await trackingApi.isSdkEnabled();
```

**Check RTLD (Real-Time Data Logging) status**
```dart
final rtldEnabled = await trackingApi.isRTLDEnabled();
```

**Register speed limit violations monitoring**
```dart
await trackingApi.registerSpeedViolations(
  speedLimitKmH: 90.0,
  speedLimitTimeout: 60,
);
```

**Listen for speed violations**
```dart
final sub = trackingApi.speedViolation.listen((event) {
  // Handle speed violation
});
```

**Listen for location updates**
```dart
final sub = trackingApi.locationChanged.listen((location) {
  // Handle location update
});
```

**Listen for tracking state changes**
```dart
final sub = trackingApi.trackingStateChanged.listen((active) {
  // true = started, false = stopped
});
```

**Listen for Low Power Mode changes**
```dart
final sub = trackingApi.lowPowerMode.listen((enabled) {
  // Power saving mode changed
});
```

**Upload unsent trips**
```dart
await trackingApi.uploadUnsentTrips();
```

**Get unsent trips count**
```dart
final unsentTripsCount = await trackingApi.getUnsentTripCount();
```

**Send a custom heartbeat**
```dart
await trackingApi.sendCustomHeartbeats(reason: 'CustomHeartbeat');
```

**Tracking status**
```dart
final isTracking = await trackingApi.isTracking();
```

**Tracking availability state**

Returns automatic and manual tracking availability statuses. Use this method to
inspect whether tracking is enabled or blocked by device ID, SDK settings,
local settings, server settings, or schedule.
```dart
final state = await trackingApi.getTrackingState();

final automaticStatus = state.automaticTrackingStatus;
final manualStatus = state.manualTrackingStatus;
```

**Set persistent tracking interval**

Sets the maximum duration for a single persistent tracking session, in minutes.
Allowed values are from `5` to `600`. The native SDK default is `240` minutes
(4 hours).
```dart
await trackingApi.setMaxPersistentTrackingInterval(minutes: 240);
```

**Get persistent tracking interval**
```dart
final minutes = await trackingApi.getMaxPersistentTrackingInterval();
```

**Set tracking mode**

Sets whether automatically started and manually started tracking sessions use
standard or persistent mode.
```dart
await trackingApi.setTrackingMode(
  trackingMode: TrackingMode.persistent,
);
```

**Get tracking mode**
```dart
final trackingMode = await trackingApi.getTrackingMode();

if (trackingMode == TrackingMode.standard) {
  // Standard tracking mode is active.
}
```

**Enable Accidents detection**
Accidents detection is disabled by default. You can enable detection.
```dart
await trackingApi.setAccidentDetectionEnabled(value: true);
//to check current accidents status
final isEnabledAccidents = await trackingApi.isAccidentDetectionEnabled();
```

**Change Accident detection sensitivity**
Accident detection sensitivity is normal by default. You can change sensitivity. Sensitivity options which is available to apply: .normal, .sensitive, .tough
```dart
await trackingApi.setAccidentDetectionSensitivity(sensitivity: AccidentDetectionSensitivity.normal);
```

**Properties and sub-units**

Properties and sub-units are string key-value pairs associated with the current SDK user. Each `set` call replaces the entire existing dictionary; it does not merge keys.

```dart
await trackingApi.setProperties(properties: {'policy': 'standard'});
final properties = await trackingApi.getProperties();
await trackingApi.clearProperties();

await trackingApi.setSubUnits(subUnits: {'vehicle': 'fleet-42'});
final subUnits = await trackingApi.getSubUnits();
await trackingApi.clearSubUnits();
```

**Activity log**

```dart
await trackingApi.addActivityLog(
  text: 'Trip started manually',
  data: {'tripId': '42'},
);
```

> **Deprecated:** Future Track Tags are deprecated on iOS and Android. They remain available for backwards compatibility; migrate new integrations to Properties APIs.

**Create new tag**
The detailed information about using Tags is available [here](https://docs.damoov.com/docs/ios-sdk-incoming-tags)
```dart
final tagAddedSubscription = trackingApi.futureTrackTagAdded.listen((result) {
  print('status=${result.status}, tag=${result.tag.tag}, source=${result.tag.source}');
});

String tag = 'TAG';
String? source = 'App';
await trackingApi.addFutureTrackTag(tag: tag, source: source);

// source is optional:
await trackingApi.addFutureTrackTag(tag: tag);
```

**Remove a tag**
```dart
final tagRemovedSubscription = trackingApi.futureTrackTagRemoved.listen((result) {
  print('status=${result.status}, tag=${result.tag.tag}, source=${result.tag.source}');
});

String tag = 'TAG';
String? source = 'App';
await trackingApi.removeFutureTrackTag(tag: tag, source: source);
```

**Remove all tags**
```dart
final allTagsRemovedSubscription = trackingApi.allFutureTrackTagsRemoved.listen((result) {
  print('status=${result.status}, time=${result.time}');
});

await trackingApi.removeAllFutureTrackTags();
```

**Get tags**
```dart
final tagsReceivedSubscription = trackingApi.futureTrackTagsReceived.listen((result) {
  print('status=${result.status}, tags=${result.tags}');
});

await trackingApi.getFutureTrackTags();
```

**Setting up the permission wizard**
Without these permissions SDK can not be enabled.
If you want to use your own way to request permissions, you can skip this part.

To show the permission wizard, follow next steps:
1. Create and init **StreamSubscription** in your widget
```dart
late StreamSubscription<PermissionWizardResult?> _onPermissionWizardStateChanged;
    
@override
void initState() {
  onPermissionWizardStateChanged = trackingApi
      .onPermissionWizardClose
      .listen(_onPermissionWizardResult);
}
        
void onPermissionWizardResult(PermissionWizardResult result) {
  if (result == PermissionWizardResult.allGranted) {
    //All permissions are granted. To do something here.
  } else {
    //Permissions are not granted. To do something here.
  }
}
```
2. Request to show the permission wizard
```dart
await trackingApi.showPermissionWizard(
  android: const AndroidPermissionWizardOptions(
    themeMode: AndroidPermissionWizardThemeMode.system,
    blockEarlyExit: false,
    skipWizardPages: false,
  ),
);
```

`blockEarlyExit` prevents closing the Android wizard before it ends. `skipWizardPages` skips the informational pages supported by Android SDK 4.1+.

On iOS, configure the wizard before launching it. Any omitted property keeps the iOS SDK default:

```dart
await trackingApi.configureIosPermissionWizard(
  const IosPermissionWizardConfiguration(
    locationAlways: IosPermissionWizardPageConfiguration(
      title: 'Location access',
    ),
  ),
);

await trackingApi.configureIosMissingPermissionsAlert(
  const IosMissingPermissionsAlertConfiguration(isBlocking: true),
);
await trackingApi.setIosMissingPermissionsAlertEnabled(true);
await trackingApi.showPermissionWizard();
```

`IosPermissionWizardConfiguration` accepts optional `locationWhenInUse`,
`locationAlways`, and `motion` page configurations; each supports `title`,
`body`, `primaryButtonTitle`, `hintLead`, and `permissionHint`. Its `status`
configuration supports the status-screen copy, and `lightTheme` / `darkTheme`
configure the visual theme.

The status-screen and missing-permissions-alert copy fields are `title`,
`body`, `locationTitle`, `motionTitle`, `locationEnabledText`,
`locationAlwaysRequiredText`, `locationPreciseRequiredText`,
`locationActionNeededText`, `motionEnabledText`, `motionActionNeededText`,
`fixInSettingsButtonTitle`, and `skipButtonTitle`.

`IosMissingPermissionsAlertConfiguration` supports the same status copy and
themes, plus `isBlocking`. `setIosMissingPermissionsAlertEnabled` controls
whether this alert is shown.

For iOS theme colors, use `#RRGGBB` or `#AARRGGBB`, for example:

```dart
const IosPermissionWizardTheme(
  primaryElementColor: '#2563EB',
  backgroundColor: '#FFFFFFFF',
)
```

The available theme fields are `backgroundColor`, `gradientStartColor`,
`gradientEndColor`, `titleTextColor`, `bodyTextColor`, `primaryElementColor`,
`secondaryElementColor`, `buttonTextColor`, `cardBackgroundColor`,
`successElementColor`, `warningElementColor`, `secondaryButtonTextColor`,
`secondaryButtonBackgroundColor`, `statusIndicatorTextColor`, and
`modalScrimColor`.


### Available Methods (iOS only)

**Get API language**
```dart
final apiLanguage = await trackingApi.getApiLanguage();
```

**Set API language**

Supported values are `ApiLanguage.none`, `ApiLanguage.english`,
`ApiLanguage.russian`, `ApiLanguage.portuguese`, and `ApiLanguage.spanish`.
```dart
await trackingApi.setApiLanguage(language: ApiLanguage.english);
```

**Check wrong accuracy state (Reduced Accuracy)**
```dart
final wrongAccuracy = await trackingApi.isWrongAccuracyState();
```

**Request Always Location permission**
```dart
await trackingApi.requestIOSLocationAlwaysPermission();
```

**Request Motion permission**
```dart
await trackingApi.requestIOSMotionPermission();
```

**Listen for wrong accuracy events**
```dart
trackingApi.iOSWrongAccuracyAuthorization.listen((_) {
  // Reduced accuracy detected
});
```

**Listen for RTLD events**
```dart
trackingApi.iOSRTLDDataCollected.listen((_) {
  // RTLD data collected
});
```

**Enable/Disable Automatic tracking**
```dart
bool disableTracking = false;
//true to disable automatic tracking (tracking is enabled by default)
await trackingApi.setDisableTracking(value: disableTracking);
```

**Automatic tracking status**
```dart
final isTrackingDisabled = await trackingApi.isDisableTracking();
```

**Enable/Disable Aggressive Heartbeats**

The telematics SDK (iOS only) supports two operational modes for heartbeats;

**Aggressive heartbeats** - heartbeats are sent every 20 minutes. SDK is always active.
**Normal Heartbeats** - heartbeats are sent every 20 minutes but when SDK turns into Standby mode, it will be activated only by a new trip, and heartbeat will be sent respectively.

**Mode switcher**

```dart
bool enable = true; //false to disable aggressive heartbeats
await trackingApi.setAggressiveHeartbeats(value: enable)
```

**Check state**
```dart
final isAggressiveHeartbeats = await trackingApi.isAggressiveHeartbeats();
```
---

### Available Methods (Android only)

**Enable / Disable SDK auto-start**
```dart
await trackingApi.setAndroidAutoStartEnabled(
  enable: true,
  permanent: true,
);
```

**Check SDK auto-start status**
```dart
final autoStartEnabled = await trackingApi.isAndroidAutoStartEnabled();
```

## Links

[https://damoov.com](https://damoov.com/)
