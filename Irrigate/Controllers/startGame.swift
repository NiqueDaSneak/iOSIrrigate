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

func startGame() -> SCNNode {
    
    let goalScene = SCNScene(named: "art.scnassets/goal.scn")
    let goalNode = goalScene?.rootNode.childNode(withName: "goal", recursively: false)
//    goalNode?.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0)
//    goalNode?.eulerAngles.x = -45
//    goalNode?.eulerAngles.y = 180
    goalNode?.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
    goalNode?.position = SCNVector3(x: 0.0, y: 0.0, z: -1.5)
//    var targetArray:[SCNNode] = []
    
//    for _ in 1...15 {
//        let target = createTarget(forStart: false)
//        let randX = randomFloat(min: -15, max: 15)
//        let randY = 0
//        let randZ = randomFloat(min: -15, max: 15)
//        target.position = SCNVector3(x: randX, y: Float(randY), z: randZ)
//        targetArray.append(target)
//    }
    
    return goalNode!
  
}
