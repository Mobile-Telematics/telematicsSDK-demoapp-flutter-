package com.telematicssdk

import android.os.Handler
import android.os.Looper
import com.telematicssdk.tracking.SpeedViolation
import com.telematicssdk.tracking.SpeedViolationsListener
import io.flutter.plugin.common.MethodChannel

class SpeedViolationsListenerImpl(private val channel: MethodChannel): SpeedViolationsListener {

    override fun onSpeedViolation(p0: SpeedViolation?) {
        p0?.let {
            val date = it.date
            val latitude = it.latitude
            val longitude = it.long
            val speed = it.yourSpeed
            val speedLimit = it.speedLimit

            val json = mapOf<String, Any>(
                "date" to date,
                "latitude" to latitude,
                "longitude" to longitude,
                "speed" to speed.toDouble(),
                "speedLimit" to speedLimit.toDouble()
            )

            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onSpeedViolation", json)
            }
        } ?: run {
            println("SpeedViolation is null")
        }
    }
}