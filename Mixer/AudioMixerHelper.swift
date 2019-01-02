//
//  AudioMixerHelper.swift
//  
//
//  Created by NoamSasunker on 12/23/18.
//

import UIKit
import AVFoundation
import FirebaseStorage


extension UIViewController{
    
    //func that gets path to directory
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
    
    
    func deleteSound(name:String){
        let storageRef = Storage.storage().reference()
        let fileName = "/\(name).m4a"
        let imagesRef = storageRef.child("upload").child(fileName)
        imagesRef.delete { (err) in
            if let err = err{
                self.displayAlert(title: "Delete", message: "Can not delete this file")
            } else{
                print("SUCCESS")
            }
        }
    }
    
}
