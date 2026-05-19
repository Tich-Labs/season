import UIKit
import Turbo

class HotwireTabBarController: UIViewController, UITabBarDelegate {
    private let turboNavigator = TurboNavigator()
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Embed the TurboNavigator's root view controller
        let child = turboNavigator.rootViewController
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // Setup tab bar
        tabBar.items = tabs.enumerated().map { index, t in
            UITabBarItem(title: t.title, image: UIImage(systemName: t.systemImageName), tag: index)
        }
        tabBar.selectedItem = tabBar.items?.first
        tabBar.delegate = self
        view.addSubview(tabBar)

        child.view.translatesAutoresizingMaskIntoConstraints = false
        tabBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor),

            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Navigate to the first tab
        navigateToTab(index: 0)
    }

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
}
