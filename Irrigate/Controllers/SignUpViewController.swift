//
//  SignUpViewController.swift
//  Irrigate
//
//  Created by Clemmer, Dom on 6/14/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var signUpEmail: UITextField!
    @IBOutlet weak var signUpPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        let email = signUpEmail.text
        let pass = signUpPassword.text
        
        Auth.auth().createUser(withEmail: email!, password: pass!) { (result, error) in
            if (error != nil) {
                print(error!)
            } else {
                self.performSegue(withIdentifier: "showOverview", sender: self)
               
                UserDefaults.standard.set(result?.user.email, forKey: "sessionEmail")
            }
        }
    }
}
