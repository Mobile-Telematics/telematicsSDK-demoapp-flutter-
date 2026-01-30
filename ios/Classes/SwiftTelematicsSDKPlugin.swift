import Flutter
import TelematicsSDK
import UIKit

struct Constants {
    struct WizardResult {
        static let allGranted = "WIZARD_RESULT_ALL_GRANTED"
        static let notAllGranted = "WIZARD_RESULT_NOT_ALL_GRANTED"
    }
}

public class SwiftTelematicsSDKPlugin: NSObject, FlutterPlugin {
    
    private let channel: FlutterMethodChannel
    
    public init(methodChannel: FlutterMethodChannel) {
        self.channel = methodChannel
        super.init()
        RPEntry.instance.lowPowerModeDelegate = self
        RPEntry.instance.locationDelegate = self
        RPEntry.instance.accuracyAuthorizationDelegate = self
        RPEntry.instance.trackingStateDelegate = self
        RPEntry.instance.rtldDelegate = self
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "telematics_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftTelematicsSDKPlugin(methodChannel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
        registrar.addSceneDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isInitialized":
            isInitialized(result)
        case "setDeviceID":
            setDeviceID(call, result: result)
        case "getDeviceId":
            getDeviceId(result)
        case "logout":
            logout(result)
        case "isAllRequiredPermissionsAndSensorsGranted":
            isAllRequiredPermissionsGranted(result)
        case "isSdkEnabled":
            isSDKEnabled(result)
        case "isTracking":
            isTracking(result)
        case "setEnableSdk":
            setEnableSdk(call, result: result)
        case "startManualTracking":
            startManualTracking(result)
        case "startManualPersistentTracking":
            startManualPersistentTracking(result)
        case "stopManualTracking":
            stopManualTracking(result)
        case "uploadUnsentTrips":
            uploadUnsentTrips(result)
        case "getUnsentTripCount":
            getUnsentTripCount(result)
        case "sendCustomHeartbeats":
            sendCustomHeartbeats(call, result: result)
        case "showPermissionWizard":
            showPermissionWizard(call, result)
        case "getFutureTrackTags":
            getFutureTrackTags(result)
        case "addFutureTrackTag":
            addFutureTrackTag(call, result)
        case "removeFutureTrackTag":
            removeFutureTrackTag(call, result)
        case "removeAllFutureTrackTags":
            removeAllFutureTrackTags(result)
        case "setAccidentDetectionSensitivity":
            setAccidentDetectionSensitivity(call, result)
        case "isRTLDEnabled":
            isRTLDEnabled(result)
        case "enableAccidents":
            enableAccidents(call, result)
        case "isEnabledAccidents":
            isEnabledAccidents(result)
        case "getApiLanguage":
            getApiLanguage(result)
        case "setApiLanguage":
            setApiLanguage(call, result)
        case "setAggressiveHeartbeats":
            setAggressiveHeartbeats(call, result)
        case "isAggressiveHeartbeat":
            isAggressiveHeartbeat(result)
        case "isDisableTracking":
            isDisableTracking(result: result)
         case "setDisableTracking":
            setDisableTracking(call, result: result)
        case "isWrongAccuracyState":
            isWrongAccuracyState(result)
        case "requestIOSLocationAlwaysPermission":
            requestLocationAlwaysPermission(result)
        case "requestIOSMotionPermission":
            requestMotionPermission(result)
        default:
            result(FlutterError(code: FlutterPluginCode.failure,
                                message: "not implemented",
                                details: nil)
            )
        }
    }
    
    private func isInitialized(_ result: @escaping FlutterResult) {
        result(RPEntry.isInitialized)
    }
    
    private func logout(_ result: @escaping FlutterResult) {
        RPEntry.instance.logout()
        result(nil)
    }
    
    private func getDeviceId(_ result: @escaping FlutterResult) {
        result(RPEntry.instance.virtualDeviceToken)
    }
    
    private func isAllRequiredPermissionsGranted(_ result: @escaping FlutterResult) {
        result(RPEntry.instance.isAllRequiredPermissionsGranted())
    }
    
    private func isSDKEnabled(_ result: @escaping FlutterResult) {
        result(RPEntry.instance.isSDKEnabled())
    }
    
    private func isTracking(_ result: @escaping FlutterResult) {
        result(RPEntry.instance.isTrackingActive())
    }
    
    private func setDeviceID(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let deviceId = args["deviceId"] as? String
        RPEntry.instance.virtualDeviceToken = deviceId
        result(nil)
    }
    
    private func setEnableSdk(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let enable = args["enable"] as! Bool
        
        RPEntry.instance.setEnableSdk(enable)
        result(nil)
    }
    
    private func setDisableTracking(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let value = args["value"] as! Bool
        
        RPEntry.instance.disableTracking = value
        result(nil)
    }
    
    private func isDisableTracking(result: @escaping FlutterResult) {
        result(RPEntry.instance.disableTracking)
    }

    private func startManualTracking(_ result: @escaping FlutterResult) {
        RPEntry.instance.startTracking()
        result(true)
    }

    private func startManualPersistentTracking(_ result: @escaping FlutterResult) {
        RPEntry.instance.startPersistentTracking()
        result(true)
    }

    private func stopManualTracking(_ result: @escaping FlutterResult) {
        RPEntry.instance.stopTracking()
        result(true)
    }
    
    private func uploadUnsentTrips(_ result: @escaping FlutterResult) {
        RPEntry.instance.uploadUnsentTrips()
        result(nil)
    }
    
    private func getUnsentTripCount(_ result: @escaping FlutterResult) {
        result(RPEntry.instance.getUnsentTripCount())
    }
    
    private func sendCustomHeartbeats(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let reason = args["reason"] as! String
        
        RPEntry.instance.sendCustomHeartbeat(reason)
        result(nil)
    }
    
    private func showPermissionWizard(_ call: FlutterMethodCall, _ result: @escaping FlutterReply) {
        RPPermissionsWizard.returnInstance().launch(finish: { _ in
            let wizardResult = RPEntry.instance.isAllRequiredPermissionsGranted() ? Constants.WizardResult.allGranted : Constants.WizardResult.notAllGranted
            self.channel.invokeMethod("onPermissionWizardResult", arguments: wizardResult)
        })
        result(nil)
    }
    
    private func setAggressiveHeartbeats(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let value = args["value"] as! Bool
        RPEntry.instance.setAggressiveHeartbeats(value)
        result(nil)
    }
    
    //MARK: - Future track tags
    
    private func getFutureTagStatusStrung(from status: RPTagStatus) -> String {
        switch status {
        case .success:
            return "SUCCESS"
        case .offline:
            return "OFFLINE"
        case .errorTagOperation:
            return "ERROR_TAG_OPERATION"
        case .invalidDeviceToken:
            return "INVALID_DEVICE_TOKEN"
        @unknown default:
            return ""
        }
    }
    
    private func getFutureTrackTags(_ result: @escaping FlutterResult) {
        RPEntry.instance.api.getFutureTrackTag { [weak self] status, tags in
            
            var strTags = [String]()
            
            tags.forEach {
                let tagJson: [String: Any?] = [
                    "tag": $0.tag,
                    "source": $0.source,
                    "type": $0.type,
                    "activationTime": Int($0.timestamp.timeIntervalSince1970)
                ]
                guard
                    let jsonString = try? JSONSerialization.data(withJSONObject: tagJson, options: .prettyPrinted),
                    let strTag = String(data: jsonString, encoding: .utf8)
                else {
                    result(FlutterError(code: FlutterPluginCode.failure,
                                        message: "Json serialization of tag failed",
                                        details: nil)
                    )
                    return
                }
                
                strTags.append(strTag)
            }
            
            let status = self?.getFutureTagStatusStrung(from: status) ?? "SUCCESS"
            let timestamp: Int = Int(tags.first?.timestamp.timeIntervalSince1970 ?? 0)
            let json: [String : Any?] = [
                "status": status,
                "tags": strTags,
                "time": timestamp
            ]
            self?.channel.invokeMethod("onGetTags", arguments: json)
            result(nil)
        }
    }
    
    private func addFutureTrackTag(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let tag = args["tag"] as? String
        let source = args["source"] as? String
        
        guard let tag else {
            result(FlutterError(code: FlutterPluginCode.failure,
                                message: "tag field is required",
                                details: nil)
            )
            return
        }
        
        let futureTag = RPFutureTag(tag: tag, source: source)
        RPEntry.instance.api.addFutureTrackTag(futureTag) { [weak self] status, error in
            if let error {
                result(FlutterError(code: FlutterPluginCode.failure,
                                    message: error.localizedDescription,
                                    details: nil)
                )
                return
            }
            
            let status = self?.getFutureTagStatusStrung(from: status) ?? "SUCCESS"
            let tagJson: [String: Any?] = [
                "tag": futureTag.tag,
                "source": futureTag.source,
                "type": futureTag.type,
                "activationTime": Int(futureTag.timestamp.timeIntervalSince1970)
            ]
            
            guard
                let jsonString = try? JSONSerialization.data(withJSONObject: tagJson, options: .prettyPrinted),
                let strTag = String(data: jsonString, encoding: .utf8)
            else {
                result(FlutterError(code: FlutterPluginCode.failure,
                                    message: "Json serialization of tag failed",
                                    details: nil)
                )
                return
            }
            
            let json: [String : Any?] = [
                "status": status,
                "tag": strTag,
                "activationTime": Int(futureTag.timestamp.timeIntervalSince1970)
            ]
            
            self?.channel.invokeMethod("onTagAdd", arguments: json)
            result(nil)
        }
    }
    
    private func removeFutureTrackTag(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let tag = args["tag"] as? String
        let source = args["source"] as? String
        
        guard let tag else {
            result(FlutterError(code: FlutterPluginCode.failure,
                                message: "tag field is required",
                                details: nil)
            )
            return
        }
        
        let futureTag = RPFutureTag(tag: tag, source: source)
        RPEntry.instance.api.removeFutureTrackTag(futureTag) { [weak self] status, error in
            if let error {
                result(FlutterError(code: FlutterPluginCode.failure,
                                    message: error.localizedDescription,
                                    details: nil)
                )
                return
            }
            
            let status = self?.getFutureTagStatusStrung(from: status) ?? "SUCCESS"
            let tagJson: [String: Any?] = [
                "tag": futureTag.tag,
                "source": futureTag.source,
                "type": futureTag.type,
                "activationTime": Int(futureTag.timestamp.timeIntervalSince1970)
            ]
            
            guard
                let jsonString = try? JSONSerialization.data(withJSONObject: tagJson, options: .prettyPrinted),
                let strTag = String(data: jsonString, encoding: .utf8)
            else {
                result(FlutterError(code: FlutterPluginCode.failure,
                                    message: "Json serialization of tag failed",
                                    details: nil)
                )
                return
            }
            
            let json: [String : Any?] = [
                "status": status,
                "tag": strTag,
                "activationTime": Int(futureTag.timestamp.timeIntervalSince1970)
            ]
            
            self?.channel.invokeMethod("onTagRemove", arguments: json)
            result(nil)
        }
    }
    
    private func removeAllFutureTrackTags(_ result: @escaping FlutterResult) {
        RPEntry.instance.api.removeAllFutureTrackTags { [weak self] status, error in
            let status = self?.getFutureTagStatusStrung(from: status) ?? "SUCCESS"
            let json: [String : Any?] = [
                "status": status,
                "time": 0
            ]
            
            self?.channel.invokeMethod("onAllTagsRemove", arguments: json)
            result(nil)
        }
    }
    
    
    /// wrongAccuracyAuthorization
    private func isWrongAccuracyState(_ result: @escaping FlutterResult) {
        result(RPEntry.instance.wrongAccuracyState)
    }
    
    private func getApiLanguage(_ result: @escaping FlutterResult) {
        let language = RPEntry.instance.apiLanguage
        switch language {
        case .none:
            result("None")
        case .english:
            result("English")
        case .russian:
            result("Russian")
        case .portuguese:
            result("Portuguese")
        case .spanish:
            result("Spanish")
        default:
            result("")
        }
    }
    
    /// Force API language.
    private func setApiLanguage(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let language = args["apiLanguage"] as? String else {
            result(nil)
            return
        }
        if language == "None" {
            RPEntry.instance.apiLanguage = .none
        }
        if language == "English" {
            RPEntry.instance.apiLanguage = .english
        }
        if language == "Russian" {
            RPEntry.instance.apiLanguage = .russian
        }
        if language == "Portuguese" {
            RPEntry.instance.apiLanguage = .portuguese
        }
        if language == "Spanish" {
            RPEntry.instance.apiLanguage = .spanish
        }
        
        result(nil)
    }
    
    private func isAggressiveHeartbeat(_ result: @escaping FlutterResult) {
        result(RPEntry.instance.aggressiveHeartbeat())
    }
    
    private func enableAccidents(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        guard let value = args["enableAccidents"] as? Bool else {
            result(nil)
            return
        }
        RPEntry.instance.enableAccidents(value)
        result(nil)
    }
    
    private func setAccidentDetectionSensitivity(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        guard let value = args["accidentDetectionSensitivity"] as? Int else {
            result(nil)
            return
        }
        let sensitivity = RPAccidentDetectionSensitivity.init(rawValue: value) ?? .normal
        RPEntry.instance.accidentDetectionSensitivity = sensitivity
        result(nil)
    }
    
    private func isEnabledAccidents(_ result: @escaping FlutterResult) {
        result(RPEntry.instance.isEnabledAccidents())
    }
    
    private func isRTLDEnabled(_ result: @escaping FlutterResult) {
        result(RPEntry.instance.isRTDEnabled())
    }
    
    private func requestLocationAlwaysPermission(_ result: @escaping FlutterResult) {
        RPEntry.instance.requestLocationAlwaysPermission()
        result(nil)
    }
    
    private func requestMotionPermission(_ result: @escaping FlutterResult) {
        RPEntry.instance.requestMotionPermission()
        result(nil)
    }
    
}

