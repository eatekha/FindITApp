//
//  AudioManager.swift
//  FindIT
//
//  Created by Eseosa on 2023-12-25.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var audioRecorder: AVAudioRecorder?

    private init() {}  // Private initializer to ensure singleton pattern

    func startRecording(completion: @escaping (Result<Void, Error>) -> Void) {
        let audioSession = AVAudioSession.sharedInstance()
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()

            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetoothA2DP, .allowBluetooth, .defaultToSpeaker])
            completion(.success(()))
        } catch {
            completion(.failure(error))
            
        }
    }

    func stopRecording() -> URL? {
        audioRecorder?.stop()
        return getDocumentsDirectory().appendingPathComponent("recording.m4a")
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

