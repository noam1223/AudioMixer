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
        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int { numberOfRecords = number }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordsCell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Shared.shared.companyName = String(indexPath.row + 1)
        dismiss(animated: true, completion: nil)
    }
    
}
    


