package com.telematicssdk.example

import android.util.Log
import com.telematicssdk.TelematicsSDKApp
import com.raxeltelematics.v2.sdk.Settings
import com.raxeltelematics.v2.sdk.TrackingApi

class App : TelematicsSDKApp() {

    override fun onCreate() {
        val api = TrackingApi.getInstance()
        api.initialize(this, setTelematicsSettings())
        Log.d("App.onCreate", "TrackingApi initialized")
        Log.d("App.onCreate", "created")
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
        Log.d("App.setTelematicsSettings", "setTelematicsSettings")
        return settings
    }

}