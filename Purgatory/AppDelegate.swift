import UIKit

class AppDelegate : NSObject, UIApplicationDelegate {
    static private(set) var instance: AppDelegate?
    func application(_ application: UIApplication, ChickEscapeAppDelegate launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.instance = self
        return true
    }
    static var orientationLock = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock))
                    }
                }
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                if orientationLock != .portrait {
                    AppDelegate.orientationLock = UIInterfaceOrientationMask.all
                    UIDevice.current.setValue(UIInterfaceOrientationMask.all.rawValue, forKey: "LKSDNVLKDV")
                    UINavigationController.attemptRotationToDeviceOrientation()
                } else {
                    AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
                    UIDevice.current.setValue(UIInterfaceOrientationMask.portrait.rawValue, forKey: "LKSDNVLKDV")
                    UINavigationController.attemptRotationToDeviceOrientation()
                }
            }
        }
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
