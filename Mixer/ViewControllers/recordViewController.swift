//
//  recordViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/3/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseStorage

class recordViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate{
    
    @IBAction func homePage(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadSound(localFile: URL) {
        let storageRef = Storage.storage().reference()
        let fileName = "/\(numberOfRecords).m4a"
        let imagesRef = storageRef.child("upload").child(fileName)
        
        let uploadTask = imagesRef.putFile(from: localFile, metadata: nil) { metadata, error in
            if let error = error {
                print(error)
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.size
                print("\(downloadURL)")
            }
        }
    }
    
    var saveRecordList:audioMixerArray!
    
    @IBOutlet weak var timeLabel: UILabel!
    var numberOfRecords:Int = 0
   
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    var soundTimer: CFTimeInterval = 0.0
    var updateTimer: CADisplayLink!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nc = NotificationCenter.default
        let session = AVAudioSession.sharedInstance()
        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int { numberOfRecords = number }

    }
    @IBAction func recordsList(_ sender: UIButton) {
        let listRecord = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "recordListViewController") as! recordsListViewController
        self.present(listRecord, animated: true, completion: nil)
    }
    
    @IBAction func startRecording(_ sender: UIButton) {
        if audioRecorder == nil{
            setupRecord()
            startUpdateLoop()
        }
    }
    
    func startUpdateLoop() {
        if updateTimer != nil {
            updateTimer.invalidate()
        }
        updateTimer = CADisplayLink(target: self, selector: #selector (updateLoop))
        updateTimer.preferredFramesPerSecond = 1
        updateTimer.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    @IBAction func saveRecord(_ sender: UIButton) {
        
    }
    
    @IBAction func stopRecord(_ sender: UIButton) {
        audioRecorder.stop()
        stopUpdateLoop()
        audioRecorder = nil
        UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
        uploadSound(localFile: getDirectory().appendingPathComponent("\(numberOfRecords).m4a"))
    }
}


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



