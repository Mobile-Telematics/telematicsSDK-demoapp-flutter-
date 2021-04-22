# Telematics SDK

A flutter plugin for tracking the person's driving behavior such as speeding, turning, braking and several other things on iOS and Android.

__Disclaimer__: This project uses Telematics SDK which belongs to DATA MOTION PTE. LTD.  
When using Telematics SDK refer to these [terms of use](https://docs.telematicssdk.com/license)

## Getting Started

### Initial app setup & credentials

For commercial use, you need create sandbox account [DataHub](https://userdatahub.com/user/registration) and get `InstanceId` auth keys to work with our API.

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
    </application>

    ```

3. add Raxel repository into (module)/gradle.build

    ```groovy
    dependencies {
        //...
        implementation "com.telematicssdk:tracking: 2.2.231"
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
```

## Links

[https://telematicssdk.com/](https://telematicssdk.com/)
