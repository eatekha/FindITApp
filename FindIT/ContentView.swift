import SwiftUI
import AVFoundation

struct ContentView: View {
    // State variable to track if the microphone is active
    @State private var isMicrophoneActive = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var hasRecording = false // Tracks if a recording has been made


    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Hello, Eseosa")
                    .font(.title)
                    .foregroundColor(.black)
                
                Text("Record Snippet Bellow")
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                //Microphone Button
                Button(action: {
                    self.isMicrophoneActive.toggle()
                    if self.isMicrophoneActive {
                        self.startRecording()
                    }
                     
                    else {
                       self.stopRecording()
                        self.hasRecording = true // Set hasRecording to true after stopping the recording
                        print("Currently Recording")
                    }
                     
                }) {
                    Image(systemName: "mic.fill")
                        .font(.largeTitle)
                        .foregroundColor(isMicrophoneActive ? .gray : .black) // Change color based on state
                        .padding()
                        .background(isMicrophoneActive ? Color.black.opacity(0.5) : Color.black.opacity(0.1))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                }
                //For Debugging
                if isMicrophoneActive {
                        Text("Recording in progress")
                            .font(.subheadline)
                            .foregroundColor(.red)
                }
                //For Getting Recording after
                if hasRecording {
                    Button("Play Recording", action: playRecording)
                }
            }
        }
    }
    func startRecording() {
            // Check for microphone permission
        AVAudioApplication.requestRecordPermission { granted in
                if granted {
                    // Set up and start the recorder
                    DispatchQueue.main.async {
                        self.setupRecorder()
                        self.audioRecorder?.record()
                    }
                } else {
                    // Handle permission denied
                    print("Microphone permission denied")
                }
            }
        }

        func stopRecording() {
            // Stop the recorder
            audioRecorder?.stop()
        }

        func setupRecorder() {
            let recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)

                let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let audioFilename = documentPath.appendingPathComponent("recording.m4a")

                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]

                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            } catch {
                // Handle errors
                print("Failed to set up recorder: \(error)")
            }
        }
    func playRecording() {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("recording.m4a")

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer?.play()
        } catch {
            print("Could not load file: \(error)")
        }
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
