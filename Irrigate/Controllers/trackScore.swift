//
//  trackScore.swift
//  Irrigate
//
//  Created by Dom Clemmer on 7/17/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import Firebase
import FirebaseAuth
import FirebaseDatabase

func trackScore(score:Int, user:String) {
    let db:DatabaseReference
    db = Database.database().reference()
    let scoreDic = [user: score]
    
    db.child("scores").childByAutoId().setValue(scoreDic)

}
