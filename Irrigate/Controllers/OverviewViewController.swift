//
//  OverviewViewController.swift
//  Irrigate
//
//  Created by Clemmer, Dom on 6/14/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import PKHUD

class OverviewViewController: UIViewController {
    var db: DatabaseReference!

    var sessionUsername:String?
    let sessionEmail = UserDefaults.standard.string(forKey: "sessionEmail")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        db = Database.database().reference()

        if sessionUsername != nil {
            print("USERNAME: \(String(describing: sessionUsername))")
        } else {
            let usersRef = db.child("users")
            let query = usersRef.child((Auth.auth().currentUser?.uid)!)
            
            query.observe(.value, with: { snapshot in

                if snapshot.value is NSNull {
                    
                    let alert = UIAlertController(title: "Need Username", message: "We need you to create a username. Input below.", preferredStyle: .alert)
                    alert.addTextField { (textField) in
                        textField.placeholder = "Username goes here"
                    }
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Submit", comment: "Create Username"), style: .default, handler: { _ in
                        UserDefaults.standard.set(alert.textFields?.first?.text, forKey: "sessionUsername")
                        self.sessionUsername = alert.textFields?.first?.text
                        let user = ["email": self.sessionEmail, "username": self.sessionUsername]
                        self.db.child("users").child((Auth.auth().currentUser?.uid)!).setValue(user)
                        print("sessionUsername \(String(describing: self.sessionUsername))")
                        HUD.flash(.success, delay: 1.0)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    for child in snapshot.children {
                        let snap = child as! DataSnapshot
                        
                        if snap.value != nil {
                            if snap.key == "username" {
                                if snap.value != nil {
                                    self.sessionUsername = snap.value as? String
                                    print("sessionUsername \(String(describing: self.sessionUsername))")
                                } else {
                                    
                                    let alert = UIAlertController(title: "Need Username", message: "We need you to create a username. Input below.", preferredStyle: .alert)
                                    alert.addTextField { (textField) in
                                        textField.placeholder = "Username goes here"
                                    }
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Submit", comment: "Create Username"), style: .default, handler: { _ in
                                        UserDefaults.standard.set(alert.textFields?.first?.text, forKey: "sessionUsername")
                                        self.sessionUsername = alert.textFields?.first?.text
                                        let user = ["email": self.sessionEmail, "username": self.sessionUsername]
                                        self.db.child("users").child((Auth.auth().currentUser?.uid)!).setValue(user)
                                        print("sessionUsername \(String(describing: self.sessionUsername))")
                                        HUD.flash(.success, delay: 1.0)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                    
                                }
                            }
                        }
                    }
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logOut(_ sender: UIButton) {
        do {
        try Auth.auth().signOut()
        } catch {
            print("error logging out: \(error)")
        }
        UserDefaults.standard.set(nil, forKey: "sessionUsername")
        UserDefaults.standard.set(nil, forKey: "sessionEmail")
        self.performSegue(withIdentifier: "logOut", sender: self)
    }
    
}


