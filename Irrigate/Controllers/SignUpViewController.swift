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
        
        Auth.auth().createUser(withEmail: email!, password: pass!) { (user, error) in
            if (error != nil) {
                print(error!)
            } else {
                // TRANSITION TO OVERVIEW PAGE
                self.performSegue(withIdentifier: "showOverview", sender: self)
                print(user!.user)
            }
        }
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
