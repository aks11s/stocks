import Foundation
import Starscream

protocol WebSocketServiceProtocol: AnyObject {
    var onData: ((Data) -> Void)? { get set }
    var onConnect: (() -> Void)? { get set }
    var onDisconnect: ((Error?) -> Void)? { get set }
    func connect(url: URL)
    func disconnect()
}

final class WebSocketService: WebSocketServiceProtocol, WebSocketDelegate {
    var onData: ((Data) -> Void)?
    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?

    private var socket: WebSocket?

    func connect(url: URL) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }

    func disconnect() {
        socket?.disconnect()
        socket = nil
    }

    // MARK: - WebSocketDelegate

    func didReceive(event: WebSocketEvent, client: any WebSocketClient) {
        switch event {
        case .connected:
            onConnect?()
        case .text(let string):
            guard let data = string.data(using: .utf8) else { return }
            onData?(data)
        case .binary(let data):
            onData?(data)
        case .disconnected:
            onDisconnect?(nil)
        case .error(let error):
            onDisconnect?(error)
        case .cancelled:
            onDisconnect?(nil)
        default:
            break
        }
    }
}
