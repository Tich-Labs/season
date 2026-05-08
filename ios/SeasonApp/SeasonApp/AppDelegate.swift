import UIKit
import HotwireNative

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigator: HotwireNavigator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let navigator = HotwireNavigator()
        self.navigator = navigator

        // Point to your Rails app
        navigator.route("https://seasonv2.onrender.com")

        window.rootViewController = navigator.rootViewController
        window.makeKeyAndVisible()

        return true
    }
}
