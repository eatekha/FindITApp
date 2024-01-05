import SwiftUI
import AVFoundation
import SocketIO

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
                let viewModel = MovieViewModel(movie: MovieViewModel.sampleMovie()) // Create ViewModel for sample movie
                MovieView(viewModel: viewModel, onBack: { showSampleMovie = false })
            } else if showMovieDetails, let movie = selectedMovie {
                let viewModel = MovieViewModel(movie: movie) // Create ViewModel for the selected movie
                MovieView(viewModel: viewModel, onBack: { showMovieDetails = false })
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
