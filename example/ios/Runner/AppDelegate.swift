import Flutter
import UIKit
import RaxelPulse

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // Documentation: https://docs.damoov.com/docs/-download-the-sdk-and-install-it-in-your-environment#setting-up-the-permissions-wizard
      RPPermissionsWizard.returnInstance().launch(finish: { _ in
          RPEntry.initialize(withRequestingPermissions: true)
          let token = NSString(string: "Please, enter your Token")
          RPEntry.instance().virtualDeviceToken = token
          let options = launchOptions ?? [:]
          RPEntry.application(application, didFinishLaunchingWithOptions: options)
      })
      
      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
