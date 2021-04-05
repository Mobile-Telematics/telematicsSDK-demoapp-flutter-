package com.telematicssdk

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import com.raxeltelematics.v2.sdk.TrackingApi
import com.raxeltelematics.v2.sdk.utils.permissions.PermissionsWizardActivity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

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
            "showPermissionWizard" -> showPermissionWizard(call, result)
            "startTracking" -> startTracking(result)
            "stopTracking" -> stopTracking(result)
            else -> result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == PermissionsWizardActivity.WIZARD_PERMISSIONS_CODE) {
            lateinit var wizardResult: String

            when (resultCode) {
                PermissionsWizardActivity.WIZARD_RESULT_ALL_GRANTED -> wizardResult =
                    "WIZARD_RESULT_ALL_GRANTED"
                PermissionsWizardActivity.WIZARD_RESULT_NOT_ALL_GRANTED -> wizardResult =
                    "WIZARD_RESULT_NOT_ALL_GRANTED"
                PermissionsWizardActivity.WIZARD_RESULT_CANCELED -> wizardResult =
                    "WIZARD_RESULT_CANCELED"
            }

            channel.invokeMethod("onPermissionWizardResult", wizardResult)
            return true
        }

        return false
    }

    private fun clearDeviceID(@NonNull result: Result) {
        api.clearDeviceID()

        result.success(null)
    }

    private fun getDeviceId(@NonNull result: Result) {
        val deviceId = api.getDeviceId()

        result.success(deviceId)
    }

    private fun isSdkEnabled(@NonNull result: Result) {
        val isEnabled = api.isSdkEnabled()

        result.success(isEnabled)
    }

    private fun isTracking(@NonNull result: Result) {
        val isTracking = api.isTracking()

        result.success(isTracking)
    }

    private fun isAllRequiredPermissionsAndSensorsGranted(@NonNull result: Result) {
        val isGranted = api.isAllRequiredPermissionsAndSensorsGranted()

        result.success(isGranted)
    }

    private fun setDeviceID(@NonNull call: MethodCall, @NonNull result: Result) {
        val deviceId = call.argument<String?>("deviceId") as String

        api.setDeviceID(deviceId)

        result.success(null)
    }

    private fun setEnableSdk(@NonNull call: MethodCall, @NonNull result: Result) {
        val enable = call.argument<Boolean?>("enable") as Boolean

        api.setEnableSdk(enable)

        result.success(null)
    }

    private fun startTracking(@NonNull result: Result) {
        val startResult = api.startTracking()

        result.success(startResult)
    }

    private fun stopTracking(@NonNull result: Result) {
        val stopResult = api.stopTracking()

        result.success(stopResult)
    }

    private fun showPermissionWizard(@NonNull call: MethodCall, @NonNull result: Result) {
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
}
