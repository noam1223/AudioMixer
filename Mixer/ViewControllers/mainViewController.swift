//
//  ViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/2/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import IQAudioRecorderController
import CoreLocation


class mainViewController: UIViewController, IQAudioRecorderViewControllerDelegate, CLLocationManagerDelegate {
    
    let recordListPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("recording.plist")
    var recordPlist = [audioMixer]()
    let locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            print("longitud:\(location.coordinate.longitude), latitued\(location.coordinate.latitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
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

    
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        print("finished")
        controller.delegate = nil
        controller.dismiss(animated: true, completion: nil)
        userWantToSaveRecord(filePath: filePath)
    }
    
    
    @IBAction func logOutTrapped(_ sender: UIButton) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func listRecord(_ sender: UIButton) {
        let listRecord = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordsTableViewController") as! RecordsTableViewController
        self.present(listRecord, animated: true, completion: nil)
    }
    
    @IBAction func startRecordViewController(_ sender: UIButton) {
        var recordNow = IQAudioRecorderViewController()
        recordNow.delegate = self
        recordNow.title = "Recorder"
        recordNow.maximumRecordDuration = 10
        recordNow.allowCropping = true
        recordNow.barStyle = UIBarStyle.default
        //recordNow.normalTintColor = UIColor(ciColor: .magenta)
        
        self.presentBlurredAudioRecorderViewControllerAnimated(recordNow)
    }
    
    @IBAction func startMix(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordPlist = loadRecords()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        
    }
}


