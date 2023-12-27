import SwiftUI
import AVFoundation
import SocketIO

public struct Movie: Codable {
    let title: String
    let overview: String
    let releaseDate: String
    let posterPath: String
    let trailer: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case overview
        case trailer
        case releaseDate = "release_date"
        case posterPath = "poster_path"
    }
}

struct ContentView: View {
    @State private var webSocketConnected = false
    @State private var showMovieDetails = false
    @State private var selectedMovie: Movie?
    @State private var showSampleMovie = false
    @State private var isRecording = false
    
    init() {
        WebSocketManager.shared.establishConnection()
        webSocketConnected = true
    }

    var body: some View {
        ZStack {
            if showSampleMovie {
                MovieDetailView(onBack: { showSampleMovie = false }, movie: sampleMovie())
            } else if showMovieDetails, let movie = selectedMovie {
                MovieDetailView(onBack: { showMovieDetails = false }, movie: movie)
            } else {
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
                    
                Button(action: { isRecording ? stopRecording() : startRecording() }) {
                    Image(systemName: isRecording ? "mic.slash.fill" : "mic.fill")
                        .font(.largeTitle)
                        .foregroundColor(isRecording ? .gray : .white)
                        .padding()
                        .background(isRecording ? Color.white.opacity(0.5) : Color.white.opacity(0.1))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }

                if isRecording {
                    Text("Recording in progress").font(.subheadline).foregroundColor(.red)
                }

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
    
    func startRecording() {
        isRecording = true
        AudioManager.shared.startRecording { result in
            if case .failure(let error) = result {
                print("Error starting recording: \(error)")
            }
        }
    }

    func stopRecording() {
        isRecording = false
        if let audioURL = AudioManager.shared.stopRecording() {
            WhisperManager.shared.transcribeAudio(fileURL: audioURL) { result in
                switch result {
                case .success(let transcription):
                    print("To Server: \(transcription)")
                    WebSocketManager.shared.sendMessage(message: transcription, to: "message")
                    getResponse()
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        } else {
            print("Recording file not found")
        }
    }


    func sampleMovie() -> Movie {
        Movie(title: "Sample Movie", overview: "This is a sample movie for preview purposes.", releaseDate: "2023-01-01", posterPath: "https://www.themoviedb.org/t/p/original/78lPtwv72eTNqFW9COBYI0dWDJa.jpg", trailer: "eOrNdBpGMv8")
    }
    
    private func getResponse() {
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
                                        self.selectedMovie = movie
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
