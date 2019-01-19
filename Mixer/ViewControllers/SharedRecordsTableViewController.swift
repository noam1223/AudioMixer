//
//  SharedRecordsTableViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 1/6/19.
//  Copyright © 2019 NoamSasunker. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import IQAudioRecorderController
import ChameleonFramework
import SVProgressHUD


class SharedRecordsTableViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, RecordListShareCellDelegate, IQAudioCropperViewControllerDelegate {
    
    var recordShare:[sharedRecord] = []
    var recordsLikes:[String] = []
    
    @IBOutlet weak var shareRecordsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveLikes { (likeList) in
            self.recordsLikes = likeList
            self.retrieveRecord(complition: { (finished) in
                self.shareRecordsTableView.delegate = self
                self.shareRecordsTableView.rowHeight = 160.0
                self.shareRecordsTableView.separatorStyle = .none
                self.shareRecordsTableView.backgroundColor = UIColor.flatGray
                self.shareRecordsTableView.reloadData()
            })
        }
    }
    
    func audioCropperController(_ controller: IQAudioCropperViewController, didFinishWithAudioAtPath filePath: String) {
        controller.delegate = nil
        controller.dismiss(animated: true, completion: nil)
        displayAlert(title: "Error", message: "Can not edit this file!")
    }
    
    
    func didPlayTrapped(name: String, userName:String) {
        let fileName = "/\(name).m4a"
        let storageRef = Storage.storage().reference()
        let recordRef = storageRef.child("upload").child(userName).child(fileName)
        let newfile = getURLforMemo(fileName: name) as URL
        recordRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error{
                self.displayAlert(title: "Error", message: error.localizedDescription)
            } else {
                if let d = data{
                    do{
                        try d.write(to: newfile)
                        let croppNow = IQAudioCropperViewController(filePath: newfile.path)
                        croppNow.delegate = self
                        croppNow.title = name
                        croppNow.barStyle = UIBarStyle.default
                        self.presentBlurredAudioCropperViewControllerAnimated(croppNow)
                    } catch {
                        self.displayAlert(title: "Error", message: "Please check your internet connection")
                    }
                }
            }
        }
    }
    
    
    func didLikeTrapped(recordItem:sharedRecord) {
        var didLike = false
        var indexLocation:Int!
        for index in 0..<recordsLikes.count{
            if recordsLikes[index] == recordItem.mixName{
                didLike = true
                recordItem.numberOfLikes -= 1
                indexLocation = index
            }
        }
        if !didLike{
            recordItem.numberOfLikes += 1
            recordsLikes.append(recordItem.mixName)
        } else {
            recordsLikes.remove(at: indexLocation)
        }
        saveLikes(recordShare: recordItem)
    }
    
    
    func retrieveLikes(complition:@escaping (_ likesList:[String])->Void){
        var likeslist:[String] = []
        let likeDB = Database.database().reference().child("UsersLike").child(User.user.userName)
        likeDB.observeSingleEvent(of: .value ) { (snapshot) in
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                let value = snap.value
                likeslist.append(value as! String)
            }
            likeDB.removeAllObservers()
            complition(likeslist)
        }
    }
    
    
    
    func saveLikes(recordShare:sharedRecord){
        let likeDB = Database.database().reference().child("UsersLike").child(User.user.userName)
        likeDB.setValue(recordsLikes) { (err, data) in
            likeDB.removeAllObservers()
            if let err = err{
                self.displayAlert(title: "Error", message: err.localizedDescription)
            } else {
                let recordDB = Database.database().reference().child("RecordsShared").child(recordShare.userName)
                recordDB.updateChildValues(["Likes" : recordShare.numberOfLikes], withCompletionBlock: { (err, data) in
                    recordDB.removeAllObservers()
                    self.shareRecordsTableView.reloadData()
                })
            }
        }
    }
    
    
    func retrieveRecord(complition:@escaping (_ finished:Bool)->Void){
        let recordDB = Database.database().reference().child("RecordsShared")
        recordDB.observe(DataEventType.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            let userName = snapshotValue["Sender"] as! String
            let recordName = snapshotValue["RecordName"] as! String
            let numberOfLikes = snapshotValue["Likes"] as! Int
            
            let newRecordShare = sharedRecord(userName: userName, mixName: recordName, numberOfLikes: numberOfLikes)
            self.recordShare.append(newRecordShare)
            recordDB.removeAllObservers()
            complition(true)
        }
    }
    
    
    @IBAction func backTrapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordShare.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newShareRecord = recordShare[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SharedRecordsCell", for: indexPath) as! RecordListShare
        cell.setRecordShared(recordShared: newShareRecord , recordLikes: recordsLikes)
        cell.delegate = self
        if let color = FlatMint().darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(recordShare.count))){
            cell.backgroundColor = color
            cell.recordNameLabel.textColor = ContrastColorOf(color, returnFlat: true)
            cell.numberOfLikesLable.textColor = ContrastColorOf(color, returnFlat: true)
            cell.userNameLabel.textColor = ContrastColorOf(color, returnFlat: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shareRecordsTableView.deselectRow(at: indexPath, animated: true)
    }
    
}
