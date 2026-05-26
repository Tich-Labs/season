import HotwireNative
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var tabBarController = HotwireTabBarController(
        navigatorDelegate: self
    )

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        tabBarController.tabBar.isHidden = true
        tabBarController.load(HotwireTab.all)
    }

    private func isAuthURL(_ url: URL) -> Bool {
        let path = url.path
        return path == "/" ||
            path.hasPrefix("/welcome") ||
            path.hasPrefix("/session") ||
            path.hasPrefix("/registration") ||
            path.hasPrefix("/onboarding") ||
            path.hasPrefix("/password") ||
            path.hasPrefix("/users") ||
            path.hasPrefix("/invite")
    }
}

extension SceneDelegate: NavigatorDelegate {
    func handle(
        proposal: VisitProposal,
        from navigator: Navigator
    ) -> ProposalResult {
        guard let host = proposal.url.host else { return .accept }

        if host == baseURL.host || host.hasSuffix(".onrender.com") || host.hasSuffix(".season.vision") {
            tabBarController.tabBar.isHidden = isAuthURL(proposal.url)
            return .accept
        }

        UIApplication.shared.open(proposal.url)
        return .reject
    }
}
