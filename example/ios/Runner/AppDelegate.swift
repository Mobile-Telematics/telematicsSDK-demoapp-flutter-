import Flutter
import UIKit
import RaxelPulse

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      RPEntry.initialize(withRequestingPermissions: false)
      
      let options = launchOptions ?? [:]
      RPEntry.application(application, didFinishLaunchingWithOptions: options)
      
      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
