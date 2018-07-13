//
//  LogInViewController.swift
//  Irrigate
//
//  Created by Clemmer, Dom on 6/14/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LogInViewController: UIViewController {

    @IBOutlet weak var logInEmail: UITextField!
    @IBOutlet weak var logInPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logInPressed(_ sender: UIButton) {
        let email = logInEmail.text
        let pass = logInPass.text
        
        Auth.auth().signIn(withEmail: email!, password: pass!) { (result, error) in
            if (error != nil) {
                print(error!)
            } else {
                self.performSegue(withIdentifier: "showOverview", sender: self)
                
                UserDefaults.standard.set(result?.user.email, forKey: "sessionEmail")
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
