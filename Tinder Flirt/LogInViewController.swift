//
//  LogInViewController.swift
//  Tinder Flirt
//
//  Created by Emil Vaklinov on 02/05/2020.
//  Copyright © 2020 Emil Vaklinov. All rights reserved.
//

import UIKit
import Parse
class LogInViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInSignUpButton: UIButton!
    @IBOutlet weak var changeLogInSignUpButton: UIButton!
    
    var signUpMode = true
    
    @IBAction func logInSignUpTapped(_ sender: Any) {
        
        if signUpMode {
            let user = PFUser()
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            
            user.signUpInBackground(block: { (success, error) in
                if error != nil {
                    var errorMessage = "Sign up Failed - Try again!"
                    if let newError = error as NSError? {
                        if let detailedError = newError.userInfo["error"] as? String {
                            errorMessage = detailedError
                        }
                    }
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = errorMessage
                } else {
                    print("Sign up Successful")
                }
            })
            
        } else {
            if let username = usernameTextField.text {
                if let password = passwordTextField.text {
                    PFUser.logInWithUsername(inBackground: username, password: password, block: { (user, error) in
                        if error != nil {
                            var errorMessage = "Login Failed - Try again!"
                            if let newError = error as NSError? {
                                if let detailedError = newError.userInfo["error"] as? String {
                                    errorMessage = detailedError
                                }
                            }
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = errorMessage
                        } else {
                            print("Login Successful")
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func changeLogInSignUpTapped(_ sender: Any) {
        // Creating shafle of the buttons
        if signUpMode {
            logInSignUpButton.setTitle("Log In", for: .normal)
            changeLogInSignUpButton.setTitle("Sign Up", for: .normal)
            signUpMode = false
        } else {
            logInSignUpButton.setTitle("Sign Up", for: .normal)
            changeLogInSignUpButton.setTitle("Log In", for: .normal)
            signUpMode = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    


}
