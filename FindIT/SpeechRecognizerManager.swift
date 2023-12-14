import Speech

class SpeechRecognizerManager: ObservableObject {
    // Speech recognizer for converting speech to text.
    private let speechRecognizer = SFSpeechRecognizer()
    
    // Audio engine for managing and processing audio.
    private var audioEngine = AVAudioEngine()
    
    // Request for speech recognition.
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    // Task for managing the speech recognition process.
    private var recognitionTask: SFSpeechRecognitionTask?

    //Managing the Recording of Audio
    private var audioRecorder: AVAudioRecorder?
    
    //Managing the Playing of Audio
    private var audioPlayer: AVAudioPlayer?

    
    // Threshold for detecting silence in decibels.
    let silenceThreshold: Float = -45 // Adjust based on testing
    
    // Timer for detecting a duration of silence.
    private var silenceTimer: Timer?
    
    // Flag to indicate if silence is detected.
    private var isSilenceDetected = false
    
    // Published properties to observe changes in the UI.
    @Published var transcribedText: String = ""
    private var temp: String = ""

    @Published var isRecording: Bool = false
    
    // Starts the recording and speech recognition process.
    func startRecording() {
        // If already recording, stop and return.
        if isRecording {
            stopRecording()
            return
        }
        resetSilenceTimer()
        
        // Set recording flag to true and prepare for a new recognition request.
        isRecording = true
        print("Currently Recording")
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        // Create a recognition task with a result handler.
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in
            // Update the transcribed text as speech is recognized.
            if let result = result {
                let transcribedText = result.bestTranscription.formattedString
                    
                self?.temp = transcribedText
                print(transcribedText) // Print the transcribed text in real-time
                
                self?.resetSilenceTimer()
            }

            // Stop recording on error.
            if error != nil {
                self?.stopRecording()
            }
        })

        // Setup the audio input node and configure the audio session.
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        // Configure the audio session for recording.
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetoothA2DP, .allowBluetooth])
            // Successfully set the audio session category
        } catch {
            // Handle the error here
            print("An error occurred setting the audio session category: \(error)")
        }
        
        do {
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("An error occurred activating the audio session: \(error)")
            // Handle the error, e.g., by stopping the recording or notifying the user
        }

        // Install an audio tap to capture the microphone input.
        let hwSampleRate = AVAudioSession.sharedInstance().sampleRate
        let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: hwSampleRate, channels: 1)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            recognitionRequest.append(buffer)
        }
        
        // Prepare and start the audio engine.
        audioEngine.prepare()
        try? audioEngine.start()
    }

    // Stops the recording and cleans up.
    func stopRecording() {
        // Stop the audio engine and invalidate the recognition request and task.
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        silenceTimer?.invalidate()
        silenceTimer = nil
        cancelSilenceTimer()
        print("Stopped Recording")
    }
    

    // Handles the detected pause in speech.
    private func handlePauseDetected() {
        print("Pause detected")
        // Implement actions to handle the detected pause.
        if (temp != "") {
            WebSocketManager.shared.sendMessage(message: temp, to: "message")
            stopRecording()
        }
    }
    
    // Reset and start the silence detection timer
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.isSilenceDetected = true
            self?.handlePauseDetected()
        }
    }

    // Call this function when you stop recording or when you detect speech
    private func cancelSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = nil
    }
}
