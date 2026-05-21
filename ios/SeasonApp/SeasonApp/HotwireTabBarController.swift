import UIKit
import Turbo
import WebKit

class HotwireTabBarController: UIViewController, UITabBarDelegate {
    private let session: Session
    private let turboNavigator: TurboNavigator
    private let baseURL: String = {
        if let url = Bundle.main.object(forInfoDictionaryKey: "SEASON_BASE_URL") as? String {
            return url
        }
        return "https://seasonv2.onrender.com"
    }()

    private let tabBar = UITabBar()

    private let tabs: [Tab] = [
        Tab(title: "Calendar", systemImageName: "calendar", urlPath: "/calendar"),
        Tab(title: "Daily", systemImageName: "calendar.circle", urlPath: "/daily"),
        Tab(title: "Tracking", systemImageName: "chart.pie", urlPath: "/tracking")
    ]

    // MARK: - Init

    init() {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "Turbo Native iOS"

        let tokenScript = WKUserScript(
            source: HotwireTabBarController.tokenExtractionJS(),
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(tokenScript)

        self.session = Session(webViewConfiguration: config)
        self.turboNavigator = TurboNavigator(session: session)

        super.init(nibName: nil, bundle: nil)

        session.delegate = self
        config.userContentController.add(self, name: "nativeAuth")
        configurePathConfiguration()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        injectAuthCookie { [weak self] in
            self?.embedTurboNavigator()
            self?.setupTabBar()
            self?.navigateToTab(index: 0)
        }
    }

    // MARK: - Layout

    private func embedTurboNavigator() {
        let child = turboNavigator.rootViewController
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)

        child.view.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupTabBar() {
        tabBar.items = tabs.enumerated().map { index, t in
            UITabBarItem(title: t.title, image: UIImage(systemName: t.systemImageName), tag: index)
        }
        tabBar.selectedItem = tabBar.items?.first
        tabBar.delegate = self
        tabBar.tintColor = UIColor(red: 0.58, green: 0.23, blue: 0.21, alpha: 1.0) // #933a35
        tabBar.unselectedItemTintColor = UIColor(red: 0.58, green: 0.23, blue: 0.21, alpha: 0.5)
        tabBar.backgroundColor = .white
        view.addSubview(tabBar)

        tabBar.translatesAutoresizingMaskIntoConstraints = false

        guard let childView = turboNavigator.rootViewController.view else { return }

        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: view.topAnchor),
            childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),

            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Path Configuration

    private func configurePathConfiguration() {
        let configURL = "\(baseURL)/configurations/ios_v1.json"
        guard let url = URL(string: configURL) else { return }
        session.pathConfiguration = PathConfiguration(sources: [.server(url)])
    }

    // MARK: - Auth Cookie

    private func injectAuthCookie(completion: @escaping () -> Void) {
        guard let token = KeychainHelper.retrieve(),
              let url = URL(string: baseURL) else {
            completion()
            return
        }

        var properties: [HTTPCookiePropertyKey: Any] = [
            .domain: url.host ?? "",
            .path: "/",
            .name: "native_auth_token",
            .value: token,
            .expires: Date().addingTimeInterval(30 * 24 * 60 * 60)
        ]
        if url.scheme == "https" {
            properties[.secure] = true
        }

        let cookie = HTTPCookie(properties: properties)!
        session.webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
            completion()
        }
    }

    // MARK: - Tab Navigation

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        navigateToTab(index: item.tag)
    }

    private func navigateToTab(index: Int) {
        guard index >= 0 && index < tabs.count else { return }
        let tab = tabs[index]
        var urlString = baseURL + tab.urlPath
        if tab.urlPath == "/daily" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: Date())
            urlString += "/\(dateString)"
        }
        if let url = URL(string: urlString) {
            turboNavigator.navigate(to: url)
        }
    }

    // MARK: - Token Extraction JS

    private static func tokenExtractionJS() -> String {
        return """
        (function() {
            var meta = document.querySelector('meta[name="native-auth-token"]');
            if (meta && meta.content) {
                window.webkit.messageHandlers.nativeAuth.postMessage(meta.content);
            }
        })();
        """
    }
}

// MARK: - WKScriptMessageHandler

extension HotwireTabBarController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard message.name == "nativeAuth",
              let token = message.body as? String,
              !token.isEmpty else { return }
        KeychainHelper.store(token)
    }
}

// MARK: - SessionDelegate

extension HotwireTabBarController: SessionDelegate {
    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        if let token = KeychainHelper.retrieve() {
            var headers = proposal.properties["httpHeaders"] as? [String: String] ?? [:]
            headers["X-Turbo-Native-Token"] = token
            proposal.properties["httpHeaders"] = headers
        }
        session.visit(proposal)
    }

    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        print("[Turbo Native] Visit failed: \(error.localizedDescription)")
    }

    func sessionWebViewProcessDidTerminate(_ session: Session) {
        session.reload()
    }
}
