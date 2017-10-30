//
//  LoginViewController.swift
//  InClass07
//
//  Created by Gupta, Nidhi on 10/26/17.
//  Copyright © 2017 Example. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
   
 
   
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = Auth.auth().currentUser {
            print("already logged in")
           self.signIn()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
  
    @IBAction func btnLogin_Clicked(_ sender: Any) {
       let email = txtEmail.text!
        let password = txtPassword.text!
        if(email.isEmpty || password.isEmpty)
        {
            showAlert("Email or Password not entered.")
        }
        else
        {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if user == nil {
                    if let error = error {
                        if let errCode = AuthErrorCode(rawValue: error._code) {
                            switch errCode {
                            case AuthErrorCode.userNotFound:
                                self.showAlert("User account not found. Try registering")
                            case AuthErrorCode.wrongPassword:
                                self.showAlert("Incorrect username/password combination")
                            default:
                                self.showAlert("Error: \(error.localizedDescription)")
                            }
                        }
                        return
                    }
                }else{
                  self.signIn()
                }
            })
        }
    }
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Login Failed", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func signIn() {
       
      let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let navController = storyBoard.instantiateViewController(withIdentifier: "navController") as! UINavigationController
        let allPhotosVC = self.storyboard!.instantiateViewController(withIdentifier: "allPhotosVC") as! PhotoCollectionViewController
        self.present(navController, animated: false, completion: {
            navController.pushViewController(allPhotosVC, animated: false)
        })
    }

}
