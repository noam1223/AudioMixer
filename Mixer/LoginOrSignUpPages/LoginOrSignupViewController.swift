//
//  LoginOrSignupViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/23/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class LoginOrSignupViewController: UIViewController {

    @IBAction func loginTrapped(_ sender: UIButton) {
        let loginPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogIn") as! LoginViewController
        self.present(loginPage, animated: true, completion: nil)
    }
    
    @IBAction func signUpTrapped(_ sender: UIButton) {
        let signUp = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp") as! SignUpViewController
        self.present(signUp, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            let mixerPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Mixer") as! AudioMixerMenuViewController
            self.present(mixerPage, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.dismiss()
    }
}
