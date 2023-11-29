import Speech

class SpeechRecognizerManager: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer()
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    let silenceThreshold: Float = -70 // dB, adjust based on testing
    private var silenceTimer: Timer?
    private var isSilenceDetected = false
    
    @Published var transcribedText: String = ""
    @Published var isRecording: Bool = false
    
    func startRecording() {
        if isRecording {
            stopRecording()
            return
        }
        
        isRecording = true
        print("Currently Recording")
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in
            if let result = result {
                let transcribedText = result.bestTranscription.formattedString
                print(transcribedText) // Print the transcribed text in real-time
            }

            if error != nil {
                self?.stopRecording()
            }
        })

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        // Configure the audio session
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            recognitionRequest.append(buffer)
            self.analyzeBuffer(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        print("Stopped Recording")
    }
    
    
    func analyzeBuffer(_ buffer: AVAudioPCMBuffer) {
            let avgPower = calculateAveragePower(from: buffer)
            //print(avgPower)

            if avgPower < silenceThreshold {
                if !isSilenceDetected {
                    startSilenceTimer()
                    isSilenceDetected = true
                    print("Silence has been detected")
                }
            } else {
                print("Silence is now false")
                isSilenceDetected = false
                silenceTimer?.invalidate()
            }
        }

    private func startSilenceTimer() {
        DispatchQueue.main.async {
            self.silenceTimer?.invalidate()  // Invalidate any existing timer
            self.silenceTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
                print("WORK")
                self?.handlePauseDetected()
            }
        }
    }

        private func handlePauseDetected() {
            print("Pause detected")
            // Handle the detected pause, e.g., stop recording or process the current recording
        }
    
    private func calculateAveragePower(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0.0 }

        let channelDataValue = channelData.pointee
        let frames = Int(buffer.frameLength)
        let channelDataValues = (0..<frames).map { channelDataValue[$0] }

        let rms = sqrt(channelDataValues.map { $0 * $0 }.reduce(0, +) / Float(frames))

        // Convert to decibels
        let avgPower = 20 * log10(rms)
        return avgPower
    }
}

