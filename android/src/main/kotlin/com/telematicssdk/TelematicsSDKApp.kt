package com.telematicssdk

import android.util.Log
import androidx.annotation.CallSuper
import com.raxeltelematics.v2.sdk.Settings
import com.raxeltelematics.v2.sdk.TrackingApi
import io.flutter.app.FlutterApplication

open class TelematicsSDKApp : FlutterApplication() {

    @CallSuper
    override fun onCreate() {
        super.onCreate()
        Log.d("TelematicsSDKApp.onCreate", "created")

        val api = TrackingApi.getInstance()
        if (!api.isInitialized()) {
            api.initialize(this, setTelematicsSettings())
            Log.d("TelematicsSDKApp.onCreate", "TrackingApi initialized")
        }
    }

    open fun setTelematicsSettings(): Settings {
        val settings = Settings(
            stopTrackingTimeout = Settings.stopTrackingTimeHigh,
            accuracy = Settings.accuracyHigh,
            autoStartOn = true,
            elmOn = false,
            hfOn = true,
        )
        Log.d("TelematicsSDKApp", "setTelematicsSettings")
        return settings
    }
}
