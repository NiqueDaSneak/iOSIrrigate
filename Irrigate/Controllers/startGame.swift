//
//  startGame.swift
//  Irrigate
//
//  Created by Dom Clemmer on 6/29/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

func startGame() -> [SCNNode] {
    var targetArray:[SCNNode] = []
    
    for _ in 1...15 {
        let target = createTarget(forStart: false)
        let randX = randomFloat(min: -15, max: 15)
        let randY = 0
        let randZ = randomFloat(min: -15, max: 15)
        target.position = SCNVector3(x: randX, y: Float(randY), z: randZ)
        targetArray.append(target)
    }
    
    return targetArray
}
