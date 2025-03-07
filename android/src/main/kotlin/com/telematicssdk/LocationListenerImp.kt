package com.telematicssdk

import android.location.Location
import android.os.Looper
import android.os.Handler
import io.flutter.plugin.common.MethodChannel
import com.telematicssdk.tracking.LocationListener

class LocationListenerImp(private val channel: MethodChannel): LocationListener {

    override fun onLocationChanged(location: Location?) {
        location?.let {
            val latitude = it.latitude
            val longitude = it.longitude
            val json = mapOf<String, Any>(
                "latitude" to latitude,
                "longitude" to longitude
            )
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("onLocationChanged", json)
            }
        } ?: run {
            println("Location is null")
        }
    }

}