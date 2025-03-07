package com.telematicssdk

import android.util.Log
import androidx.annotation.CallSuper
import com.telematicssdk.tracking.Settings
import com.telematicssdk.tracking.TrackingApi
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

    /**
     * Default Setting constructor
     * Stop tracking time is 5 minute.
     * Parking radius is 100 meters.
     * Auto start tracking is true.
     * hfOn - true if HIGH FREQUENCY data recording from sensors (acc, gyro) is ON and false otherwise.
     * isElmOn - true if data recording from ELM327 devices is ON and false otherwise.
     */
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
