//
//  LoginOrSignupViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/23/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import FirebaseAuth

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
        if let user = Auth.auth().currentUser {
            let mixerPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Mixer") as! mainViewController
            self.present(mixerPage, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
