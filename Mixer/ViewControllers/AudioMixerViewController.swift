//
//  AudioMixerViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/30/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import AVKit
import FirebaseStorage
import IQAudioRecorderController

class AudioMixerViewController: UIViewController, IQAudioCropperViewControllerDelegate {
    
    let recordListPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("recording.plist")
    var recordPlist = [audioMixer]()
    var recordURL:URL!
    var firstMergeDetected = false

    
    func audioCropperController(_ controller: IQAudioCropperViewController, didFinishWithAudioAtPath filePath: String) {
        print("finished")
        controller.dismiss(animated: true, completion: nil)
        userWantToSaveRecord(filePath: filePath)
    }

    @IBAction func backTrapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playNewMix(_ sender: UIButton) {
        if recordURL != nil{
        let croppNow = IQAudioCropperViewController(filePath: recordURL.path)
        croppNow.delegate = self
        croppNow.title = Shared.shared.companyName!
        croppNow.barStyle = UIBarStyle.default
        self.presentBlurredAudioCropperViewControllerAnimated(croppNow)
        }
    }
    
    @IBAction func mergeTrapped(_ sender: UIButton) {
        if Shared.shared.companyName != nil{
            firstMergeDetected = true
            let audioCut = downLoadSound(name: Shared.shared.companyName!)
            let newAudioPath = getURLforMemo(fileName: "newAudio")
            let composition = AVMutableComposition()
            guard let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                else{return}
        
            compositionAudioTrack.append(url: newAudioPath as URL)
            compositionAudioTrack.append(url: audioCut)
        
        
            if FileManager.default.fileExists(atPath: newAudioPath.path!){
                try! FileManager.default.removeItem(at: newAudioPath as URL)
                print("deleted")
            }
        
            if let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) {
                assetExport.outputFileType = AVFileType.m4a
                assetExport.outputURL = newAudioPath as URL
                assetExport.exportAsynchronously(completionHandler: {
                    print("Done")
                    self.recordURL = newAudioPath as URL
                if FileManager.default.fileExists(atPath: audioCut.path){
                    try! FileManager.default.removeItem(at: audioCut)
                    print("AUDIOCUT REMOVED")
                }
            })
        }
    }
}
    
    @IBAction func chooseRecord(_ sender: UIButton) {
        let popUpList = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpListRecords") as! ChooseRecordPopUpViewController
        self.present(popUpList, animated: true, completion: nil)
    }
    
    
    @IBAction func saveNewMix(_ sender: UIButton) {
        if firstMergeDetected{
            let newPath = recordURL.path
            userWantToSaveRecord(filePath: newPath)
        }
    }
    
    @IBAction func newMixTrapped(_ sender: UIButton) {
        if firstMergeDetected{
            try! FileManager.default.removeItem(at: recordURL)
            firstMergeDetected = false
            print("deleted")
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(Shared.shared.companyName)
        recordPlist = loadRecords()
    }

    func userWantToSaveRecord(filePath:String) {
        var newTextField = UITextField()
        
        let alert = UIAlertController(title: "Save", message: "Do you want to save the record?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .default) { (yesAction) in
            self.recordPlist.append(audioMixer(name: newTextField.text!))
            self.saveRecords(recordList: self.recordPlist)
            self.uploadSound(localFile: URL.init(fileURLWithPath: filePath)  ,name: newTextField.text!)
        }
        
        let action2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Name it!"
            newTextField = alertTextField
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
}

extension AVMutableCompositionTrack {
//    func append(url: URL, duration:CMTime) {
//        let newAsset = AVURLAsset(url: url)
//        let range = CMTimeRangeMake(kCMTimeZero, duration)
//        let end = timeRange.end
//        print(end)
//        if let track = newAsset.tracks(withMediaType: AVMediaType.audio).first {
//            try! insertTimeRange(range, of: track, at: end)
//        }
//    }
    
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
