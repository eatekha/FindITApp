//
//  ContentView.swift
//  FindIT
//
//  Created by Eseosa on 2023-11-29.
//

import SwiftUI
import AVFoundation
import Speech


struct ContentView: View {
    @StateObject private var speechRecognizerManager = SpeechRecognizerManager()

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
            }
        }
    }
}

// Preview provider for ContentView

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
