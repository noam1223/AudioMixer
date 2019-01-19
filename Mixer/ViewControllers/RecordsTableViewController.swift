//
//  RecordsTableViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/30/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import ChameleonFramework
import IQAudioRecorderController
import CoreLocation
import SVProgressHUD

class RecordsTableViewController: UIViewController, IQAudioCropperViewControllerDelegate, CLLocationManagerDelegate {
    
    var recordPlist:[audioMixer]! = []
    let locationManager = CLLocationManager()
    @IBOutlet weak var recordsListTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecordsFromDatabase { (recordsList) in
            self.recordPlist = recordsList
            self.recordsListTableView.delegate = self
            self.recordsListTableView.rowHeight = 70.0
            self.recordsListTableView.separatorStyle = .none
            self.recordsListTableView.backgroundColor = UIColor.flatGray
            self.recordsListTableView.reloadData()
        }
    }
    
    
    func didBtnTrapped(name: String) {
        let recordDB = Database.database().reference().child("RecordsShared")
        let recordDictionary = ["Sender" : User.user.userName,
                                "RecordName" : name,
                                "Likes" : 0] as [String : Any]
        
        recordDB.child(User.user.userName).setValue(recordDictionary) { (err, ref) in
            if err != nil{
                self.displayAlert(title: "Error", message: err!.localizedDescription)
            } else {
                self.displayAlert(title: "Shared", message: "Notice: you can only share one record mix!")
            }
        }
    }
    
    
    func audioCropperController(_ controller: IQAudioCropperViewController, didFinishWithAudioAtPath filePath: String) {
        print("finished")
        dismiss(animated: true, completion: nil)
        userWantToSaveRecord(filePath: filePath)
    }
    
    @IBAction func backTrapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func userWantToSaveRecord(filePath:String) {
        var newTextField = UITextField()
        var longitud:CLLocationDegrees = (self.locationManager.location?.coordinate.longitude)!
        var latitude:CLLocationDegrees = (self.locationManager.location?.coordinate.latitude)!
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alertInit(alert: alert, title: "Save", message: "Do you want to save the record?")
        let action1 = UIAlertAction(title: "Yes", style: .default) { (action) in
            SVProgressHUD.show()
            self.getAddress(longitude: longitud, latitude: latitude) { (address) in
                self.recordPlist.append(audioMixer(name: newTextField.text!, address: address!))
                self.saveRecordsAtDatabase(recordsList: self.recordPlist)
                self.uploadSound(localFile: URL.init(fileURLWithPath: filePath) ,name: newTextField.text!)
                self.locationManager.stopUpdatingLocation()
                SVProgressHUD.dismiss()
                self.recordsListTableView.reloadData()
            }
        }
        
        let action2 = UIAlertAction(title: "No", style: .destructive, handler: nil)
        
        alert.addTextField { (alertTextField) in
            self.alerTextFieldInit(alertTextField: alertTextField)
            newTextField = alertTextField
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
}




    // MARK: - Table view data source
extension RecordsTableViewController : UITableViewDelegate, UITableViewDataSource, RecordCellDelegate{

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordPlist.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listRecordViewController", for: indexPath) as! shareRecordCell
        let record = recordPlist[indexPath.row]
        cell.setRecord(records: record)
        cell.delegate = self
        if let color = FlatMint().darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(recordPlist.count))){
            cell.backgroundColor = color
            cell.recordLabelView?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let name = recordPlist[indexPath.row].name!
        let fileName = "/\(name).m4a"
        let storageRef = Storage.storage().reference()
        let recordRef = storageRef.child("upload").child(User.user.userName).child(fileName)
        let newfile = getURLforMemo(fileName: name) as URL
        recordRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error{
                self.displayAlert(title: "Error", message: error.localizedDescription)
            } else {
                if let data = data{
                    do{
                        try data.write(to: newfile)
                        let croppNow = IQAudioCropperViewController(filePath: newfile.path)
                        croppNow.delegate = self
                        croppNow.title = name
                        croppNow.barStyle = UIBarStyle.default
                        self.presentBlurredAudioCropperViewControllerAnimated(croppNow)
                    } catch {
                        self.displayAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let name = recordPlist[indexPath.row].name!
            deleteSound(name: name)
            recordPlist.remove(at: indexPath.row)
            saveRecordsAtDatabase(recordsList: recordPlist)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
