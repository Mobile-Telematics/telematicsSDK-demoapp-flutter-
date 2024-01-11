import Flutter
import RaxelPulse
import UIKit

struct Constants {
    struct WizardResult {
        static let allGranted = "WIZARD_RESULT_ALL_GRANTED"
        static let notAllGranted = "WIZARD_RESULT_NOT_ALL_GRANTED"
    }
}

public class SwiftTelematicsSDKPlugin: NSObject, FlutterPlugin, RPLowPowerModeDelegate, RPLogDelegate, RPTrackingStateListenerDelegate, RPAccuracyAuthorizationDelegate, RPRTDLDelegate, RPLocationDelegate {
    
    private var channel: FlutterMethodChannel?
    private var tagStateDelegate: TagStateDelegate?
    
    public init(methodChannel: FlutterMethodChannel) {
        super.init()
        channel = methodChannel
        tagStateDelegate = TagStateDelegate(methodChannel: methodChannel)
        RPEntry.instance().tagStateDelegate = tagStateDelegate
        RPEntry.instance().lowPowerModeDelegate = self
        RPEntry.instance().locationDelegate = self
        RPEntry.instance().accuracyAuthorizationDelegate = self
        RPEntry.instance().trackingStateDelegate = self
        RPEntry.instance().logDelegate = self
        RPEntry.instance().rtldDelegate = self
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "telematics_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftTelematicsSDKPlugin(methodChannel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "clearDeviceID":
            clearDeviceID(result)
        case "getDeviceId":
            getDeviceId(result)
        case "isAllRequiredPermissionsAndSensorsGranted":
            isAllRequiredPermissionsGranted(result)
        case "isSdkEnabled":
            isSDKEnabled(result)
        case "isTracking":
            isTracking(result)
        case "setDeviceID":
            setDeviceID(call, result: result)
        case "setEnableSdk":
            setEnableSdk(call, result: result)
        case "setDisableWithUpload":
            setDisableWithUpload(result)
         case "setDisableTracking":
            setDisableTracking(call, result: result)
        case "startManualTracking":
            startManualTracking(result)
        case "stopManualTracking":
            stopManualTracking(result)
        case "showPermissionWizard":
            showPermissionWizard(call, result)
        case "setAggressiveHeartbeats":
            setAggressiveHeartbeats(call, result)
        case "getTrackTags":
            getTrackTags(call, result)
        case "addTrackTags":
            addTrackTags(call, result)
        case "removeTrackTags":
            removeTrackTags(call, result)
        case "getFutureTrackTags":
            getFutureTrackTags(result)
        case "addFutureTrackTag":
            addFutureTrackTag(call, result)
        case "removeFutureTrackTag":
            removeFutureTrackTag(call, result)
        case "removeAllFutureTrackTags":
            removeAllFutureTrackTags(result)
        case "getSdkVersion":
            getSdkVersion(result)
        case "isWrongAccuracyState":
            isWrongAccuracyState(result)
        case "setWrongAccuracyState":
            setWrongAccuracyState(call, result)
        case "getApiLanguage":
            getApiLanguage(result)
        case "setApiLanguage":
            setApiLanguage(call, result)
        case "initializeSdk":
            initializeSdk(call, result)
        case "isAggressiveHeartbeat":
            isAggressiveHeartbeat(result)
        case "setHeartbeatType":
            setHeartbeatType(call, result)
        case "enableHF":
            enableHF(call, result)
        case "enableELM":
            enableELM(call, result)
        case "enableAccidents":
            enableAccidents(call, result)
        case "enableRTLD":
            enableRTLD(call, result)
        case "isRTLDEnabled":
            isRTLDEnabled(result)
        case "getRTLDData":
            getRTLDData(result)
        case "getCurrentSpeed":
            getCurrentSpeed(result)
        default:
            print("not implemented")
        }
    }
    
    private func clearDeviceID(_ result: @escaping FlutterResult) {
        RPEntry.instance().removeVirtualDeviceToken()
        
        result(nil)
    }
    
    private func getDeviceId(_ result: @escaping FlutterResult) {
        result(RPEntry.instance().virtualDeviceToken)
    }
    
    private func isAllRequiredPermissionsGranted(_ result: @escaping FlutterResult) {
        result(RPEntry.isAllRequiredPermissionsGranted())
    }
    
    private func isSDKEnabled(_ result: @escaping FlutterResult) {
        guard let token = RPEntry.instance().virtualDeviceToken else {
            result(false)
            return
        }
        
        if (token as String).isEmpty {
            result(false)
            return
        }
        
        result(RPEntry.isSDKEnabled())
    }
    
    private func isTracking(_ result: @escaping FlutterResult) {
        result(RPTracker.instance().isActive)
    }
    
    private func setDeviceID(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        if let deviceId = args["deviceId"] as? String {
            let virtualDeviceToken = NSString(string: deviceId)
            RPEntry.instance().virtualDeviceToken = virtualDeviceToken
        } else {
            RPEntry.instance().virtualDeviceToken = nil
        }
        
        result(nil)
    }
    
    private func setEnableSdk(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let enable = args["enable"] as! Bool
        
        RPEntry.instance().setEnableSdk(enable)
        result(nil)
    }
    
    private func setDisableWithUpload(_ result: @escaping FlutterResult) {
        RPEntry.instance().setDisableWithUpload()
        result(nil)
    }
    
    private func setDisableTracking(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let value = args["value"] as! Bool
        
        RPEntry.instance().disableTracking = value
        result(nil)
    }

    private func startManualTracking(_ result: @escaping FlutterResult) {
         RPTracker.instance().startTracking()
         result(nil)
    }

    private func stopManualTracking(_ result: @escaping FlutterResult) {
         RPTracker.instance().stopTracking()
         result(nil)
    }
    
    private func showPermissionWizard(_ call: FlutterMethodCall, _ result: @escaping FlutterReply) {
        RPPermissionsWizard.returnInstance().launch(finish: { _ in
            let wizardResult = RPEntry.isAllRequiredPermissionsGranted() ? Constants.WizardResult.allGranted : Constants.WizardResult.notAllGranted
            
            self.channel?.invokeMethod("onPermissionWizardResult", arguments: wizardResult)
        })
        result(nil)
    }
    
    private func setAggressiveHeartbeats(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let value = args["value"] as? Bool
        
        let prevValue = RPEntry.instance().aggressiveHeartbeat()
        
        RPEntry.instance().setAggressiveHeartbeats(value ?? prevValue)
        
        result(nil)
    }
    
    //MARK: - Lifecycle handlers
    
    public func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        RPEntry.application(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }
    
    public func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        RPEntry.applicationDidReceiveMemoryWarning(application)
    }
    
    public func applicationWillTerminate(_ application: UIApplication) {
        RPEntry.applicationWillTerminate(application)
    }
    
    public func applicationDidEnterBackground(_ application: UIApplication) {
        RPEntry.applicationDidEnterBackground(application)
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        RPEntry.applicationDidBecomeActive(application)
    }
    
    public func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        RPEntry.application(application) {
            completionHandler(.newData)
        }
    }
    
    //MARK: - Delegate callbacks
    
    /// Handle Low power
    public func lowPowerMode(_ state: Bool) {
        self.channel?.invokeMethod("onLowPowerMode", arguments: state)
    }
    
    /// Handle Location change and Events
    public func onLocationChanged(_ location: CLLocation!) {
        let latitude = location.coordinate.latitude as Double
        let longitude = location.coordinate.longitude as Double
        let json: [String : Any?] = [
            "latitude": latitude,
            "longitude": longitude
        ]
        self.channel?.invokeMethod("onLocationChanged", arguments: json)
    }
    
    public func onNewEvents(_ events: NSMutableArray!) {  //TO DO
        for item in events {
            if let theItem = item as? RPEventPoint {
                
            }
        }
        //self.channel?.invokeMethod("onNewEvents", arguments: json)
    }
    
    /// Handle Low accuracy mode
    /// Notify user "Precise Location is off. Your trips may be not recorded. Please, follow to App Settings=>Location=>Precise Location"
    public func wrongAccuracyAuthorization() {
        //self.channel?.invokeMethod("onWrongAccuracyAuthorization", arguments: nil) //TO DO
    }
    
    /// Handle Tracking status changing
    public func trackingStateChanged(_ state: Bool) {
        self.channel?.invokeMethod("onTrackingStateChanged", arguments: state)
    }
    
    /// Handle Log event and Log warning
    public func logEvent(_ event: String) {
        self.channel?.invokeMethod("onLogEvent", arguments: event as String)
    }
    
    public func logWarning(_ warning: String) {
        self.channel?.invokeMethod("onLogWarning", arguments: warning as String)
    }
    
    /// Handle heartbeat sending state and collecting data state
    public func heartbeatSended(_ state: Bool, success: Bool) {
        let json: [String : Any?] = [
            "state": state,
            "success": success
        ]
        self.channel?.invokeMethod("onHeartbeatSent", arguments: json)
    }
    
    public func rtldColecctedData(_ state: Bool) {
        self.channel?.invokeMethod("onRtldCollectedData", arguments: state)
    }
    
    
    
    //MARK: - Track tags
    
    private func getTrackTags(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let trackId = args["trackId"] as! String
        
        RPEntry.instance().api.getTrackTags(trackId) { response, error in
            let tags = response as? RPTags
            
            var res = [String]()
            
            tags?.tags.forEach { element in
                do {
                    let json = try JSONSerialization.data(withJSONObject: element.toJSON(), options: .prettyPrinted)
                    let str = String(data: json, encoding: .utf8)!
                    res.append(str)
                } catch {
                    result(FlutterError(code: FlutterPluginCode.failure,
                                        message: "Json serialization of tag failed",
                                        details: nil)
                    )
                }
            }
            
            result(res)
        }
    }
    
    private func addTrackTags(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let trackId = args["trackId"] as! String
        let strings = args["tags"] as! [String]
        
        let tags = strings.map { (element) -> RPTag in
            if let data = element.data(using: .utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data)
                    return RPTag.init(json: json)!
                } catch {
                    result(FlutterError(code: FlutterPluginCode.failure,
                                        message: "Json deserialization of tag failed",
                                        details: nil)
                    )
                }
            }
            return RPTag()
        }
        
        RPEntry.instance().api.addTrackTags(tags, to: trackId) { response, error in
            let tags = response as? RPTags
            
            var res = [String]()
            
            tags?.tags.forEach { element in
                do {
                    let json = try JSONSerialization.data(withJSONObject: element.toJSON(), options: .prettyPrinted)
                    let str = String(data: json, encoding: .utf8)!
                    res.append(str)
                } catch {
                    result(FlutterError(code: FlutterPluginCode.failure,
                                        message: "Json serialization of tag failed",
                                        details: nil)
                    )
                }
            }
            
            result(res)
        }
    }
    
    private func removeTrackTags(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let trackId = args["trackId"] as! String
        let strings = args["tags"] as! [String]
        
        let tags = strings.map { (element) -> RPTag in
            if let data = element.data(using: .utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data)
                    return RPTag.init(json: json)!
                } catch {
                    result(FlutterError(code: FlutterPluginCode.failure,
                                        message: "Json deserialization of tag failed",
                                        details: nil)
                    )
                }
            }
            return RPTag()
        }
        
        RPEntry.instance().api.removeTrackTags(tags, from: trackId) { response, error in
            let tags = response as? RPTags
            
            var res = [String]()
            
            tags?.tags.forEach { element in
                do {
                    let json = try JSONSerialization.data(withJSONObject: element.toJSON(), options: .prettyPrinted)
                    let str = String(data: json, encoding: .utf8)!
                    res.append(str)
                } catch {
                    result(FlutterError(code: FlutterPluginCode.failure,
                                        message: "Json serialization of tag failed",
                                        details: nil)
                    )
                }
            }
            
            result(res)
        }
        
    }
    
    //MARK: - Future track tags
    
    private func getFutureTrackTags(_ result: @escaping FlutterResult) {
        RPEntry.instance().api.getFutureTrackTag(0, completion: nil)
        
        result(nil)
    }
    
    private func addFutureTrackTag(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let _tag = args["tag"] as! String?
        let _source = args["source"] as! String?
        
        let json = ["tag": _tag, "source": _source]
        let tag = RPTag.init(json: json)
        
        RPEntry.instance().api.addFutureTrackTag(tag, completion: nil)
        
        result(nil)
    }
    
    private func removeFutureTrackTag(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let _tag = args["tag"] as! String?
        
        let json = ["tag": _tag]
        let tag = RPTag.init(json: json)
        
        RPEntry.instance().api.removeFutureTrackTag(tag, completion: nil)
        
        result(nil)
    }
    
    private func removeAllFutureTrackTags(_ result: @escaping FlutterResult) {
        RPEntry.instance().api.removeAllFutureTrackTagsWithСompletion(nil)
        
        result(nil)
    }
    
    
    //MARK: - Methods
    
    /// Current SDK Version
    private func getSdkVersion(_ result: @escaping FlutterResult) {
        result(RPEntry.instance().version)
    }
    
    /// wrongAccuracyAuthorization
    private func isWrongAccuracyState(_ result: @escaping FlutterResult) {
        result(RPEntry.instance().wrongAccuracyState)
    }
    
    private func setWrongAccuracyState(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let value = args["value"] as? Bool else {
            result(nil)
            return
        }
        RPEntry.instance().wrongAccuracyState = value
        result(nil)
    }
    
    private func getApiLanguage(_ result: @escaping FlutterResult) {
        let language = RPEntry.instance().apiLanguage
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
            RPEntry.instance().apiLanguage = RPApiLanguage.none
        }
        if language == "English" {
            RPEntry.instance().apiLanguage = RPApiLanguage.english
        }
        if language == "Russian" {
            RPEntry.instance().apiLanguage = RPApiLanguage.russian
        }
        if language == "Portuguese" {
            RPEntry.instance().apiLanguage = RPApiLanguage.portuguese
        }
        if language == "Spanish" {
            RPEntry.instance().apiLanguage = RPApiLanguage.spanish
        }
        
        result(nil)
    }
    
    /*
     Initializes new RPEntry class instance with specified device ID. Must be the first method calling from RaxelPulse SDK.
     withRequestingPermissions Indicates whether the SDK should request system permissions.
     */
    private func initializeSdk(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let value = args["value"] as? Bool else {
            result(nil)
            return
        }
        RPEntry.initialize(withRequestingPermissions: value)
        result(nil)
    }
    
    private func isAggressiveHeartbeat(_ result: @escaping FlutterResult) {
        result(RPEntry.instance().aggressiveHeartbeat())
    }
    
    private func setHeartbeatType(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        guard let heartbeatType = args["heartbeatType"] as? Int else {
            result(nil)
            return
        }
        RPEntry.setHeartbeatType(HeartbeatType(rawValue: heartbeatType))
        result(nil)
    }
    
    private func enableHF(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        guard let value = args["enableHF"] as? Bool else {
            result(nil)
            return
        }
        RPEntry.enableHF(value)
        result(nil)
    }
    
    private func enableELM(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        guard let value = args["enableELM"] as? Bool else {
            result(nil)
            return
        }
        RPEntry.enableELM(value)
        result(nil)
    }
    
    private func enableAccidents(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        guard let value = args["enableAccidents"] as? Bool else {
            result(nil)
            return
        }
        RPEntry.enableAccidents(value)
        result(nil)
    }
    
    private func isEnabledELM(_ result: @escaping FlutterResult) {
        result(RPEntry.isEnabledELM())
    }
    
    private func isEnabledAccidents(_ result: @escaping FlutterResult) {
        result(RPEntry.isEnabledAccidents())
    }
    
    private func enableRTLD(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        guard let value = args["enableRTLD"] as? Bool else {
            result(nil)
            return
        }
        RPEntry.enableRTLD(value)
        result(nil)
    }
    
    private func isRTLDEnabled(_ result: @escaping FlutterResult) {
        result(RPEntry.isRTDEnabled())
    }
    
    private func getRTLDData(_ result: @escaping FlutterResult) {
        RPEntry.getRTLData { stringData in
            result(stringData as String)
        }
    }
    
    private func getCurrentSpeed(_ result: @escaping FlutterResult) {
        RPEntry.instance().currentSpeed { speed in
            result(speed.doubleValue)
        }
    }
}
