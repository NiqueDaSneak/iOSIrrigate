//
//  TargetClass.swift
//  Irrigate
//
//  Created by Dom Clemmer on 6/29/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class Target {
    

    
}

func createTarget(forStart:Bool) -> SCNNode {
    let gameScene = SCNScene(named: "art.scnassets/largeCone.scn")
    let coneNode = gameScene?.rootNode.childNode(withName: "LargeCone", recursively: false)
    
    coneNode?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: coneNode!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: 0.200]))
    coneNode?.physicsBody?.collisionBitMask = BitMaskCategory.ballCategory.rawValue | BitMaskCategory.floorCategory.rawValue
    coneNode?.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
    
    if forStart == true {
        coneNode?.name = "startCone"
        coneNode?.physicsBody?.categoryBitMask = BitMaskCategory.startConeCategory.rawValue
    } else {
        coneNode?.name = UUID().uuidString
        coneNode?.physicsBody?.categoryBitMask = BitMaskCategory.targetCategory.rawValue
    }
    
    return coneNode!
    
}

func randomFloat(min:Float, max:Float) -> Float {
    return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
}
