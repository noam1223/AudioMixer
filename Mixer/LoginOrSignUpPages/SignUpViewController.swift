//
//  SignUpViewController.swift
//  Mixer
//
//  Created by NoamSasunker on 12/23/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class SignUpViewController: UIViewController {
    
    
    var userName:String?
    var email:String?
    var password:String?
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func insertToFireBaseUsers(_ sender: UIButton) {
        
        userNameTextField.backgroundColor = UIColor.white
        emailTextField.backgroundColor = UIColor.white
        passwordTextField.backgroundColor = UIColor.white
        
        if !(userNameTextField.text?.isEmpty)!{
            if !(emailTextField.text?.isEmpty)!{
                if !(passwordTextField.text?.isEmpty)!{
                    
                    SVProgressHUD.show()
                    
                    userName = userNameTextField.text
                    email = emailTextField.text
                    password = passwordTextField.text
                    
                    Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
                        SVProgressHUD.dismiss()
                        if let error = error{
                            self.displayAlert(title: "Error", message: error.localizedDescription)
                        } else {
                            let uid = Auth.auth().currentUser?.uid
                            User.user.firstTimeLoggedIn = true
                            let databaseRF = Database.database().reference()
                            let newUserName = databaseRF.child("Users").child(uid!)
                            let userDictionary = ["userName" : self.userName, "Email" : self.email, "Password" : self.password]
                            newUserName.setValue(userDictionary, withCompletionBlock: {( err, database) in
                                let mixer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Mixer") as! AudioMixerMenuViewController
                                self.present(mixer, animated: true, completion: nil)
                            })
                        }
                    }
                } else {
                    passwordTextField.shake()
                    passwordTextField.backgroundColor = UIColor.red
                }
            } else {
                emailTextField.shake()
                emailTextField.backgroundColor = UIColor.red
            }
        } else {
            userNameTextField.shake()
            userNameTextField.backgroundColor = UIColor.red
        }
    }
    
    
    @IBAction func backToHomePage(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
