import Foundation
import SocketIO

class WebSocketManager {
    static let shared = WebSocketManager()

    private var manager: SocketManager?
    private var socket: SocketIOClient?

    init() {
        configureSocketClient()
    }

    private func configureSocketClient() {
        let url = URL(string: "http://192.168.58.101:5000")! // Replace with your server URL
        manager = SocketManager(socketURL: url, config: [.log(true), .compress])
        socket = manager?.defaultSocket
    }

    func establishConnection() {
        socket?.connect()
        print("Connection has been Established")
    }

    func closeConnection() {
        socket?.disconnect()
    }

    func sendMessage(message: String, to event: String) {
        socket?.emit(event, message)
    }

    func listenToEvent(event: String, completion: @escaping (Any) -> Void) {
        socket?.on(event) { data, ack in
            completion(data)
        }
    }
}
