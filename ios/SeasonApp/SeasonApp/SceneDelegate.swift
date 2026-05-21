import UIKit
import Turbo

private let baseURL = URL(string: "https://seasonv2.onrender.com")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var navigator: Navigator!
    private lazy var navigationController = UINavigationController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        navigationController.setNavigationBarHidden(true, animated: false)
        navigator = Navigator(delegate: self)
        navigator.transientViewControllers = [navigationController]

        let root = VisitableViewController(url: baseURL)
        navigationController.viewControllers = [root]

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

extension SceneDelegate: NavigatorDelegate {
    func navigator(_ navigator: Navigator, didProposeVisit proposal: VisitProposal) {
        guard isInternalURL(proposal.url) else {
            UIApplication.shared.open(proposal.url)
            return
        }

        let viewController = VisitableViewController(url: proposal.url)
        if proposal.properties?.action == "replace" {
            navigationController.setViewControllers([viewController], animated: false)
        } else {
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    func navigator(_ navigator: Navigator, didFailVisit visit: Visit, error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            visit.reload()
        })
        navigationController.present(alert, animated: true)
    }

    func navigator(_ navigator: Navigator, didFinishRequestForVisit visit: Visit) {
        let viewController = navigationController.topViewController as? VisitableViewController
        viewController?.presentedVisitable?.updateVisitableView()
    }

    private func isInternalURL(_ url: URL) -> Bool {
        guard let host = url.host else { return false }

        if host == baseURL.host { return true }
        if host.hasSuffix(".onrender.com") { return true }
        if host.hasSuffix(".season.vision") { return true }
        if host.hasSuffix(".seasonapp.co") { return true }

        return false
    }
}
