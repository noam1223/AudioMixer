//
//  ChooseRecordPopUpViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/11/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit

class ChooseRecordPopUpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let recordListPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("recording.plist")
    var recordPlist = [audioMixer]()

    @IBOutlet weak var recordsTableView: UITableView!

    var numberOfRecords:Int!

    @IBAction func ClosePopUpRecordList(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordPlist = loadRecords()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordPlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordsCell", for: indexPath)
        cell.textLabel?.text = recordPlist[indexPath.row].name + "/" + recordPlist[indexPath.row].address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Shared.shared.companyName = recordPlist[indexPath.row].name
        dismiss(animated: true, completion: nil)
    }
    
}
    


