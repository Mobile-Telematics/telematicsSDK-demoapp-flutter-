import Flutter
import UIKit
import TelematicsSDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      RPEntry.initializeSDK()
      RPEntry.instance.application(application, didFinishLaunchingWithOptions: launchOptions)
      GeneratedPluginRegistrant.register(with: self)
      if #available(iOS 13.0, *) {
          self.window.overrideUserInterfaceStyle = .light
      }
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
