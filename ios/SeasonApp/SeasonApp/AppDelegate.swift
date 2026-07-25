import HotwireNative
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let notificationTokenViewModel = NotificationTokenViewModel()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Hotwire.loadPathConfiguration(from: [
            .server(baseURL.appending(path: "configurations/ios_v1.json"))
        ])

        Hotwire.registerBridgeComponents([
            ButtonComponent.self,
            NotificationTokenComponent.self
        ])

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        Task { await notificationTokenViewModel.register(token) }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: any Error
    ) {
        print("[Push] Failed to register: \(error.localizedDescription)")
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
