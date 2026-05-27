package com.telematicssdk

import android.app.Application
import android.util.Log
import androidx.annotation.CallSuper
import com.telematicssdk.tracking.Settings
import com.telematicssdk.tracking.TrackingApi

open class TelematicsSDKApp : Application() {

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
     */
    open fun setTelematicsSettings(): Settings {
        val settings = Settings()
            .stopTrackingTimeout(Settings.stopTrackingTimeHigh)
            .accuracy(Settings.accuracyHigh)
            .autoStartOn(true)
        Log.d("TelematicsSDKApp", "setTelematicsSettings")
        return settings
    }
}
