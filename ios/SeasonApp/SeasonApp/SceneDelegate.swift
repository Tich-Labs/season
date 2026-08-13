import HotwireNative
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // Guards against re-visiting on the very first activation, which immediately
    // follows willConnectTo(_:options:) on cold launch and already issued its own visit.
    private var hasBecomeActiveOnce = false

    // Timestamp of the last genuine background entry. Must stay in sync with
    // PinProtection::PIN_TIMEOUT (5 minutes) on the Rails side.
    private var backgroundedAt: Date?
    private static let pinTimeout: TimeInterval = 5 * 60

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
        // /app (HomeController#app), not the bare domain root — root maps to the
        // Login/Create Account welcome screen with no auth check at all, so an
        // already-logged-in user would see it flash by on every cold launch before
        // landing on calendar. /app does the authenticated?-based redirect instead.
        navigator.route(baseURL.appendingPathComponent("app"))
        navigator.start()
    }

    // App Lock: only fires on genuine background entry, not on transient
    // occlusions (Control Center, call banners, system alerts), which trigger
    // resignActive/becomeActive without ever backgrounding the scene.
    func sceneDidEnterBackground(_ scene: UIScene) {
        backgroundedAt = Date()
    }

    // Force a fresh visit of whatever's on screen when the app returns to the
    // foreground after being genuinely backgrounded past the PIN timeout, so the
    // pending server-side pin_unlock_required? check (and the pin/_unlock_modal
    // overlay) fires immediately instead of waiting for the next tap. Applies
    // regardless of whether Face ID/WebAuthn is registered — the visit itself is
    // what triggers the check, same as any other navigation would.
    func sceneDidBecomeActive(_ scene: UIScene) {
        guard hasBecomeActiveOnce else {
            hasBecomeActiveOnce = true
            return
        }

        defer { backgroundedAt = nil }

        guard let backgroundedAt,
              Date().timeIntervalSince(backgroundedAt) >= Self.pinTimeout else { return }

        guard let visitable = navigator.rootViewController.visibleViewController as? Visitable else { return }
        navigator.route(visitable.visitableURL, options: VisitOptions(action: .replace), animated: false)
    }
}

extension SceneDelegate: NavigatorDelegate {
    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        return .accept
    }
}