// MARK: - App Delegate

extension SwiftTelematicsSDKPlugin {
    
    //MARK: - Lifecycle handlers
    
    public func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) -> Bool {
        RPEntry.instance.application(
            application,
            handleEventsForBackgroundURLSession: identifier,
            completionHandler: completionHandler
        )
        return true
    }
    
    public func applicationDidReceiveMemoryWarning(
        _ application: UIApplication
    ) {
        RPEntry.instance.applicationDidReceiveMemoryWarning(
            application
        )
    }
    
    public func applicationWillTerminate(
        _ application: UIApplication
    ) {
        RPEntry.instance.applicationWillTerminate(
            application
        )
    }
    
    public func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) -> Bool {
        RPEntry.instance.application(application) {
            completionHandler(.newData)
        }
        return true
    }
    
    public func applicationDidEnterBackground(_ application: UIApplication) {
        RPEntry.instance.applicationDidEnterBackground(application)
    }
    
    public func applicationWillEnterForeground(_ application: UIApplication) {
        RPEntry.instance.applicationWillEnterForeground(application)
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        RPEntry.instance.applicationDidBecomeActive(application)
    }
    
}

// MARK: - Scene Delegate
extension SwiftTelematicsSDKPlugin: FlutterSceneLifeCycleDelegate {
    
