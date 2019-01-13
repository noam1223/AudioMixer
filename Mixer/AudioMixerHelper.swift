//
//  AudioMixerHelper.swift
//  
//
//  Created by NoamSasunker on 12/23/18.
//

import UIKit
import AVFoundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import CoreLocation


extension UIViewController{
    
    func getDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    
    func getURLforMemo(fileName: String) -> NSURL {
        let tempDir = NSTemporaryDirectory()
        let filePath = tempDir + "/" + fileName + ".m4a"
        
        return NSURL.fileURL(withPath: filePath) as NSURL
    }
    
    
    func displayAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func saveRecords(recordList:[audioMixer]){
        let recordListPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("recording.plist")
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(recordList)
            try data.write(to: recordListPath)
        } catch {
            print("ERROR SAVING RECORD: \(error)")
        }
    }
    
    
    func saveRecordsAtDatabase(recordsList:[audioMixer]){
        let recordDB = Database.database().reference().child("myRecords").child(User.user.userName)
        var recordsDictionary:[[String : String]] = []
        for recordItem in recordsList {
            let newRecordDictionary = ["recordName" : recordItem.name, "Address" : recordItem.address]
            recordsDictionary.append(newRecordDictionary as! [String : String])
        }
        recordDB.setValue(recordsDictionary)
    }
    
    
    func loadRecords() -> [audioMixer]{
        let recordListPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("recording.plist")
        var loadedRecords = [audioMixer]()
        if let data = try? Data(contentsOf: recordListPath){
            let decoder = PropertyListDecoder()
            do{
                loadedRecords = try decoder.decode([audioMixer].self, from: data)
            } catch {
                print("ERROR TO LOAD RECORDS: \(error)")
            }
        }
        return loadedRecords
    }
    
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
    
    
    func deleteSound(name:String){
        let storageRef = Storage.storage().reference()
        let fileName = "/\(name).m4a"
        let recordRef = storageRef.child("upload").child(User.user.userName).child(fileName)
        recordRef.delete { (err) in
            if let err = err{
                self.displayAlert(title: "Failed", message: "Can not delete this file")
            }
        }
    }
    
    func getAddress(longitude: Double, latitude: Double, comlition:@escaping (_ answer:String?)->Void){
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geo = CLGeocoder()
        
        geo.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error{
                print(error)
            }
            
            if (placemarks?.count)! > 0 {
                let place = placemarks?.last as CLPlacemark!
                comlition(self.displayAddress(placemark: place))
            }
        }
        
    }
    
    func displayAddress(placemark:CLPlacemark?) -> String?{
        if let containPlacemark = placemark{
            return containPlacemark.thoroughfare!
        } else{
            return ""
        }
    }
    

}
