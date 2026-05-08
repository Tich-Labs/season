import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else { return false }

        let webView = WKWebView(frame: window.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let url = URL(string: "https://seasonv2.onrender.com")!
        webView.load(URLRequest(url: url))

        let viewController = UIViewController()
        viewController.view.addSubview(webView)

        window.rootViewController = viewController
        window.makeKeyAndVisible()

        return true
    }
}