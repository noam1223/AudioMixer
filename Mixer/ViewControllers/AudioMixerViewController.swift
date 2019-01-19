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
import CoreLocation
import SVProgressHUD

class AudioMixerViewController: UIViewController, IQAudioCropperViewControllerDelegate, CLLocationManagerDelegate {
    
    
    let recordListPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("recording.plist")
    var recordPlist = [audioMixer]()
    var recordURL:URL!
    var firstMergeDetected = false
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadRecordsFromDatabase { (recordsList) in
            self.recordPlist = recordsList
        }
    }
    
    
    @IBAction func chooseRecord(_ sender: UIButton) {
        let popUpList = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpListRecords") as! ChooseRecordPopUpViewController
        self.addChildViewController(popUpList)
        popUpList.view.frame = self.view.frame
        self.view.addSubview(popUpList.view)
        popUpList.didMove(toParentViewController: self)
    }
    
    
    @IBAction func saveNewMix(_ sender: UIButton) {
        if firstMergeDetected{
            let newPath = recordURL.path
            userWantToSaveRecord(filePath: newPath)
        } else {
            displayAlert(title: "Warning", message: "No record detected")
        }
    }
    

    @IBAction func newMixTrapped(_ sender: UIButton) {
        if firstMergeDetected{
            try! FileManager.default.removeItem(at: recordURL)
            firstMergeDetected = false
            displayAlert(title: "Success", message: "New mix added")
        }
    }
    
    
    @IBAction func mergeTrapped(_ sender: UIButton) {
        if Shared.shared.companyName != nil{
            SVProgressHUD.show()
            let storageRef = Storage.storage().reference()
            let fileName = "/\(Shared.shared.companyName!).m4a"
            let fileUrl = getURLforMemo(fileName: fileName) as URL
            let recordRef = storageRef.child("upload").child(User.user.userName).child(fileName)
            let newAudioPath = getURLforMemo(fileName: "newAudio") as URL
            recordRef.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                SVProgressHUD.dismiss()
                if let error = error{
                    self.displayAlert(title: "Error", message: error.localizedDescription)
                } else {
                    if let data = data{
                        do{
                            try data.write(to: fileUrl)
                            self.mergeTwoRecords(fileFromStorage: fileUrl, newFile: newAudioPath)
                        } catch {
                            self.displayAlert(title: "Error", message: error.localizedDescription)
                        }
                    }
                }
            })
        } else {
            displayAlert(title: "Warning", message: "No record have been chosen")
        }
    }
    
    
    @IBAction func playNewMix(_ sender: UIButton) {
        if recordURL != nil{
            let croppNow = IQAudioCropperViewController(filePath: recordURL.path)
            croppNow.delegate = self
            croppNow.title = Shared.shared.companyName!
            croppNow.barStyle = UIBarStyle.default
            self.presentBlurredAudioCropperViewControllerAnimated(croppNow)
        } else {
            displayAlert(title: "Warning", message: "Not found new mix")
        }
    }
    
    
    @IBAction func backTrapped(_ sender: UIButton) {
        if firstMergeDetected{
            let alert = UIAlertController(title: "Are you sure?", message: "Notice: the file will be delete!", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                if FileManager.default.fileExists(atPath: self.recordURL.path){
                    try! FileManager.default.removeItem(at: self.recordURL)
                }
                self.dismiss(animated: true, completion: nil)
            })
            
            let action2 = UIAlertAction(title: "No", style: .destructive, handler: nil)
            alert.addAction(action1)
            alert.addAction(action2)
            present(alert, animated: true, completion: nil)
            
        } else {
            let newAudioPath = getURLforMemo(fileName: "newAudio") as URL
            if FileManager.default.fileExists(atPath: newAudioPath.path){
                try! FileManager.default.removeItem(at: newAudioPath)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func audioCropperController(_ controller: IQAudioCropperViewController, didFinishWithAudioAtPath filePath: String) {
        controller.dismiss(animated: true, completion: nil)
        userWantToSaveRecord(filePath: filePath)
    }
    
    
    func mergeTwoRecords(fileFromStorage:URL ,newFile:URL){
        let composition = AVMutableComposition()
        guard let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            else {
                return
        }
        compositionAudioTrack.append(url: newFile)
        compositionAudioTrack.append(url: fileFromStorage)
        if FileManager.default.fileExists(atPath: newFile.path){
            try! FileManager.default.removeItem(at: newFile)
        }
        if let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) {
            assetExport.outputFileType = AVFileType.m4a
            assetExport.outputURL = newFile
            assetExport.exportAsynchronously(completionHandler: {
                self.recordURL = newFile
                self.firstMergeDetected = true
                self.displayAlert(title: "Merge", message: "Merge has complete")
            })
        }
    }
    
    
    func userWantToSaveRecord(filePath:String) {
        var newTextField = UITextField()
        let longitud:CLLocationDegrees = (self.locationManager.location?.coordinate.longitude)!
        let latitude:CLLocationDegrees = (self.locationManager.location?.coordinate.latitude)!
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alertInit(alert: alert, title: "Save", message: "Would you like to save the record?")
        
        let action1 = UIAlertAction(title: "Yes", style: .default) { (action) in
            SVProgressHUD.show()
            self.getAddress(longitude: longitud, latitude: latitude) { (address) in
                self.recordPlist.append(audioMixer(name: newTextField.text!, address: address!))
                self.saveRecordsAtDatabase(recordsList: self.recordPlist)
                self.uploadSound(localFile: URL.init(fileURLWithPath: filePath)  ,name: newTextField.text!)
                self.locationManager.stopUpdatingLocation()
                SVProgressHUD.dismiss()
                self.displayAlert(title: "Saved", message: "record saved successfuly")
            }
        }
        let action2 = UIAlertAction(title: "No", style: .destructive, handler: nil)
        alert.addTextField { (alertTextField) in
            self.alerTextFieldInit(alertTextField: alertTextField)
            newTextField = alertTextField
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        SVProgressHUD.dismiss()
        present(alert, animated: true, completion: nil)
    }
}



extension AVMutableCompositionTrack {
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
