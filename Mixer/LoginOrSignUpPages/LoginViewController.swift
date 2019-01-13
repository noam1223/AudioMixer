//
//  LoginViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/23/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func checkUser(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error{
                print(error)
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.dismiss()
                let mixer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Mixer") as! mainViewController
                self.present(mixer, animated: true, completion: nil)            }
        }
    }
    
    @IBAction func backToHomePage(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
