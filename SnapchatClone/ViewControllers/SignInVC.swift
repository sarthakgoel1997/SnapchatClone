//
//  ViewController.swift
//  SnapchatClone
//
//  Created by Sarthak Goel on 29/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignInVC: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signInClicked(_ sender: Any) {
        if emailText.text != "" && passwordText.text != "" {
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { (result, error) in
                if error != nil {
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error while signing in")
                } else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        } else {
            makeAlert(title: "Error", message: "Email/Password is empty")
        }
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        if emailText.text != "" && usernameText.text != "" && passwordText.text != "" {
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (result, createUserError) in
                if createUserError != nil {
                    self.makeAlert(title: "Error", message: createUserError?.localizedDescription ?? "Error while signing up")
                } else {
                    let userDictionary = ["email": self.emailText.text!, "username": self.usernameText.text!] as [String : Any]
                    let firestore = Firestore.firestore()
                    
                    firestore.collection("UserInfo").addDocument(data: userDictionary) { (addUserInfoError) in
                        if addUserInfoError != nil {
                            self.makeAlert(title: "Error", message: addUserInfoError?.localizedDescription ?? "Error while adding user info")
                        } else {
                            self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                        }
                    }
                }
            }
        } else {
            makeAlert(title: "Error", message: "Email/Username/Password is empty")
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}

