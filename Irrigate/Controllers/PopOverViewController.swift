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
    @IBOutlet weak var usernameHeader: UILabel!
    @IBOutlet weak var currentScore: UILabel!
    @IBOutlet weak var bestScore: UILabel!
    var gameScore:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameHeader.text = "\(String(describing: username))'s Scores"
        currentScore.text = String(UserDefaults.standard.integer(forKey: "currentScore"))
        bestScore.text = String(UserDefaults.standard.integer(forKey: "highScore"))

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func restartGamePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
