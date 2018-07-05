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
    goalNode?.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0)
//    goalNode?.eulerAngles.x = 45
//    goalNode?.eulerAngles.y = 180
//    goalNode?.scale = SCNVector3(x: 0.3, y: 0.3, z: 0.3)
    goalNode?.position = SCNVector3(x: 0.0, y: -0.4, z: -3.5)
    
    let crossBarNode = goalScene?.rootNode.childNode(withName: "PostsAndCrossbar", recursively: true)
    
    crossBarNode?.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: crossBarNode!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron, SCNPhysicsShape.Option.scale: SCNVector3(0.058, 0.058, 0.058)]))
//    crossBarNode?.physicsBody?.mass = 400.0
//    crossBarNode?.physicsBody?.restitution = 0.8
//    crossBarNode?.physicsBody?.isAffectedByGravity = false
    
    crossBarNode?.physicsBody?.categoryBitMask = BitMaskCategory.crossBarCategory.rawValue
    crossBarNode?.physicsBody?.collisionBitMask = BitMaskCategory.ballCategory.rawValue
    crossBarNode?.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
    
    let netNode = goalScene?.rootNode.childNode(withName: "Net", recursively: true)
    netNode?.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: netNode!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron, SCNPhysicsShape.Option.scale: SCNVector3(1,2.7,0.9)]))
    netNode?.physicsBody?.categoryBitMask = BitMaskCategory.netCategory.rawValue
    netNode?.physicsBody?.collisionBitMask = BitMaskCategory.ballCategory.rawValue
    netNode?.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
    
//    let goalPhysicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: goalNode!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: SCNVector3(0.3, 0.3, 0.3)]))
//    goalPhysicsBody.mass = 400.0
//    goalPhysicsBody.categoryBitMask = BitMaskCategory.targetCategory.rawValue
//    goalPhysicsBody.collisionBitMask = BitMaskCategory.floorCategory.rawValue
//    goalPhysicsBody.contactTestBitMask = BitMaskCategory.noCategory.rawValue
//    goalNode?.physicsBody = goalPhysicsBody
    
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
