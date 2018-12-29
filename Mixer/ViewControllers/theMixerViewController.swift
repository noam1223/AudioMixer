//
//  theMixerViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/8/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import AVKit
import Foundation
import FirebaseStorage

class theMixerViewController: UIViewController,AVAudioPlayerDelegate {
    
    let recordListPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("recording.plist")
    var recordPlist = [audioMixer]()
    
    func loadRecords(){
        if let data = try? Data(contentsOf: recordListPath!){
            let decoder = PropertyListDecoder()
            do{
                recordPlist = try decoder.decode([audioMixer].self, from: data)
            } catch {
                print("ERROR TO LOAD RECORDS: \(error)")
            }
        }
    }
    
    func saveRecords(){
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(recordPlist)
            try data.write(to: recordListPath!)
        } catch {
            print("ERROR SAVING RECORD: \(error)")
        }
    }
    
    func uploadSound(localFile: URL, name:String) {
        let storageRef = Storage.storage().reference()
        let fileName = "/\(name).m4a"
        let imagesRef = storageRef.child("upload").child(fileName)
        let uploadTask = imagesRef.putFile(from: localFile, metadata: nil) { metadata, error in
            if let error = error {
                print("ERROE TO UPLOAD: \(error)")
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.size
                print("\(downloadURL)")
            }
        }
    }
    
    func downLoadSound(name:String) -> URL {
        let storageRef = Storage.storage().reference()
        let fileName = "/\(name).m4a"
        let imagesRef = storageRef.child("upload").child(fileName)
        let newfile = getURLforMemo(fileName: name)
        let uploadTask = imagesRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error) } else {
                if let d = data {
                    do {
                        try d.write(to: newfile as URL)
                        
                    } catch {
                        print(error)
                        
                    }
                }
            }
        }
        return newfile as URL
    }
    
    func getURLforMemo(fileName: String) -> NSURL {
        let tempDir = NSTemporaryDirectory()
        let filePath = tempDir + fileName
        
        return NSURL.fileURL(withPath: filePath) as NSURL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecords()
    }
    
    
    @IBAction func restartTrapped(_ sender: UIButton) {
        
    }
    
    
    @IBAction func backHome(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var ChosenRecordLabel: UILabel!
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var audioPlayer2:AVAudioPlayer!
    var numberOfRecords:Int!
    var soundTimer: CFTimeInterval = 0.0
    var updateTimer: CADisplayLink!
    
    @IBOutlet weak var topSlider: UISlider!
    @IBOutlet weak var countingTimeRecordChoosen: UILabel!
    @IBOutlet weak var maximumTimeRecordChoosen: UILabel!
    @IBAction func sliderHasMoved(_ sender: UISlider) {
    }
    @IBAction func chooseRecord(_ sender: UIButton) {
        let popUpList = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpListRecords") as! ChooseRecordPopUpViewController
        self.present(popUpList, animated: true, completion: nil)
    }
    
    @IBAction func pausePlayer(_ sender: UIButton) {
        audioPlayer.pause()
        stopUpdateLoop()
    }
    
    @IBAction func cutRecord(_ sender: UIButton) {
        if audioPlayer == nil{
            return
       }
        
        let audioCut = getDirectory().appendingPathComponent(Shared.shared.companyName! + ".m4a")
        let newAudioPath = getDirectory().appendingPathComponent("example.m4a")
        let composition = AVMutableComposition()
        guard let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
           else{return}
        
        let duration = CMTimeMakeWithSeconds(Float64(audioPlayer.currentTime), Int32(1))
        compositionAudioTrack.append(url: audioCut, duration: duration)
        
        if let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) {
            assetExport.outputFileType = AVFileType.m4a
            assetExport.outputURL = newAudioPath
            assetExport.exportAsynchronously(completionHandler: {
                print("Done")
            })
        }
    }
    
    
    @IBAction func mergeRecord(_ sender: UIButton) {
        
        let newAudioPath = getDirectory().appendingPathComponent("newAudio.m4a")
        let audioCut = getDirectory().appendingPathComponent("example.m4a")
        
        let composition = AVMutableComposition()
        
        guard let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            else{return}
        
        compositionAudioTrack.append(url: newAudioPath)
        compositionAudioTrack.append(url: audioCut)
        
        if FileManager.default.fileExists(atPath: newAudioPath.path){
            try! FileManager.default.removeItem(at: newAudioPath)
        }
        
            if let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) {
                assetExport.outputFileType = AVFileType.m4a
                assetExport.outputURL = newAudioPath
                assetExport.exportAsynchronously(completionHandler: {
                    print("Done")
                    if FileManager.default.fileExists(atPath: audioCut.path){
                        try! FileManager.default.removeItem(at: audioCut)
                    }
                })
        }
        
    }

    
    @IBAction func playRecord(_ sender: UIButton) {
        let path = getDirectory().appendingPathComponent(Shared.shared.companyName + ".m4a")
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            topSlider.maximumValue = Float(audioPlayer.duration)
            formattedCurrentTime(time: UInt(audioPlayer.duration), label: maximumTimeLabel)
            audioPlayer.play()
            startUpdateLoop(audioPlayerCurrent: audioPlayer)
        } catch {
            displayAlert(title: "Ops!", message: "the play goes wrong")
        }
    }
    
    
    @IBOutlet weak var countingTimeLabel: UILabel!
    @IBOutlet weak var maximumTimeLabel: UILabel!
    @IBOutlet weak var sliderNewRecord: UISlider!
    @IBAction func sliderNewRecordHasMoved(_ sender: UISlider) {
    }
    
    @IBAction func playNewRecord(_ sender: UIButton) {
        let path = getDirectory().appendingPathComponent("newAudio.m4a")
        do{
            audioPlayer2 = try AVAudioPlayer(contentsOf: path)
            sliderNewRecord.maximumValue = Float(audioPlayer2.duration)
            formattedCurrentTime(time: UInt(audioPlayer.duration), label: maximumTimeLabel)
            audioPlayer2.play()
            startUpdateLoop(audioPlayerCurrent: audioPlayer2)
        } catch {
            displayAlert(title: "Ops!", message: "the play goes wrong")
        }
    }
    
    @IBAction func pauseNewRecord(_ sender: UIButton) {
    }
    
    @IBAction func restartNewRecord(_ sender: UIButton) {
    }
    
    func startUpdateLoop(audioPlayerCurrent:AVAudioPlayer) {
        if updateTimer != nil {
            updateTimer.invalidate()
        }
        if audioPlayerCurrent == audioPlayer{
        updateTimer = CADisplayLink(target: self, selector: #selector (updateLoop))
        } else{
            updateTimer = CADisplayLink(target: self, selector: #selector (updateLoop2))
        }
        updateTimer.preferredFramesPerSecond = 1
        updateTimer.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    func stopUpdateLoop() {
        updateTimer.invalidate()
        updateTimer = nil
        // Update UI
        formattedCurrentTime(time: 0, label: countingTimeLabel)
    }
    
    @objc func updateLoop2() {
        if CFAbsoluteTimeGetCurrent() - soundTimer > 0.5 {
            formattedCurrentTime(time: UInt(audioPlayer2.currentTime), label: countingTimeRecordChoosen)
            soundTimer = CFAbsoluteTimeGetCurrent()
            moveSlider(slider: sliderNewRecord, audioPlayer: audioPlayer2)
        }
    }
    
    @objc func updateLoop() {
        if CFAbsoluteTimeGetCurrent() - soundTimer > 0.5 {
            formattedCurrentTime(time: UInt(audioPlayer.currentTime), label: countingTimeRecordChoosen)
            soundTimer = CFAbsoluteTimeGetCurrent()
            moveSlider(slider: topSlider, audioPlayer: audioPlayer)
        }
    }
    
}

extension AVMutableCompositionTrack {
    func append(url: URL, duration:CMTime) {
        let newAsset = AVURLAsset(url: url)
        let range = CMTimeRangeMake(kCMTimeZero, duration)
        let end = timeRange.end
        print(end)
        if let track = newAsset.tracks(withMediaType: AVMediaType.audio).first {
            try! insertTimeRange(range, of: track, at: end)
        }
        
    }
    
    func append(url: URL) {
        let newAsset = AVURLAsset(url: url)
        let range = CMTimeRangeMake(kCMTimeZero, newAsset.duration)
        let end = timeRange.end
        print(end)
        if let track = newAsset.tracks(withMediaType: AVMediaType.audio).first {
            try! insertTimeRange(range, of: track, at: end)
        }
        
    }
}
