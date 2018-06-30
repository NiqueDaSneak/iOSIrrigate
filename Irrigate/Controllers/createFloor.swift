//
//  createFloor.swift
//  Irrigate
//
//  Created by Dom Clemmer on 6/29/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

func createFloor() -> SCNNode {
    let floor = SCNFloor()
    floor.reflectivity = 0.1
    let floorTexture = SCNMaterial()
    floorTexture.transparency = 0.1
    floorTexture.diffuse.contents = UIColor.green
    floor.length = 1000
    floor.width = 1000
    let floorNode = SCNNode(geometry: floor)
    let floorPhysicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: SCNBox(width: 100, height: 0.01, length: 1000, chamferRadius: 0)))
    floorPhysicsBody.allowsResting = true
    

    floorNode.name = "floor"
    

    
    floorNode.physicsBody = floorPhysicsBody
    floorNode.physicsBody?.categoryBitMask = BitMaskCategory.floorCategory.rawValue
    floorNode.physicsBody?.collisionBitMask = BitMaskCategory.targetCategory.rawValue | BitMaskCategory.ballCategory.rawValue | BitMaskCategory.startConeCategory.rawValue
    floorNode.physicsBody?.contactTestBitMask = BitMaskCategory.noCategory.rawValue
    
    return floorNode
}
