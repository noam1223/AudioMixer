//
//  ViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/2/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import FirebaseAuth

class mainViewController: UIViewController {
    
    @IBAction func logOutTrapped(_ sender: UIButton) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func listRecord(_ sender: UIButton) {
        let listRecord = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "recordListViewController") as! recordsListViewController
        self.present(listRecord, animated: true, completion: nil)
    }
    
    @IBAction func startRecordViewController(_ sender: UIButton) {
        let startRecord = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "recordViewController") as! recordViewController
        self.present(startRecord, animated: true, completion: nil)
    }
    @IBAction func startMix(_ sender: UIButton) {
        let mixerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mixerViewController") as! theMixerViewController
        self.present(mixerViewController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

