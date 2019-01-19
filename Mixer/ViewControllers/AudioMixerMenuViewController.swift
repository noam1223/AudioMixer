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


class AudioMixerMenuViewController: UIViewController, IQAudioRecorderViewControllerDelegate, CLLocationManagerDelegate {
    
    var recordPlist = [audioMixer]()
    let locationManager = CLLocationManager()

    //Loading the information of the user and download the list of the current user records list
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo { (_) in
            self.loadRecordsFromDatabase { (records) in
                self.recordPlist = records
                SVProgressHUD.dismiss()
            }
        }
        locationManager.requestWhenInUseAuthorization()
        
    }

    
    @IBAction func logOutTrapped(_ sender: UIButton) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func startRecordViewController(_ sender: UIButton) {
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            let recordNow = IQAudioRecorderViewController()
            recordNow.delegate = self
            recordNow.title = "Recorder"
            recordNow.maximumRecordDuration = 10
            recordNow.allowCropping = true
            recordNow.barStyle = UIBarStyle.default
            self.presentBlurredAudioRecorderViewControllerAnimated(recordNow)
        }
    }
    
    
    //Moving to the records list of the current user
    @IBAction func listRecord(_ sender: UIButton) {
        let listRecord = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordsTableViewController")
            as! RecordsTableViewController
        self.present(listRecord, animated: true, completion: nil)
    }
    
    
    @IBAction func socialMedia(_ sender: UIButton) {
        let sharedRecords = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sharedRecordsViewController")
            as! SharedRecordsTableViewController
        self.present(sharedRecords, animated: true, completion: nil)
    }
    
    
    @IBAction func startMix(_ sender: UIButton) {
        let audioMixer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "audioMixerViewController")
            as! AudioMixerViewController
        self.present(audioMixer, animated: true, completion: nil)
    }
    
    
    //Loading the user information from the database
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
    
    
    //Saving the current record in the database and the upload the record to the storage
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


    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        controller.delegate = nil
        controller.dismiss(animated: true, completion: nil)
        userWantToSaveRecord(filePath: filePath)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        displayAlert(title: "Error", message: error.localizedDescription)
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


