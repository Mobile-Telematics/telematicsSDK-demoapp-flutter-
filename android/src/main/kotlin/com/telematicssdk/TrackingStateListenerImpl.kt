package com.telematicssdk

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel
import com.telematicssdk.tracking.TrackingStateListener

class TrackingStateListenerImpl(private val channel: MethodChannel): TrackingStateListener {

    override fun onStartTracking() {
        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod("onTrackingStateChanged", true)
        }
    }

    override fun onStopTracking() {
        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod("onTrackingStateChanged", false)
        }
    }
}