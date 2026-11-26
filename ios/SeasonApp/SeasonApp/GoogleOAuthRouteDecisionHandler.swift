import AuthenticationServices
import HotwireNative
import UIKit

final class GoogleOAuthRouteDecisionHandler: RouteDecisionHandler {
    let name = "google-calendar-oauth"

    private var authenticationSession: ASWebAuthenticationSession?
    private let presentationProvider = AuthenticationPresentationProvider()

    func matches(proposal: VisitProposal, configuration: Navigator.Configuration) -> Bool {
        guard proposal.url.host == configuration.startLocation.host else { return false }
        return proposal.url.path == "/settings/connect_google_calendar"
    }

    func handle(
        proposal: VisitProposal,
        configuration: Navigator.Configuration,
        navigator: Navigating
    ) -> Router.Decision {
        let direction = URLComponents(url: proposal.url, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "direction" })?.value

        Task { @MainActor in
            await startAuthentication(direction: direction, navigator: navigator)
        }

        return .cancel
    }

    @MainActor
    private func startAuthentication(direction: String?, navigator: Navigating) async {
        do {
            let authorizationURL = try await fetchAuthorizationURL(direction: direction)
            let callback = ASWebAuthenticationSession.Callback.https(
                host: "seasonv2.onrender.com",
                path: "/settings/google_calendar_callback"
            )
            let session = ASWebAuthenticationSession(url: authorizationURL, callback: callback) {
                [weak self, weak navigator] callbackURL, error in
                guard let self, let navigator else { return }
                Task { @MainActor in
                    await self.finish(callbackURL: callbackURL, error: error, navigator: navigator)
                }
            }
            session.presentationContextProvider = presentationProvider
            session.prefersEphemeralWebBrowserSession = false
            authenticationSession = session

            if !session.start() {
                authenticationSession = nil
                presentError("Unable to start Google Calendar sign-in.", on: navigator)
            }
        } catch {
            presentError(error.localizedDescription, on: navigator)
        }
    }

    @MainActor
    private func finish(callbackURL: URL?, error: Error?, navigator: Navigating) async {
        authenticationSession = nil

        guard error == nil else {
            if let error, (error as? ASWebAuthenticationSessionError)?.code != .canceledLogin {
                presentError(error.localizedDescription, on: navigator)
            }
            return
        }

        guard let callbackURL else { return }

        do {
            let items = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems ?? []
            guard let code = items.first(where: { $0.name == "code" })?.value,
                  let state = items.first(where: { $0.name == "state" })?.value else {
                throw AuthError.invalidCallback
            }

            let response = try await submit(code: code, state: state)
            navigator.route(
                baseURL.appending(path: "settings/calendar"),
                options: VisitOptions(action: .replace),
                parameters: nil
            )
            if response.status != "ok" {
                presentError(response.alert ?? "Failed to connect Google Calendar.", on: navigator)
            }
        } catch {
            presentError(error.localizedDescription, on: navigator)
        }
    }

    private func fetchAuthorizationURL(direction: String?) async throws -> URL {
        var components = URLComponents(
            url: baseURL.appending(path: "settings/google_calendar_auth_url"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "direction", value: direction ?? "one_way")]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw AuthError.requestFailed
        }

        return try JSONDecoder().decode(AuthorizationURLResponse.self, from: data).authURL
    }

    private func submit(code: String, state: String) async throws -> NativeCallbackResponse {
        var request = URLRequest(url: baseURL.appending(path: "settings/google_calendar_callback_native"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["code": code, "state": state])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw AuthError.requestFailed }

        let decoded = try JSONDecoder().decode(NativeCallbackResponse.self, from: data)
        guard (200..<300).contains(http.statusCode) else {
            throw AuthError.message(decoded.alert ?? "Failed to connect Google Calendar.")
        }
        return decoded
    }

    @MainActor
    private func presentError(_ message: String, on navigator: Navigating) {
        let alert = UIAlertController(title: "Google Calendar", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigator.activeNavigationController.present(alert, animated: true)
    }
}

private struct AuthorizationURLResponse: Decodable {
    let authURL: URL

    enum CodingKeys: String, CodingKey {
        case authURL = "auth_url"
    }
}

private struct NativeCallbackResponse: Decodable {
    let status: String
    let alert: String?
}

private enum AuthError: LocalizedError {
    case invalidCallback
    case requestFailed
    case message(String)

    var errorDescription: String? {
        switch self {
        case .invalidCallback: "Google Calendar returned an invalid response."
        case .requestFailed: "Could not reach Season. Check your connection and try again."
        case .message(let message): message
        }
    }
}

private final class AuthenticationPresentationProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) ?? ASPresentationAnchor()
    }
}
