import SwiftUI
import AVFoundation
import Speech
import SocketIO

public struct Movie: Codable {
    let title: String
    let overview: String
    let releaseDate: String
    let voteAverage: Double
    let posterPath: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case overview
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
    }
}

struct ContentView: View {
    @StateObject private var speechRecognizerManager = SpeechRecognizerManager()
    @State private var webSocketConnected = false
    @State private var showMovieDetails = false
    @State private var selectedMovie: Movie?
    @State private var showSampleMovie = false


    var body: some View {
        ZStack {
            if showSampleMovie {
                MovieDetailView(onBack: {
                    showSampleMovie = false
                }, movie: sampleMovie())
            } else if showMovieDetails, let movie = selectedMovie {
                MovieDetailView(onBack: {
                    showMovieDetails = false
                }, movie: movie)
            } else {
                // Original ContentView
                originalContentView
            }

        }
    }

    var originalContentView: some View {
        
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Hello, Eseosa on iPad")
                    .font(.title)
                    .foregroundColor(.white)
                    
                
                Text(speechRecognizerManager.transcribedText)
                    .font(.subheadline)
                    .foregroundColor(.white)

                // Mic button
                Button(action: {
                    speechRecognizerManager.startRecording()
                    setupWebSocketConnection()
                }) {
                    Image(systemName: speechRecognizerManager.isRecording ? "mic.slash.fill" : "mic.fill")
                        .font(.largeTitle)
                        .foregroundColor(speechRecognizerManager.isRecording ? .gray : .white)
                        .padding()
                        .background(speechRecognizerManager.isRecording ? Color.white.opacity(0.5) : Color.white.opacity(0.1))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
                
                if speechRecognizerManager.isRecording {
                    Text("Recording in progress")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                HStack {
                    Button("Movie View") {
                        showSampleMovie = true
                        
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    }
            }
        }
    }



    private func setupWebSocketConnection() {
        if !webSocketConnected {
            WebSocketManager.shared.establishConnection()
            webSocketConnected = true
            
            // Set up listener here if it's general and not specific to an event
            WebSocketManager.shared.listenToEvent(event: "message") { data in
                print("Received response from message: \(data)")
                
                if let array = data as? [Any] {
                    for element in array{
                        if let stringValue = element as? String {
                            if (stringValue != "Keep Listening....."){
                                let jsonData = Data(stringValue.utf8)
                                
                                do {
                                    showMovieDetails = true
                                    let movie = try JSONDecoder().decode(Movie.self, from: jsonData)
                                    self.selectedMovie = movie // Update the selected movie

                                    print("Title: \(movie.title)")
                                    print("Overview: \(movie.overview)")
                                    // Access other fields as needed
                                } catch {
                                    print("Error parsing JSON: \(error)")
                                }
                            }
                            
                        }
                    }
                }
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
    
    func sampleMovie() -> Movie {
        return Movie(
            title: "Sample Movie",
            overview: "This is a sample movie for preview purposes.",
            releaseDate: "2023-01-01",
            voteAverage: 8.5,
            posterPath: "https://www.themoviedb.org/t/p/w300_and_h450_bestv2/RYMX2wcKCBAr24UyPD7xwmjaTn.jpg"
        )
    }
    

    
}

// Preview provider for ContentView
struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
