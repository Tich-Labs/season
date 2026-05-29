import HotwireNative
import UIKit

class NativeAuthTokenComponent: BridgeComponent {
    override class var name: String { "native-auth-token" }

    override func onReceive(message: Message) {
        if message.event == "connect" {
            connect(via: message)
        }
    }

    private func connect(via message: Message) {
        guard let data: MessageData = message.data() else { return }
        KeychainHelper.save(key: "nativeAuthToken", value: data.token)
    }
}

extension NativeAuthTokenComponent {
    struct MessageData: Decodable {
        let token: String
    }
}
