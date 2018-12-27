//
//  mixerHelper.swift
//  Mixer
//
//  Created by NoamSasunker on 12/8/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import AVFoundation

extension recordViewController{
    
    func formattedCurrentTime1(time: UInt) -> String {
        let hours = time / 3600
        let minutes = (time / 60) % 60
        let seconds = time % 60
        
        return String(format: "%02i:%02i:%02i", arguments: [hours, minutes, seconds])
    }
    
    func setupRecord() {
        numberOfRecords += 1
        let fileName = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
        let recordSettings = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC), AVSampleRateKey : 44100, AVNumberOfChannelsKey : 1, AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
            ] as [String : Any]
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: recordSettings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            displayAlert(title: "Record didn't start", message: "please try again")
        }
    }
    
    
    @objc func updateLoop() {
        if CFAbsoluteTimeGetCurrent() - soundTimer > 0.5 {
            timeLabel.text = formattedCurrentTime1(time: UInt(audioRecorder.currentTime))
            soundTimer = CFAbsoluteTimeGetCurrent()
        }
    }
    
    func stopUpdateLoop() {
        updateTimer.invalidate()
        updateTimer = nil
        // Update UI
        timeLabel.text = formattedCurrentTime1(time: UInt(0))
    }
}