    public func sceneDidDisconnect(_ scene: UIScene) { }
    
    public func sceneWillEnterForeground(_ scene: UIScene) {
        RPEntry.instance.sceneWillEnterForeground(scene)
    }
    
    public func sceneDidBecomeActive(_ scene: UIScene) {
        RPEntry.instance.sceneDidBecomeActive(scene)
    }
    
    public func sceneWillResignActive(_ scene: UIScene) { }
    
    public func sceneDidEnterBackground(_ scene: UIScene) {
        RPEntry.instance.sceneDidEnterBackground(scene)
    }
    
}

// MARK: - RPLowPowerModeDelegate
extension SwiftTelematicsSDKPlugin: RPLowPowerModeDelegate {
    
    public func lowPowerMode(_ state: Bool) {
        self.channel.invokeMethod("onLowPowerMode", arguments: state)
    }
    
}

// MARK: - RPTrackingStateListenerDelegate
extension SwiftTelematicsSDKPlugin: RPTrackingStateListenerDelegate {
    
    public func trackingStateChanged(_ state: Bool) {
        self.channel.invokeMethod("onTrackingStateChanged", arguments: state)
    }
    
}

// MARK: - RPAccuracyAuthorizationDelegate
extension SwiftTelematicsSDKPlugin: RPAccuracyAuthorizationDelegate {
    
    public func wrongAccuracyAuthorization() {
        //self.channel?.invokeMethod("onWrongAccuracyAuthorization", arguments: nil) //TO DO
    }
    
}

// MARK: - RPRTDLDelegate
extension SwiftTelematicsSDKPlugin: RPRTDLDelegate {
    
    public func rtldColectedData() {
        self.channel.invokeMethod("onRtldCollectedData", arguments: true)
    }
    
}

extension SwiftTelematicsSDKPlugin: RPLocationDelegate {
    
    public func onLocationChanged(_ location: CLLocation) {
        let latitude = location.coordinate.latitude as Double
        let longitude = location.coordinate.longitude as Double
        let json: [String : Any?] = [
            "latitude": latitude,
            "longitude": longitude
        ]
        self.channel.invokeMethod("onLocationChanged", arguments: json)
    }
    
    public func onNewEvents(_ events: [RPEventPoint]) {
        //self.channel?.invokeMethod("onNewEvents", arguments: json)
    }
}
