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
import FirebaseDatabase
import IQAudioRecorderController
import CoreLocation
import SVProgressHUD


class mainViewController: UIViewController, IQAudioRecorderViewControllerDelegate, CLLocationManagerDelegate {
    
    let recordListPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("recording.plist")
    var recordPlist = [audioMixer]()
    let locationManager = CLLocationManager()

    func loadRecordsFromDatabase(complition:@escaping (_ recordList:[audioMixer])->Void){
        var recordList = [audioMixer]()
        let recordDB = Database.database().reference().child("myRecords").child(User.user.userName)
        recordDB.observe(DataEventType.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
                let recordName = snapshotValue["recordName"] as! String
                let address = snapshotValue["Address"] as! String
                recordList.append(audioMixer(name: recordName, address: address))
            complition(recordList)
        }
    }
    
    func loadUserInfo(complition:@escaping (_ finished:Bool)->Void){
        let uid = Auth.auth().currentUser?.uid
        let databaseRef = Database.database().reference().child("Users").child(uid!)
        databaseRef.observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            User.user.userName = snapshotValue["userName"]! as String
            User.user.email = snapshotValue["Email"]! as String
            User.user.password = snapshotValue["Password"]! as String
            complition(true)
        }
    }
    
    @IBAction func socialMedia(_ sender: UIButton) {
    }
    
    func userWantToSaveRecord(filePath:String) {
        var newTextField = UITextField()
        let longitud:CLLocationDegrees = (self.locationManager.location?.coordinate.longitude)!
        let latitude:CLLocationDegrees = (self.locationManager.location?.coordinate.latitude)!
        
        let alert = UIAlertController(title: "Save", message: "Would you like to save the record?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .default) { (action) in
            SVProgressHUD.show()
            self.getAddress(longitude: longitud, latitude: latitude) { (address) in
                self.recordPlist.append(audioMixer(name: newTextField.text!, address: address!))
                self.saveRecordsAtDatabase(recordsList: self.recordPlist)
                self.saveRecords(recordList: self.recordPlist)
                self.uploadSound(localFile: URL.init(fileURLWithPath: filePath)  ,name: newTextField.text!)
                self.locationManager.stopUpdatingLocation()
                SVProgressHUD.dismiss()
                self.displayAlert(title: "Saved", message: "record saved successfuly")
                
        }
    }
        let action2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Name it!"
            newTextField = alertTextField
        }

        alert.addAction(action1)
        alert.addAction(action2)
        SVProgressHUD.dismiss()
        present(alert, animated: true, completion: nil)
    }


    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
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
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            var recordNow = IQAudioRecorderViewController()
            recordNow.delegate = self
            recordNow.title = "Recorder"
            recordNow.maximumRecordDuration = 10
            recordNow.allowCropping = true
            recordNow.barStyle = UIBarStyle.default
            self.presentBlurredAudioRecorderViewControllerAnimated(recordNow)
        }
    }
    
    @IBAction func startMix(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo { (finished) in
            self.loadRecordsFromDatabase { (records) in
                self.recordPlist = records
                self.saveRecords(recordList: self.recordPlist)
            }
        }
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if (status == CLAuthorizationStatus.denied){
//            let alert = UIAlertController(title: "Background Location Access Disabled",
//                                          message: "In order to save record with your location we need your permission",
//                                          preferredStyle: .alert)
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
//                if let url = URL(string: UIApplicationOpenSettingsURLString){
//                    UIApplication.shared.open(url, options: [:], completionHandler: { (action) in
//                        UIApplication.shared.
//                    })
//                }
//            })
//            alert.addAction(cancelAction)
//            alert.addAction(openSettingsAction)
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
    
}


