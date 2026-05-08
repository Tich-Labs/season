import UIKit
import HotwireNative

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var navigator: HotwireNavigator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let navigator = HotwireNavigator()
        self.navigator = navigator

        // Point to your Rails app
        navigator.route("https://seasonv2.onrender.com")

        window.rootViewController = navigator.rootViewController
        window.makeKeyAndVisible()
    }
}
