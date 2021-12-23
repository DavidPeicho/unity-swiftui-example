import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            // Creates the bridge between UIKit and SwiftUI.
            // This is done automatically when not using an `App`.
            let vc = UIHostingController(rootView: ContentView())
            
            // Sets the UIHostingView to transparent so we can see
            // the Unity window behind it.
            vc.view.isOpaque = false
            vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
            vc.view.tag = UIWindowCustom.PassthroughTag

            self.window = UIWindowCustom(windowScene: windowScene)
            self.window!.windowLevel = .normal + 100.0
            self.window!.rootViewController = vc

            self.window!.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
