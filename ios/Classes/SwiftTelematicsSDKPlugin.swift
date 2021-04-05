import Flutter
import UIKit

public class SwiftTelematicsSDKPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "telematics_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftTelematicsSDKPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    default:
      print("not implemented")
    }
    result("iOS " + UIDevice.current.systemVersion)
  }
}
