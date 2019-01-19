//
//  ChooseRecordPopUpViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/11/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import ChameleonFramework

class ChooseRecordPopUpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var recordPlist = [audioMixer]()
    @IBOutlet weak var recordsTableView: UITableView!
    @IBOutlet weak var popUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        recordsTableView.delegate = self
        recordsTableView.dataSource = self
        self.loadRecordsFromDatabase { (recordsListFromDatabase) in
            self.recordPlist = recordsListFromDatabase
            self.recordsTableView.delegate = self
            self.recordsTableView.rowHeight = 70.0
            self.recordsTableView.separatorStyle = .none
            self.recordsTableView.backgroundColor = UIColor.flatGray
            self.popUpView.layer.cornerRadius = 15
            self.recordsTableView.reloadData()
        }
    }
    
    
    @IBAction func ClosePopUpRecordList(_ sender: UIButton) {
        removeAnimate()
    }
    
    
    func showAnimate(){
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    
    func removeAnimate(){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: { (finished) in
            if finished{
                self.view.removeFromSuperview()
            }
        })
    }
    

    //MARK: table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordPlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordsCell", for: indexPath)
        cell.textLabel?.text = recordPlist[indexPath.row].name + "/" + recordPlist[indexPath.row].address
        if let color = FlatMint().darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(recordPlist.count))){
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Shared.shared.companyName = recordPlist[indexPath.row].name
        removeAnimate()
    }
}
