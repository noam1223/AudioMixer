//
//  ChooseRecordPopUpViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/11/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import AVFoundation

class ChooseRecordPopUpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate {
    
    let recordListPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("recording.plist")
    var recordPlist = [audioMixer]()
    
    func loadRecords(){
        if let data = try? Data(contentsOf: recordListPath!){
            let decoder = PropertyListDecoder()
            do{
                recordPlist = try decoder.decode([audioMixer].self, from: data)
            } catch {
                print("ERROR TO LOAD RECORDS: \(error)")
            }
        }
    }

    @IBOutlet weak var recordsTableView: UITableView!
    var recordingSession:AVAudioSession!
    var audioPlayer:AVAudioPlayer!
    var numberOfRecords:Int!

    @IBAction func ClosePopUpRecordList(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingSession = AVAudioSession.sharedInstance()
        loadRecords()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordPlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordsCell", for: indexPath)
        cell.textLabel?.text = recordPlist[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Shared.shared.companyName = recordPlist[indexPath.row].name
        print(Shared.shared.companyName)
        dismiss(animated: true, completion: nil)
    }
    
}
    


