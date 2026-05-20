import UIKit
import WebKit

class TestViewController: UIViewController, WKNavigationDelegate {
    private let webView = WKWebView()
    private let baseURL: String = {
        Bundle.main.object(forInfoDictionaryKey: "SEASON_BASE_URL") as? String ?? "http://192.168.1.10:3000"
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        view.addSubview(webView)

        if let url = URL(string: baseURL) {
            webView.load(URLRequest(url: url))
        }
    }
}
