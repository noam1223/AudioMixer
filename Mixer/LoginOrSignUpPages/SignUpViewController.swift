//
//  SignUpViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/23/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func insertToFireBaseUsers(_ sender: UIButton) {
        SVProgressHUD.show()
        guard let userName = userNameTextField.text else {
            return
        }
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error{
                print(error)
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
