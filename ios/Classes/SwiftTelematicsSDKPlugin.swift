import Flutter
import RaxelPulse
import UIKit

struct Constants {
    struct WizardResult {
        static let allGranted = "WIZARD_RESULT_ALL_GRANTED"
        static let notAllGranted = "WIZARD_RESULT_NOT_ALL_GRANTED"
    }
}

public class SwiftTelematicsSDKPlugin: NSObject, FlutterPlugin, RPLowPowerModeDelegate {
    private var channel: FlutterMethodChannel?
    private var tagStateDelegate: TagStateDelegate?

    public init(methodChannel: FlutterMethodChannel) {
        super.init()
        channel = methodChannel
        tagStateDelegate = TagStateDelegate(methodChannel: methodChannel)
        RPEntry.instance().tagStateDelegate = tagStateDelegate
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
        case "startTracking":
            startTracking(result)
        case "stopTracking":
            stopTracking(result)
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
        result(RPEntry.isSDKEnabled())
    }

    private func isTracking(_ result: @escaping FlutterResult) {
        result(RPTracker.instance().isActive)
    }

    private func setDeviceID(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]

        RPEntry.instance().virtualDeviceToken = (args["deviceId"] as! String) as NSString

        result(nil)
    }

    private func setEnableSdk(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let enable = args["enable"] as! Bool
        let uploadBeforeDisabling = args["uploadBeforeDisabling"] as! Bool

        if !enable && uploadBeforeDisabling {
            RPEntry.instance().setDisableWithUpload()
        } else {
            RPEntry.instance().setEnableSdk(enable)
        }

        result(nil)
    }

    private func startTracking(_ result: @escaping FlutterResult) {
        RPEntry.instance().disableTracking = false

        result(nil)
    }

    private func stopTracking(_ result: @escaping FlutterResult) {
        RPEntry.instance().disableTracking = true

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

    /// Lifecycle handlers

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

    /// Handle low power
    public func lowPowerMode(_ state: Bool) {
        self.channel?.invokeMethod("onLowPowerMode", arguments: state)
    }

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
}
