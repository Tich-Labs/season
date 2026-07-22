import HotwireNative
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var navigator = Navigator(
        delegate: self,
        rootViewController: UINavigationController()
    )

    private lazy var notificationRouter = NotificationRouter(
        navigationHandler: navigator
    )

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        UNUserNotificationCenter.current().delegate = notificationRouter

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigator.rootViewController
        window.makeKeyAndVisible()
        self.window = window

        navigator.rootViewController.navigationBar.isHidden = true
        navigator.route(baseURL)
        navigator.start()
    }
}

extension SceneDelegate: NavigatorDelegate {
    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        return .accept
    }
}
