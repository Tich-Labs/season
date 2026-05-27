import HotwireNative
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var navigator = Navigator(
        configuration: .init(name: "SeasonApp", startLocation: baseURL),
        delegate: self
    )

    private lazy var tabBarController = HotwireTabBarController(
        navigatorDelegate: self
    )
    private var usingTabs = false

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        navigator.start()

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigator.rootViewController
        window?.makeKeyAndVisible()
    }

    private func switchToTabs() {
        guard !usingTabs else { return }
        usingTabs = true
        tabBarController.load(HotwireTab.all)
        window?.rootViewController = tabBarController
    }

    private func isAuthenticatedPath(_ path: String) -> Bool {
        return path.hasPrefix("/calendar") ||
            path.hasPrefix("/tracking") ||
            path.hasPrefix("/daily") ||
            path.hasPrefix("/symptoms") ||
            path.hasPrefix("/superpowers") ||
            path.hasPrefix("/settings") ||
            path.hasPrefix("/account") ||
            path.hasPrefix("/informations") ||
            path.hasPrefix("/feedback")
    }
}

extension SceneDelegate: NavigatorDelegate {
    func handle(
        proposal: VisitProposal,
        from navigator: Navigator
    ) -> ProposalResult {
        guard let host = proposal.url.host else { return .accept }

        if host == baseURL.host || host.hasSuffix(".onrender.com") || host.hasSuffix(".season.vision") {
            if isAuthenticatedPath(proposal.url.path) {
                switchToTabs()
            }
            return .accept
        }

        UIApplication.shared.open(proposal.url)
        return .reject
    }
}
