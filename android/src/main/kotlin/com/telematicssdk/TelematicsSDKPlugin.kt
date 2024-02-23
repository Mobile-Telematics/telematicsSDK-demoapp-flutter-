package com.telematicssdk

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import org.json.JSONObject
import com.raxeltelematics.v2.sdk.TrackingApi
import com.raxeltelematics.v2.sdk.server.model.sdk.TrackTag
import com.raxeltelematics.v2.sdk.utils.permissions.PermissionsWizardActivity

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
            "clearDeviceID" -> clearDeviceID(result)
            "getDeviceId" -> getDeviceId(result)
            "isAllRequiredPermissionsAndSensorsGranted" -> isAllRequiredPermissionsAndSensorsGranted(
                result,
            )
            "isSdkEnabled" -> isSdkEnabled(result)
            "isTracking" -> isTracking(result)
            "setDeviceID" -> setDeviceID(call, result)
            "setEnableSdk" -> setEnableSdk(call, result)
            "setDisableWithUpload" -> setDisableWithUpload(result)
            "startManualTracking" -> startManualTracking(result)
            "stopManualTracking" -> stopManualTracking(result)
            "enableHF" -> enableHF(call, result)
            "showPermissionWizard" -> showPermissionWizard(call, result)
            "getTrackTags" -> getTrackTags(call, result)
            "addTrackTags" -> addTrackTags(call, result)
            "removeTrackTags" -> removeTrackTags(call, result)
            "getFutureTrackTags" -> getFutureTrackTags(result)
            "addFutureTrackTag" -> addFutureTrackTag(call, result)
            "removeFutureTrackTag" -> removeFutureTrackTag(call, result)
            "removeAllFutureTrackTags" -> removeAllFutureTrackTags(result)
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

    private fun clearDeviceID(result: Result) {
        api.clearDeviceID()

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
        val isGranted = api.isAllRequiredPermissionsAndSensorsGranted()

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
    private fun enableHF(call: MethodCall, result: Result) {
        val enable = call.argument<Boolean?>("enableHF") as Boolean
        api.setHfRecordingEnabled(enable)
        result.success(null)
    }

    private fun setDisableWithUpload(result: Result) {
        api.setDisableWithUpload()
        result.success(null)
    }

    private fun startManualTracking(result: Result) {
        val startResult = api.startTracking()

        result.success(startResult)
    }

    private fun stopManualTracking(result: Result) {
        val stopResult = api.stopTracking()

        result.success(stopResult)
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

    private fun getTrackTags(call: MethodCall, result: Result) {
        val trackId = call.argument<String?>("trackId") as String

        val res = api.getTrackTags(trackId).map { it.toJsonString() }.toTypedArray()

        result.success(res)
    }

    private fun addTrackTags(call: MethodCall, result: Result) {
        val trackId = call.argument<String?>("trackId") as String
        val strings = call.argument<Array<String>?>("tags") as Array<String>

        val tags = strings.map {
            val json = JSONObject(it)
            val tag = json["tag"] as String
            val source = json["source"] as String
            TrackTag(tag, source)
        }.toTypedArray()

        val res = api.addTrackTags(trackId, tags).map { it.toJsonString() }.toTypedArray()

        result.success(res)
    }

    private fun removeTrackTags(call: MethodCall, result: Result) {
        val trackId = call.argument<String?>("trackId") as String
        val strings = call.argument<Array<String>?>("tags") as Array<String>

        val tags = strings.map {
            val json = JSONObject(it)
            val tag = json["tag"] as String
            val source = json["source"] as String
            TrackTag(tag, source)
        }.toTypedArray()

        val res = api.removeTrackTags(trackId, tags).map { it.toJsonString() }.toTypedArray()

        result.success(res)
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
}
