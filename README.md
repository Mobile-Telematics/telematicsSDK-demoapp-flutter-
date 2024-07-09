# Telematics SDK

A flutter plugin for tracking the person's driving behavior such as speeding, turning, braking and several other things on iOS and Android.

__Disclaimer__: This project uses Telematics SDK which belongs to DAMOOV PTE. LTD.  
When using Telematics SDK refer to these [terms of use](https://docs.damoov.com/docs/license)

## Getting Started

### Initial app setup & credentials

For commercial use, you need create a developer workspace in [DataHub](https://app.damoov.com) and get `InstanceId` and `InstanceKey` auth keys to work with our API.

### Android

#### Please draw attention that Android SDK supports Gradle 8+ versions only.

#### AndroidManifest.xml

add to file ./app/src/main/AndroidManifest.xml props:

1. 'xmlns:tools="http://schemas.android.com/tools"' into __manifest__ tag
2. 'tools:replace="android:label"' into __application tag

as shown below:

``` xml
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

``` xml
<manifest>
...
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
...
```

#### build.gradle

add to file (module)/build.gradle props:

``` groovy
    android {
    ...
        buildTypes {
            release {
                ...
                shrinkResources false
                minifyEnabled false
                ...
            }
        }
    ...
    }
```

#### Proguard

``` markdown
-keep public class com.raxeltelematics.** {*;}
```

### Android Advanced

#### SetTrackingSettings

1. Override application class extends __TelematicsSDKApp__

    ``` kotlin
    import com.telematicssdk.TelematicsSDKApp

    class App: TelematicsSDKApp() {
    
        override fun onCreate() {
            val api = TrackingApi.getInstance()
            api.initialize(this, setTelematicsSettings())
            super.onCreate()
        }
        
        override fun setTelematicsSettings(): Settings {
        val settings = Settings(
            stopTrackingTimeout = Settings.stopTrackingTimeHigh, 
            accuracy = Settings.accuracyHigh,
            autoStartOn = true,
            elmOn = false,
            hfOn = true
        )
        return settings
    }
}
    ```

2. add to tag __application__ of file ./app/src/main/AndroidManifest.xml this class __name__:

    ``` xml
    <application
            android:name=".App">
        ...
    </application>

    ```

3. add Telematics SDK repository into (module)/build.gradle

    ```groovy
    dependencies {
        //...
        implementation "com.telematicssdk:tracking:2.2.262"
    }
    ```

### iOS

Add permissions in your project's `ios/Runner/Info.plist`:

``` xml
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
You must request permissions for the application before GeneratedPluginRegistrant
[Example AppDelegate.swift](https://github.com/Mobile-Telematics/telematicsSDK-demoapp-flutter-/blob/main/example/ios/Runner/AppDelegate.swift)

### Enabling and Disabling the SDK

Firstly, create trackingAPI object to interact with SDK
``` dart
import 'package:telematics_sdk/telematics_sdk.dart';

final _trackingApi = TrackingApi();
```

**Login**
``` dart
    await _trackingApi.setDeviceID(deviceId: "DEVICE_TOKEN");
```

**Logout**
``` dart
    await _trackingApi.clearDeviceID();
```

**Enable the SDK**

``` dart
    await _trackingApi.setEnableSdk(enable: true);
```

**Disable the SDK**

``` dart
    await _trackingApi.setEnableSdk(enable: false);
```

**Disable the SDK with force uploading data**

``` dart
    await _trackingApi.setDisableWithUpload();
```

### Available Methods

**Manual start tracking**
``` dart
    await _trackingApi.startManualTracking();
```

**Manual stop tracking**
``` dart
    await _trackingApi.stopManualTracking();
```

**Permissions status**
``` dart
    final isAllGranted = await _trackingApi.isAllRequiredPermissionsAndSensorsGranted();
```

**Tracking status**
``` dart
    final isTracking = await _trackingApi.isTracking();
```

**Enable high-frequency data collection (HF)**
We strongly recommend keeping it enabled by default
``` dart
    await _trackingApi.enableHF(value: true);
```

**Create new tag**
The detailed information about using Tags is available [here](https://docs.damoov.com/docs/ios-sdk-incoming-tags)
``` dart
    String tag = 'TAG';
    String source = 'App';
    await _trackingApi.addFutureTrackTag(tag: tag, source: source);
```

**Remove a tag**
``` dart
    String tag = 'TAG';
    await _trackingApi.removeFutureTrackTag(tag: tag);
```

**Remove all tags**
``` dart
    await _trackingApi.removeAllFutureTrackTags();
```

**Setting up the permission wizard**
Without these permissions SDK can not be enabled.
If you want to use your own way to request permissions, you can skip this part.

To show the permission wizard, follow next steps:
1. Create and init **StreamSubscription** in your widget
``` dart
    late StreamSubscription<PermissionWizardResult?> _onPermissionWizardStateChanged;
    
    @override
    void initState() {
        _onPermissionWizardStateChanged = _trackingApi
        .onPermissionWizardClose
        .listen(_onPermissionWizardResult);
        
    void _onPermissionWizardResult(PermissionWizardResult result) {
        if (result == PermissionWizardResult.allGranted) {
            //All permissions are granted. To do something here.
        } else {
            //Permissions are not granted. To do something here.
        }
    }
```
2. Request to show the permission wizard

``` dart
    await _trackingApi.showPermissionWizard(
        enableAggressivePermissionsWizard: false, 
        enableAggressivePermissionsWizardPage: true
    );
```
If `[enableAggressivePermissionsWizard]` set to `true` the wizard will be finished if all required permissions granted (user can’t cancel it with back button), otherwise if set to `false` the wizard can be finished with not all granted permissions or cancelled with back button.

If `[enableAggressivePermissionsWizardPage]` set to `true` the wizard will slide to next page if requested permissions granted on current page, otherwise if set to `false` the wizard can slide with not granted permissions.


### Available Methods (iOS only)

**Enable/Disable Automatic tracking**
``` dart
    bool disableTracking = false;
    //true to disable automatic tracking (tracking is enabled by default)
    await _trackingApi.setDisableTracking(value: disableTracking);
```

**Automatic tracking status**
``` dart
    final isTrackingDisabled = await _trackingApi.isDisableTracking();
```

**Enable/Disable Aggressive Heartbeats**

The telematics SDK (iOS only) supports two operational modes for heartbeats;

**Aggressive heartbeats** - heartbeats are sent every 20 minutes. SDK is always active.
**Normal Heartbeats** - heartbeats are sent every 20 minutes but when SDK turns into Standby mode, it will be activated only by a new trip, and heartbeat will be sent respectively.

**Mode switcher**

``` dart
    bool enable = true; //false to disable aggressive heartbeats
    await _trackingApi.setAggressiveHeartbeats(value: enable)
```

**Check state**
``` dart
    final isAggressiveHeartbeats = await _trackingApi.isAggressiveHeartbeat()
```

**Enable Accidents detection**
Accidents detection is disabled by default. You can enable detection.
In order for accidents detection to work, you need to [enable high-frequency data collection](https://docs.damoov.com/docs/methods-for-ios-app#enable-high-frequency-data-collection-hf)
``` dart
    await _trackingApi.enableAccidents(value: true);
    
    //to check current accidents status
    final isEnabledAccidents = await _trackingApi.isEnabledAccidents();
```

## Links

[https://damoov.com](https://damoov.com/)
