# Telematics SDK

A flutter plugin for tracking the person's driving behavior such as speeding, turning, braking and several other things on iOS and Android.

__Disclaimer__: This project uses Telematics SDK which belongs to DAMOOV PTE. LTD.  
When using Telematics SDK refer to these [terms of use](https://docs.damoov.com/docs/license)

## Getting Started

### Initial app setup & credentials

For commercial use, you need create a developer workspace in [DataHub](https://app.damoov.com) and get `InstanceId` and `InstanceKey` auth keys to work with our API.

### Android

#### AndroidManifest.xml

add to file ./app/src/main/AndroidManifest.xml props:

1. 'xmlns:tools="http://schemas.android.com/tools"' into __manifest__ tag
2. 'tools:replace="android:label"' into __application tag

as shown below:

``` xml
<manifest
    xmlns:tools="http://schemas.android.com/tools">
    <application
        tools:replace="android:label">
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
        //...
    }
    ```

2. add to tag __application__ of file ./app/src/main/AndroidManifest.xml this class __name__:

    ``` xml
    <application
            android:name=".App">
        ...
       <activity
            android:name=".MainActivity"
            android:exported="true"
    </application>

    ```

3. add Telematics SDK repository into (module)/gradle.build

    ```groovy
    dependencies {
        //...
        implementation "com.telematicssdk:tracking: 2.2.257"
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

## Links

[https://damoov.com](https://damoov.com/)
