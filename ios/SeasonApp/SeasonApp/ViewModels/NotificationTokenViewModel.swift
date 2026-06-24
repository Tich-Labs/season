import Foundation

class NotificationTokenViewModel {
    func register(_ token: String) async {
        let url = baseURL.appending(path: "push_subscriptions")

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authToken = KeychainHelper.read(key: "nativeAuthToken") {
            req.setValue(authToken, forHTTPHeaderField: "X-Native-Auth-Token")
        }

        do {
            let body = NotificationToken(token: token)
            req.httpBody = try JSONEncoder().encode(body)
            _ = try await URLSession.shared.data(for: req)
            print("[Push] Token registered successfully")
        } catch {
            print("[Push] Token registration failed: \(error.localizedDescription)")
        }
    }
}
