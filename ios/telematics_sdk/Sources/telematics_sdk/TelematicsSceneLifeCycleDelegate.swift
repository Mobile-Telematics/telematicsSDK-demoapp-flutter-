import Foundation
import Flutter
import TelematicsSDK


public class TelematicsSceneLifeCycleDelegate: NSObject, FlutterSceneLifeCycleDelegate {
    // MARK: - FlutterSceneLifeCycleDelegate
    
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
