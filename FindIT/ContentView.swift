import SwiftUI
import AVFoundation
import Speech
import SocketIO  // Make sure this is correctly imported

struct ContentView: View {
    @StateObject private var speechRecognizerManager = SpeechRecognizerManager()
    // Add a state to manage the WebSocket connection status
    @State private var webSocketConnected = false

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Hello, Eseosa on iPad")
                    .font(.title)
                    .foregroundColor(.black)
                
                Text(speechRecognizerManager.transcribedText)
                    .font(.subheadline)
                    .foregroundColor(.black)

                // Mic button
                Button(action: {
                    speechRecognizerManager.startRecording()
                }) {
                    Image(systemName: speechRecognizerManager.isRecording ? "mic.slash.fill" : "mic.fill")
                        .font(.largeTitle)
                        .foregroundColor(speechRecognizerManager.isRecording ? .gray : .black)
                        .padding()
                        .background(speechRecognizerManager.isRecording ? Color.black.opacity(0.5) : Color.black.opacity(0.1))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                }
                
                if speechRecognizerManager.isRecording {
                    Text("Recording in progress")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }

                // WebSocket setup button
               /* / Button(action: {
                    sendMessageThroughWebSocket()
                }) {
                    Text("Send WebSocket Mesage")
                        .font(.headline)
                        .foregroundColor(webSocketConnected ? .black : .blue)
                        .padding()
                        .background(webSocketConnected ? Color.gray.opacity(0.5) : Color.blue.opacity(0.5))
                        .cornerRadius(10)
                }
                */
            }
        }
        
        .onAppear {
            setupWebSocketConnection()
        }
         

    }
    
    
    private func setupWebSocketConnection() {
            if !webSocketConnected {
                WebSocketManager.shared.establishConnection()
                webSocketConnected = true
                
                // Set up listener here if it's general and not specific to an event
                WebSocketManager.shared.listenToEvent(event: "message") { data in
                    print("Received response from message: \(data)")
                }
            }
        }

        private func sendMessageThroughWebSocket() {
            // Send message
            WebSocketManager.shared.sendMessage(message: "HI", to: "message")
            print("Sent 'this' to message on WebSocket")
        }
    
    private func closeConnection(){
        WebSocketManager.shared.closeConnection()
    }
    
}

// Preview provider for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
