import HotwireNative
import UIKit

final class GoogleOAuthRouteDecisionHandler: RouteDecisionHandler {
  let name: String = "google-oauth-system-browser"

  func matches(proposal: VisitProposal, configuration: Navigator.Configuration) -> Bool {
    proposal.url.host?.lowercased() == "accounts.google.com"
  }

  func handle(proposal: VisitProposal, configuration: Navigator.Configuration, navigator: Navigating) -> Router.Decision {
    Task { @MainActor in
      UIApplication.shared.open(proposal.url)
    }

    return .cancel
  }
}
