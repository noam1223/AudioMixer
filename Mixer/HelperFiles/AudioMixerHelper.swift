//
//  AudioMixerHelper.swift
//  
//
//  Created by NoamSasunker on 12/23/18.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import CoreLocation


extension UIViewController{
    
    //Get temporary directory path file
    func getURLforMemo(fileName: String) -> NSURL {
        let tempDir = NSTemporaryDirectory()
        let filePath = tempDir + "/" + fileName + ".m4a"
        
        return NSURL.fileURL(withPath: filePath) as NSURL
    }
    
    //Present alert to the user
    func displayAlert(title:String, message:String){
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alertInit(alert: alert, title: title, message: message)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func alertInit(alert:UIAlertController, title:String, message:String){
        alert.view.backgroundColor = UIColor.cyan
        alert.view.layer.cornerRadius = 25
        let titleFont = [NSAttributedStringKey.font : UIFont(name: "AmericanTypewriter", size: 19)!]
        let messageFont = [NSAttributedStringKey.font : UIFont(name: "AvenirNext-Bold", size: 14)!]
        let attributedTitle = NSMutableAttributedString(string: title, attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: message, attributes: messageFont)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
    }
    
    
    func alerTextFieldInit(alertTextField: UITextField) {
        alertTextField.keyboardAppearance = .dark
        alertTextField.textColor = UIColor.flatGreenDark
        alertTextField.placeholder = "Name it!"
        alertTextField.font = UIFont(name: "AvenirNext-Bold", size: 14)
    }
    
    
    //Saving the list records at the firebase database
    func saveRecordsAtDatabase(recordsList:[audioMixer]){
        let recordDB = Database.database().reference().child("myRecords").child(User.user.userName)
        var recordsDictionary:[[String : String]] = []
        for recordItem in recordsList {
            let newRecordDictionary = ["recordName" : recordItem.name, "Address" : recordItem.address]
            recordsDictionary.append(newRecordDictionary as! [String : String])
        }
        recordDB.setValue(recordsDictionary)
    }
    
    //Loading the list records from the firebase database
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
    
    //Up load the song to the storage of the firebase
    func uploadSound(localFile: URL, name:String) {
        let storageRef = Storage.storage().reference()
        let fileName = "/\(name).m4a"
        let recordRef = storageRef.child("upload").child(User.user.userName).child(fileName)
        recordRef.putFile(from: localFile, metadata: nil) { metadata, error in
            if let error = error {
                print("ERROE TO UPLOAD: \(error)")
            } else {
                let downloadURL = metadata!.size
                print("\(downloadURL)")
            }
        }
    }
    
    //Delete song from the storage of firebase
    func deleteSound(name:String){
        let storageRef = Storage.storage().reference()
        let fileName = "/\(name).m4a"
        let recordRef = storageRef.child("upload").child(User.user.userName).child(fileName)
        recordRef.delete { (err) in
            if err != nil{
                self.displayAlert(title: "Failed", message: "Can not delete this file")
            }
        }
    }
    
    //Gets the user location
    func getAddress(longitude: Double, latitude: Double, comlition:@escaping (_ answer:String?)->Void){
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geo = CLGeocoder()
        
        geo.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil{
                comlition(self.displayAddress(placemark: nil))
            }
            
            if (placemarks?.count)! > 0 {
                let place = placemarks?.last as CLPlacemark!
                comlition(self.displayAddress(placemark: place))
            }
        }
        
    }
    
    //Sending the thoroughfare of the user
    func displayAddress(placemark:CLPlacemark?) -> String?{
        if let containPlacemark = placemark{
            return containPlacemark.thoroughfare!
        } else{
            return "Cannot find your location"
        }
    }
}


extension UITextField{
    
    func shake(horizintaly:CGFloat = 4, verticaly:CGFloat = 0){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - horizintaly, y: self.center.y - verticaly))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + horizintaly, y: self.center.y + verticaly))
        self.layer.add(animation, forKey: "position")
    }
}
