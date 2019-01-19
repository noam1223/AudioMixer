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
    
    var email:String?
    var password:String?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func checkUser(_ sender: UIButton) {
        
        passwordTextField.backgroundColor = UIColor.white
        emailTextField.backgroundColor = UIColor.white

        if !(emailTextField.text?.isEmpty)!{
            if !(passwordTextField.text?.isEmpty)!{
                SVProgressHUD.show()
                
                email = emailTextField.text
                password = passwordTextField.text
                
                Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
                    SVProgressHUD.dismiss()
                    if let error = error{
                        self.displayAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        let mixer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Mixer") as! AudioMixerMenuViewController
                        self.present(mixer, animated: true, completion: nil)            }
                }
            } else {
                passwordTextField.shake()
                passwordTextField.backgroundColor = UIColor.red
            }
        } else {
            emailTextField.shake()
            emailTextField.backgroundColor = UIColor.red
        }
    }
    
    @IBAction func forgetPasswordTrapped(_ sender: UIButton) {
        
        var newTextField = UITextField()

        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alertInit(alert: alert, title: "Email Verification", message: "Please enter your email address, Email will send you as soon as possible.")
        let action1 = UIAlertAction(title: "No", style: .destructive, handler: nil)
        let action2 = UIAlertAction(title: "Yes", style: .default) { (action) in
            let email = newTextField.text!
            Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                if let error = error{
                    self.displayAlert(title: "Error", message: error.localizedDescription)
                } else {
                    self.displayAlert(title: "Success", message: "Email has sent to you with reset password link")
                }
            })
        }
        
        alert.addTextField { (textField) in
            self.alerTextFieldInit(alertTextField: textField)
            newTextField = textField
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backToHomePage(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
