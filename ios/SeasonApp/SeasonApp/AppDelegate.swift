import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        // Create WebView
        let webView = WKWebView(frame: window.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Load Season app
        let url = URL(string: "https://seasonv2.onrender.com")!
        let request = URLRequest(url: url)
        webView.load(request)

        // Create view controller
        let viewController = UIViewController()
        viewController.view.addSubview(webView)

        window.rootViewController = viewController
        window.makeKeyAndVisible()

        return true
    }
}