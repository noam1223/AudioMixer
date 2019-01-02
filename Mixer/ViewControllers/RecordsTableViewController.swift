//
//  RecordsTableViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/30/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import FirebaseStorage
import ChameleonFramework
import IQAudioRecorderController

class RecordsTableViewController: UIViewController, UITableViewDelegate ,UITableViewDataSource, IQAudioCropperViewControllerDelegate {
    
    
    @IBOutlet weak var recordsListTableView: UITableView!
    
    func audioCropperController(_ controller: IQAudioCropperViewController, didFinishWithAudioAtPath filePath: String) {
        print("finished")
        dismiss(animated: true, completion: nil)
        userWantToSaveRecord(filePath: filePath)
    }
    
    @IBAction func backTrapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    let recordListPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("recording.plist")
    var recordPlist:[audioMixer]?
    let storageRef = Storage.storage().reference()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        recordPlist = loadRecords()
        recordsListTableView.delegate = self
        recordsListTableView.rowHeight = 70.0
        recordsListTableView.separatorStyle = .none
        recordsListTableView.backgroundColor = UIColor.flatGray
    }
    
    func userWantToSaveRecord(filePath:String) {
        var newTextField = UITextField()
        
        let alert = UIAlertController(title: "Save", message: "Do you want to save the record?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .default) { (yesAction) in
            self.recordPlist?.append(audioMixer(name: newTextField.text!))
            self.saveRecords(recordList: self.recordPlist!)
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

    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (recordPlist?.count)!
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordListViewController", for: indexPath)
        cell.textLabel?.text = recordPlist?[indexPath.row].name
        if let color = FlatMint().darken(byPercentage: (CGFloat(indexPath.row) / CGFloat((recordPlist?.count)!))){
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }

        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let name = recordPlist![indexPath.row].name!
        let fileName = "/\(name).m4a"
        let recordRef = storageRef.child("upload").child(fileName)
        let newfile = getURLforMemo(fileName: name) as URL
        let downloadTask = recordRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error{
                print(error)
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
                        print(error)
                    }
                }
            }
        }
    }

    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let name = recordPlist![indexPath.row].name!
            deleteSound(name: name)
            recordPlist?.remove(at: indexPath.row)
            saveRecords(recordList: recordPlist!)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            recordsListTableView.reloadData()
        }
    }
}

