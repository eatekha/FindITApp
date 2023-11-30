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
    let silenceThreshold: Float = -60 // Adjust based on testing
    
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
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Install an audio tap to capture the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            recognitionRequest.append(buffer)
            self.analyzeBuffer(buffer) // Analyze buffer for silence detection.
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
        print("Stopped Recording")
    }
    
    // Analyzes the audio buffer to detect silence.
    func analyzeBuffer(_ buffer: AVAudioPCMBuffer) {
        let avgPower = calculateAveragePower(from: buffer)
        //print(avgPower)

        // Check if the average power is below the silence threshold.
        if avgPower < silenceThreshold {
            // If silence is not already detected, start the silence timer.
            if !isSilenceDetected {
                startSilenceTimer()
                isSilenceDetected = true
                // print("Silence has been detected")
            }
        } else {
            // If not silent, invalidate the timer and reset the flag.
            isSilenceDetected = false
            silenceTimer?.invalidate()
        }
    }

    // Starts a timer that triggers after a certain duration of silence.
    private func startSilenceTimer() {
        DispatchQueue.main.async {
            self.silenceTimer?.invalidate()  // Invalidate any existing timer
            self.silenceTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
                self?.handlePauseDetected() // Handle pause detection.
            }
        }
    }

    // Handles the detected pause in speech.
    private func handlePauseDetected() {
        print("Pause detected")
        // Implement actions to handle the detected pause.
        
        if (temp != "") {
            print("THIS IS THE TRANSCRIBED TEXT: " + temp)
            //1. Save Current Recording to a playable file
            WebSocketManager.shared.sendMessage(message: temp, to: "message")
            print("Sent " + temp +  " to message on WebSocket")
            //2. Take Care of Sending File To Backend
            stopRecording()
        }
    }
    
    private func sendFile(){
        print("File Sent")
    }
    
    // Calculates the average power of the audio buffer in decibels.
    private func calculateAveragePower(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0.0 }

        // Extract the frame values and calculate the RMS.
        let channelDataValue = channelData.pointee
        let frames = Int(buffer.frameLength)
        let channelDataValues = (0..<frames).map { channelDataValue[$0] }

        let rms = sqrt(channelDataValues.map { $0 * $0 }.reduce(0, +) / Float(frames))

        // Convert RMS to decibels.
        let avgPower = 20 * log10(rms)
        return avgPower
    }


}

