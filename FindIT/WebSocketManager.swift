import Foundation
import SocketIO

class WebSocketManager {
    static let shared = WebSocketManager()
    private var isConnectedPrinted: Bool = false // Flag to track if connection message is printed

    
    private var manager: SocketManager?
    private var socket: SocketIOClient?

    init() {
        configureSocketClient()
    }

    private func configureSocketClient() {
        isConnectedPrinted = false
        // Fetching the host from environment variables
        let host = ProcessInfo.processInfo.environment["HOST"] ?? "defaultHost" // Replace 'defaultHost' with a fallback host if needed

        // Constructing the URL using the environment variable
        let urlString = "http://\(host):5000" // Assuming the port is always 5000
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        manager = SocketManager(socketURL: url, config: [.log(true), .compress])
        socket = manager?.defaultSocket
    }

    func establishConnection() {
        socket?.connect()
        //print("Establishing Connection.....")
        
        socket?.on(clientEvent: .error) { data, _ in
                if let error = data.first as? Error {
                    print("Connection Error: \(error.localizedDescription)")
                } else if let errorString = data.first as? String {
                    // Sometimes the error might be a string describing the issue
                    print("Connection Error: \(errorString)")
                }
            }
        
        // Listener for successful connection
        socket?.on(clientEvent: .connect) { [weak self] _, _ in
            guard let self = self else { return }

            if !self.isConnectedPrinted {
                //print("Connection has been established")
                self.isConnectedPrinted = true // Set the flag to true after printing
            }
        }
        
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
