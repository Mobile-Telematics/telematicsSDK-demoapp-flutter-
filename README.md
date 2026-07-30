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

The wizard's notification and UI strings, images, colors, and dimensions can be
overridden through standard Android resources in the host app. Refer to
[Android App Resources](https://docs.damoov.com/docs/android-app-resources)
for the complete and current list of resource names instead of copying them
into the app manifest or this README.

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

### Trip metadata

Use trip metadata to associate trips with business entities such as an order,
driver, vehicle, or shift. These APIs add business context to trip data; they do
not replace the SDK's telematics measurements.

#### Properties

Properties are a persistent, flat string key-value dictionary attached to
trips. They remain active for subsequent trips until they are replaced or
cleared, and are cleared automatically when the user logs out or the device ID
changes.

`setProperties` replaces the whole dictionary; it does not merge keys. When
tracking is active and the new dictionary differs from the current one, the SDK
finishes the current trip and starts a new trip with the new Properties. Passing
the same dictionary does not restart tracking.

```dart
await trackingApi.setProperties(
  properties: {
    'policy_id': 'POL-1042',
    'shift_id': '2026-07-28-AM',
    'order_id': 'ORD-891',
  },
);

final properties = await trackingApi.getProperties();
await trackingApi.clearProperties();
```

Use `getProperties()` to inspect the active metadata or to update one entry
before writing the complete replacement dictionary:

```dart
final properties = await trackingApi.getProperties();
await trackingApi.setProperties(
  properties: {...properties, 'order_id': 'ORD-892'},
);
```

`clearProperties()` removes all Properties. If tracking is active and Properties
are not already empty, the SDK finishes the current trip and starts a new trip
without Properties. A Properties dictionary must contain 1–20 entries; keys and
values must be non-empty strings of at most 255 characters. Use
`clearProperties()`—not an empty map—to remove all Properties.

#### Sub-units

Sub-units are a persistent, flat string key-value dictionary for analytical
trip classification, such as a driver, vehicle, depot, or session. They remain
active until they are replaced or cleared, and are cleared automatically on
logout or when the device ID changes.

Changing or clearing Sub-units never restarts active tracking. If changed while
a trip is active, the new Sub-units apply to the next trip.

```dart
await trackingApi.setSubUnits(
  subUnits: {
    'driver_id': 'DRV-42',
    'vehicle_id': 'VEH-108',
    'depot_id': 'MINSK-01',
  },
);

final subUnits = await trackingApi.getSubUnits();
await trackingApi.clearSubUnits();
```

`setSubUnits()` replaces the full dictionary. Use `getSubUnits()` to inspect the
active dictionary or update one entry before writing the full replacement map.
`clearSubUnits()` removes all Sub-units without restarting tracking. A Sub-units
dictionary must contain 1–5 entries; its keys and values must be non-empty
strings of at most 255 characters. Use `clearSubUnits()`—not an empty map—to
remove all Sub-units.

#### Activity log

Use Activity Log to attach business events to the current active trip without
stopping or splitting it—for example, delivery acceptance, a checkpoint, or a
depot arrival. Activity Log entries can be added only while tracking is active;
each trip supports up to 100 entries.

```dart
await trackingApi.addActivityLog(
  text: 'Driver accepted delivery order',
  data: {
    'order_id': 'ORD-891',
    'vehicle_id': 'VEH-108',
    'source': 'delivery-flow',
  },
);
```

`text` is required and is limited to 1,000 characters. The `data` dictionary is
optional; because the Flutter method requires the argument, pass an empty map
when no additional metadata is needed:

```dart
await trackingApi.addActivityLog(
  text: 'Arrived at depot',
  data: const {},
);
```

When Properties change during tracking, the SDK completes the current trip and
starts a new one. Existing Activity Log entries remain attached to the completed
trip; the new trip starts with an empty Activity Log.

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

### Permission Wizard

The native Permission Wizard explains each required permission before opening
the corresponding system prompt. You may implement your own request flow, but
do not enable the SDK until
`isAllRequiredPermissionsAndSensorsGranted()` returns `true`.

Subscribe once, before displaying the wizard. `showPermissionWizard` resolves
when the native UI is launched—not when the user has finished—so use
`onPermissionWizardClose` as the completion signal and cancel the subscription
in `dispose`.

```dart
late final StreamSubscription<PermissionWizardResult?> wizardSubscription;

@override
void initState() {
  super.initState();
  wizardSubscription = trackingApi.onPermissionWizardClose.listen((result) async {
    if (result == PermissionWizardResult.allGranted) {
      await trackingApi.setEnableSdk(enable: true);
      return;
    }

    // Keep the SDK disabled and offer an appropriate retry path.
  });
}

@override
void dispose() {
  wizardSubscription.cancel();
  super.dispose();
}
```

#### Android

The Android wizard requests the runtime permissions required for tracking:
precise location, background location on Android 10+, activity recognition on
Android 10+, and battery-optimization exclusion. Check the merged manifest
after adding or upgrading dependencies: another dependency must not remove or
restrict the SDK permissions. See the
[Android SDK integration guide](https://docs.damoov.com/docs/android-sdk-integration)
for the native integration prerequisites.

The `TrackingPermissionsWizardActivity` declaration and its AppCompat theme in
the [Android setup](#android-permission-wizard-theme) section are required for
Android SDK 4.1+. Then launch it from Flutter:

```dart
await trackingApi.showPermissionWizard(
  android: const AndroidPermissionWizardOptions(
    themeMode: AndroidPermissionWizardThemeMode.system,
    blockEarlyExit: false,
    skipWizardPages: false,
  ),
);
```

`themeMode` selects the light, dark, or system appearance. Set
`blockEarlyExit` to `true` only when the product flow must keep the user in the
wizard until it reaches an outcome; the default `false` permits closing it.
`skipWizardPages` removes the Android SDK 4.1+ explanatory screens and proceeds
directly to the system requests where supported. Keep it `false` for the usual
step-by-step, policy-friendly explanation.

The stream result is one of:

| Result | Meaning | Recommended handling |
| --- | --- | --- |
| `allGranted` | All required permissions and sensors are ready. | Enable the SDK after ensuring a device ID has been set. |
| `notAllGranted` | The flow finished, but one or more requirements remain unavailable. | Keep the SDK disabled; explain the missing requirement and let the user retry. |
| `canceled` | The user closed the wizard. | Keep the SDK disabled and provide a non-blocking route to reopen it later. |

To customize Android wizard copy, illustration assets, colors, or dimensions,
override the host application's Android resources. The maintained list is in
[Android App Resources](https://docs.damoov.com/docs/android-app-resources);
using that page avoids stale duplicated resource keys here.


### Available Methods (iOS only)

#### Permission Wizard configuration

On iOS, the wizard guides the user through **When In Use** location, **Always**
location, and **Motion & Fitness** permissions, then shows their final status.
Always location, Precise Location, and Motion & Fitness are required for
reliable automatic trip detection. Configure the wizard before calling
`showPermissionWizard()`. These configuration APIs are iOS-only and throw
`UnsupportedError` on Android.

Every configuration object is partial: omitted text and color fields retain the
native iOS SDK defaults. This makes it safe to customize only the copy or colors
needed by your product while keeping the SDK's current permission flow.

```dart
await trackingApi.configureIosPermissionWizard(
  const IosPermissionWizardConfiguration(
    locationWhenInUse: IosPermissionWizardPageConfiguration(
      title: 'Location access',
      body: 'Allow location access so the app can recognize your trips.',
      primaryButtonTitle: 'Continue',
    ),
    locationAlways: IosPermissionWizardPageConfiguration(
      title: 'Always allow location',
      body: 'Choose “Always” to record trips when the app is not open.',
      primaryButtonTitle: 'Open settings',
      hintLead: 'In Settings, select:',
      permissionHint: 'Location → Always',
    ),
    motion: IosPermissionWizardPageConfiguration(
      title: 'Motion & Fitness',
      body: 'Motion data helps detect trips and calculate driving events.',
      primaryButtonTitle: 'Allow motion access',
    ),
    status: IosPermissionWizardStatusConfiguration(
      title: 'Finish setup',
      body: 'Review the permissions needed to record trips.',
      fixInSettingsButtonTitle: 'Open Settings',
      skipButtonTitle: 'Not now',
    ),
    lightTheme: IosPermissionWizardTheme(
      backgroundColor: '#FFFFFFFF',
      primaryElementColor: '#2563EB',
      buttonTextColor: '#FFFFFFFF',
    ),
    darkTheme: IosPermissionWizardTheme(
      backgroundColor: '#FF111827',
      primaryElementColor: '#60A5FA',
      buttonTextColor: '#FF111827',
    ),
  ),
);

await trackingApi.showPermissionWizard();
```

`IosPermissionWizardPageConfiguration` customizes a permission page with
`title`, `body`, `primaryButtonTitle`, `hintLead`, and `permissionHint`.
`IosPermissionWizardStatusConfiguration` customizes the final status screen,
including per-permission titles and messages for enabled, missing Always,
missing Precise Location, and missing Motion & Fitness access. Use
`fixInSettingsButtonTitle` and `skipButtonTitle` to label its actions.

`IosPermissionWizardTheme` can be supplied independently for `lightTheme` and
`darkTheme`. Its color fields use `#RRGGBB` or `#AARRGGBB`; the latter includes
the alpha channel. In addition to the colors above, it supports text, gradient,
card, success, warning, secondary-button, status-indicator, and modal-scrim
colors. See the [iOS Permission Wizard guide](https://docs.damoov.com/docs/new-permission-wizard-in-ios)
for the native wizard behavior and UX guidance.

#### Missing-permissions alert

Use the optional missing-permissions alert when the user returns to the app
without completing the wizard or later revokes a permission. It has the same
status copy and light/dark theme options as the wizard. Set `isBlocking` only
if your product must require remediation before the alert can be dismissed.

```dart
await trackingApi.configureIosMissingPermissionsAlert(
  const IosMissingPermissionsAlertConfiguration(
    title: 'Trip recording needs attention',
    body: 'Enable the required permissions in Settings to continue.',
    fixInSettingsButtonTitle: 'Open Settings',
    skipButtonTitle: 'Later',
    isBlocking: false,
  ),
);

await trackingApi.setIosMissingPermissionsAlertEnabled(true);
```

Call `setIosMissingPermissionsAlertEnabled(false)` when your app uses its own
remediation UI. The alert configuration and enablement should be applied before
the part of the app that may show the wizard or evaluate missing permissions.

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

Use these direct request methods only for a custom iOS permission flow. For the
SDK wizard, call `showPermissionWizard()` after configuring it as described
above; do not request the same permission twice in parallel.

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
