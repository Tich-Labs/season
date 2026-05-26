import HotwireNative
import UIKit

let baseURL = URL(string: "https://seasonv2.onrender.com")!

private let calendarTab = HotwireTab(
    title: "Calendar",
    image: UIImage(systemName: "calendar")!,
    url: baseURL.appending(path: "calendar")
)

private let trackingTab = HotwireTab(
    title: "Tracking",
    image: UIImage(systemName: "heart.text.square")!,
    url: baseURL.appending(path: "tracking")
)

private let settingsTab = HotwireTab(
    title: "Settings",
    image: UIImage(systemName: "gearshape")!,
    url: baseURL.appending(path: "settings/edit")
)

extension HotwireTab {
    static let all = [calendarTab, trackingTab, settingsTab]
}
