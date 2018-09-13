//
//  createMenuTargets.swift
//  Irrigate
//
//  Created by Dom Clemmer on 8/14/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

func  createMenuTargets(scene:ARSCNView) {
    
    scene.scene.rootNode.enumerateChildNodes{ (node,_) in
        if node.name == "startCone" || node.name == "quitTarget" || node.name == "trainTarget" {
            node.removeFromParentNode()
        }
    }
    
    let greenTarget = makeLargeCone()
    greenTarget.position = SCNVector3(-4,0,-4)
    greenTarget.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: greenTarget, options: [SCNPhysicsShape.Option.scale: 0.25]))
    greenTarget.name = "startCone"
    greenTarget.geometry?.firstMaterial?.diffuse.contents = UIColor.green
    
    greenTarget.physicsBody?.categoryBitMask = BitMaskCategory.startConeCategory.rawValue
    greenTarget.physicsBody?.collisionBitMask = BitMaskCategory.floorCategory.rawValue | BitMaskCategory.ballCategory.rawValue
    greenTarget.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
    
    let redTarget = makeLargeCone()
    redTarget.position = SCNVector3(-5,0,-4)
    redTarget.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: redTarget, options: [SCNPhysicsShape.Option.scale: 0.25]))
    redTarget.name = "quitTarget"
    redTarget.geometry?.firstMaterial?.diffuse.contents = UIColor.red
    
    redTarget.physicsBody?.categoryBitMask = BitMaskCategory.quitCategory.rawValue
    redTarget.physicsBody?.collisionBitMask = BitMaskCategory.floorCategory.rawValue | BitMaskCategory.ballCategory.rawValue
    redTarget.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
    
    let purpleTarget = makeLargeCone()
    purpleTarget.position = SCNVector3(-6,0,-4)
    purpleTarget.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: purpleTarget, options: [SCNPhysicsShape.Option.scale: 0.25]))
    purpleTarget.name = "trainTarget"
    purpleTarget.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
    
    purpleTarget.physicsBody?.categoryBitMask = BitMaskCategory.startTrainingCategory.rawValue
    purpleTarget.physicsBody?.collisionBitMask = BitMaskCategory.floorCategory.rawValue | BitMaskCategory.ballCategory.rawValue
    purpleTarget.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
    
    scene.scene.rootNode.addChildNode(greenTarget)
    scene.scene.rootNode.addChildNode(redTarget)
    scene.scene.rootNode.addChildNode(purpleTarget)

}
