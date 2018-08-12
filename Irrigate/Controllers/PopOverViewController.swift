//
//  PopOverViewController.swift
//  Irrigate
//
//  Created by Dom Clemmer on 7/31/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit

class PopOverViewController: UIViewController {
    
    let username = UserDefaults.standard.string(forKey: "sessionUsername") as! String
    
    @IBOutlet weak var currentUsername: UILabel!
    @IBOutlet weak var currentScore: UILabel!
    @IBOutlet weak var currentUserHighScore: UILabel!
    
    var gameScore:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUsername.text = "@\(username)'s scores"
        currentScore.text = "last score: \(UserDefaults.standard.integer(forKey: "currentScore"))"
        currentUserHighScore.text = "best score: \(UserDefaults.standard.integer(forKey: "highScore"))"

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
