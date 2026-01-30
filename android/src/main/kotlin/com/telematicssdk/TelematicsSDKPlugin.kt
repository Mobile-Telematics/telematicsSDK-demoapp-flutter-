package com.telematicssdk

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import org.json.JSONObject
import com.telematicssdk.tracking.TrackingApi
import com.telematicssdk.tracking.server.model.sdk.TrackTag
import com.telematicssdk.tracking.utils.permissions.PermissionsWizardActivity
import com.telematicssdk.tracking.model.realtime.configuration.AccidentDetectionSensitivity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

class WizardConstants {
    companion object {
        const val allGranted = "WIZARD_RESULT_ALL_GRANTED"
        const val notAllGranted = "WIZARD_RESULT_NOT_ALL_GRANTED"
        const val canceled = "WIZARD_RESULT_CANCELED"
    }
}

/** TelematicsSDKPlugin */
class TelematicsSDKPlugin : ActivityAware, ActivityResultListener, FlutterPlugin,
    MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var activity: Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activityPluginBinding: ActivityPluginBinding

    private val api = TrackingApi.getInstance()

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        activityPluginBinding.addActivityResultListener(this)
        activity = binding.activity
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "telematics_sdk")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext

        /// register callbacks
        api.addTagsProcessingCallback(TagsProcessingListenerImp(channel))
        api.setLocationListener(LocationListenerImp(channel))
        api.registerCallback((TrackingStateListenerImpl(channel)))
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding.removeActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityPluginBinding.removeActivityResultListener(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isInitialized" -> isInitialized(result)
            "getDeviceId" -> getDeviceId(result)
            "setDeviceID" -> setDeviceID(call, result)
            "logout" -> logout(result)
            "isAllRequiredPermissionsAndSensorsGranted" -> isAllRequiredPermissionsAndSensorsGranted(result)
            "isSdkEnabled" -> isSdkEnabled(result)
            "isTracking" -> isTracking(result)
            "setEnableSdk" -> setEnableSdk(call, result)
            "startManualTracking" -> startManualTracking(result)
            "startManualPersistentTracking" -> startManualPersistentTracking(result)
            "stopManualTracking" -> stopManualTracking(result)
            "uploadUnsentTrips" -> uploadUnsentTrips(result)
            "getUnsentTripCount" -> getUnsentTripCount(result)
            "sendCustomHeartbeats" -> sendCustomHeartbeats(call, result)
            "showPermissionWizard" -> showPermissionWizard(call, result)
            "getFutureTrackTags" -> getFutureTrackTags(result)
            "addFutureTrackTag" -> addFutureTrackTag(call, result)
            "removeFutureTrackTag" -> removeFutureTrackTag(call, result)
            "removeAllFutureTrackTags" -> removeAllFutureTrackTags(result)
            "setAccidentDetectionSensitivity" -> setAccidentDetectionSensitivity(call, result)
            "isRTLDEnabled" -> isRtdEnabled(result)
            "enableAccidents" -> enableAccidents(call, result)
            "isEnabledAccidents" -> isAccidentDetectionEnabled(result)
            "setAndroidAutoStartEnabled" -> setAutoStartEnabled(call, result)
            "isAndroidAutoStartEnabled" -> isAutoStartEnabled(result)
            else -> result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == PermissionsWizardActivity.WIZARD_PERMISSIONS_CODE) {
            lateinit var wizardResult: String

            when (resultCode) {
                PermissionsWizardActivity.WIZARD_RESULT_ALL_GRANTED -> wizardResult =
                    WizardConstants.allGranted
                PermissionsWizardActivity.WIZARD_RESULT_NOT_ALL_GRANTED -> wizardResult =
                    WizardConstants.notAllGranted
                PermissionsWizardActivity.WIZARD_RESULT_CANCELED -> wizardResult =
                    WizardConstants.canceled
            }

            channel.invokeMethod("onPermissionWizardResult", wizardResult)
            return true
        }

        return false
    }

    private fun isInitialized(result: Result) {
        var isInitialized = api.isInitialized()
        result.success(isInitialized)
    }

    private fun logout(result: Result) {
        api.logout()

        result.success(null)
    }

    private fun getDeviceId(result: Result) {
        val deviceId = api.getDeviceId()

        result.success(deviceId)
    }

    private fun isSdkEnabled(result: Result) {
        val isEnabled = api.isSdkEnabled()

        result.success(isEnabled)
    }

    private fun isTracking(result: Result) {
        val isTracking = api.isTracking()

        result.success(isTracking)
    }

    private fun isAllRequiredPermissionsAndSensorsGranted(result: Result) {
        val isGranted = api.areAllRequiredPermissionsAndSensorsGranted()

        result.success(isGranted)
    }

    private fun setDeviceID(call: MethodCall, result: Result) {
        val deviceId = call.argument<String?>("deviceId") as String

        api.setDeviceID(deviceId)

        result.success(null)
    }

    private fun setEnableSdk(call: MethodCall, result: Result) {
        val enable = call.argument<Boolean?>("enable") as Boolean
        api.setEnableSdk(enable)
        result.success(null)
    }

    private fun startManualTracking(result: Result) {
        val startResult = api.startTracking()

        result.success(startResult)
    }

    private fun startManualPersistentTracking(result: Result) {
        val startResult = api.startPersistentTracking()

        result.success(startResult)
    }

    private fun stopManualTracking(result: Result) {
        val stopResult = api.stopTracking()

        result.success(stopResult)
    }

    private fun uploadUnsentTrips(result: Result) {
        api.uploadUnsentTrips()
        result.success(null)
    }

    private fun getUnsentTripCount(result: Result) {
        val count = api.getUnsentTripCount()
        result.success(count)
    }

    private fun sendCustomHeartbeats(call: MethodCall, result: Result) {
        val reason = call.argument<String?>("reason") as String
        api.sendCustomHeartbeats(reason)
        result.success(null)
    }

    private fun showPermissionWizard(call: MethodCall, result: Result) {
        val enableAggressivePermissionsWizard =
            call.argument<Boolean?>("enableAggressivePermissionsWizard") as Boolean
        val enableAggressivePermissionsWizardPage =
            call.argument<Boolean?>("enableAggressivePermissionsWizardPage") as Boolean

        activity.startActivityForResult(
            PermissionsWizardActivity.getStartWizardIntent(
                context,
                enableAggressivePermissionsWizard = enableAggressivePermissionsWizard,
                enableAggressivePermissionsWizardPage = enableAggressivePermissionsWizardPage,
            ), PermissionsWizardActivity.WIZARD_PERMISSIONS_CODE
        )

        result.success(null)
    }

    private fun getFutureTrackTags(result: Result) {
        api.getFutureTrackTags()

        result.success(null)
    }

    private fun addFutureTrackTag(call: MethodCall, result: Result) {
        val tag = call.argument<String?>("tag") as String
        val source = call.argument<String?>("source") as String

        api.addFutureTrackTag(tag, source)

        result.success(null)
    }

    private fun removeFutureTrackTag(call: MethodCall, result: Result) {
        val tag = call.argument<String?>("tag") as String

        api.removeFutureTrackTag(tag)

        result.success(null)
    }

    private fun removeAllFutureTrackTags(result: Result) {
        api.removeAllFutureTrackTags()

        result.success(null)
    }

    private fun setAccidentDetectionSensitivity(call: MethodCall, result: Result) {
        val value = call.argument<String?>("accidentDetectionSensitivity") as Int

        val sensitivity = when (value) {
            0 -> AccidentDetectionSensitivity.Normal
            1 -> AccidentDetectionSensitivity.Sensitive
            2 -> AccidentDetectionSensitivity.Tough
            else -> AccidentDetectionSensitivity.Normal
        }

        api.setAccidentDetectionMode(sensitivity)
        result.success(null)
    }

    private fun isRtdEnabled(result: Result) {
        var isRtdEnabled = api.isRtdEnabled()
        result.success(isRtdEnabled)
    }

    private fun enableAccidents(call: MethodCall, result: Result) {
        val enable = call.argument<Boolean?>("enableAccidents") as Boolean
        api.setAccidentDetectionEnabled(enable)
        result.success(null)
    }

    private fun isAccidentDetectionEnabled(result: Result) {
        var isEnabledAccidents = api.isAccidentDetectionEnabled()
        result.success(isEnabledAccidents)
    }

    private fun setAutoStartEnabled(call: MethodCall, result: Result) {
        val enable = call.argument<Boolean?>("enable") as Boolean
        val permanent = call.argument<Boolean?>("permanent") as Boolean
        api.setAutoStartEnabled(enable, permanent)
        result.success(null)
    }

    private fun isAutoStartEnabled(result: Result) {
        var isAutoStartEnabled = api.isAutoStartEnabled()
        result.success(isAutoStartEnabled)
    }

    private fun registerSpeedViolations(call: MethodCall, result: Result) {
        val speedLimitKmH = call.argument<Double>("speedLimitKmH") as Double
        val speedLimitTimeout = call.argument<Long>("speedLimitTimeout") as Long
        val speedLimitTimeoutMs = speedLimitTimeout * 1000;
        api.registerSpeedViolations(speedLimitKmH.toFloat(), speedLimitTimeoutMs,
            SpeedViolationsListenerImpl(channel))
        result.success(null)
    }
}
