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

        navigator.route(baseURL)
        navigator.start()
    }
}

extension SceneDelegate: NavigatorDelegate {
    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        return .accept
    }

    func requestDidFinish(at url: URL) {
        navigator.session.webView?.evaluateJavaScript("""
            (function() {
                var el = document.querySelector('[data-native-navbar]');
                if (!el) return null;
                return JSON.stringify({
                    bg: el.getAttribute('data-native-navbar-bg') || '#933a35',
                    fg: el.getAttribute('data-native-navbar-fg') || '#FFFFFF'
                });
            })()
        """) { [weak self] result, error in
            guard let self = self,
                  let json = result as? String,
                  let data = try? JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: String],
                  let bg = data["bg"],
                  let fg = data["fg"] else { return }

            let navController = self.navigator.rootViewController
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(hex: bg)
            appearance.titleTextAttributes = [.foregroundColor: UIColor(hex: fg)]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(hex: fg)]

            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
            navController.navigationBar.tintColor = UIColor(hex: fg)
        }
    }
}
