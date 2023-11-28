//
//  ViewController.swift
//  FindIT
//
//  Created by Eseosa on 2023-11-17.
//

import Foundation
import UIKit

@IBAction func recordButtonTapped(_ sender: UIButton) {
    if audioManager.isRecording {
        audioManager.stopRecording()
        sender.setTitle("Start Recording", for: .normal)
        // Optionally, trigger file upload here or in the `AudioManager` recording completion handler
    } else {
        audioManager.startRecording()
        sender.setTitle("Stop Recording", for: .normal)
    }
}
