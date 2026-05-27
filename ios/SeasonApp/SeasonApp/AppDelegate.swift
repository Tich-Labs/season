import HotwireNative
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        loadPathConfiguration()
        return true
    }

    private func loadPathConfiguration() {
        guard let localURL = Bundle.main.url(forResource: "path-configuration", withExtension: "json"),
              let remoteURL = URL(string: "https://seasonv2.onrender.com/configurations/ios_v1.json") else {
            return
        }

        Hotwire.loadPathConfiguration(from: [
            .file(localURL),
            .server(remoteURL)
        ])
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}
