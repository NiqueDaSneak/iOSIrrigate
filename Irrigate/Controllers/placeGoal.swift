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

func placeGoal() -> SCNNode {
    
    
    let goalScene = SCNScene(named: "art.scnassets/goal.scn")
    let goalNode = goalScene?.rootNode.childNode(withName: "goal", recursively: false)
    goalNode?.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0)
    
    let crossBarNode = goalScene?.rootNode.childNode(withName: "PostsAndCrossbar", recursively: true)
    
    crossBarNode?.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: crossBarNode!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron, SCNPhysicsShape.Option.scale: SCNVector3(0.058, 0.058, 0.058)]))

    crossBarNode?.physicsBody?.restitution = 0.8
    
    crossBarNode?.physicsBody?.categoryBitMask = BitMaskCategory.crossBarCategory.rawValue
    crossBarNode?.physicsBody?.collisionBitMask = BitMaskCategory.ballCategory.rawValue
    crossBarNode?.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
    
    let netNode = goalScene?.rootNode.childNode(withName: "Net", recursively: true)
    netNode?.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: netNode!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron, SCNPhysicsShape.Option.scale: SCNVector3(1,2.7,0.9)]))
    netNode?.physicsBody?.categoryBitMask = BitMaskCategory.netCategory.rawValue
    netNode?.physicsBody?.collisionBitMask = BitMaskCategory.ballCategory.rawValue
    netNode?.physicsBody?.contactTestBitMask = BitMaskCategory.noCategory.rawValue
  
    return goalNode!
  
}
