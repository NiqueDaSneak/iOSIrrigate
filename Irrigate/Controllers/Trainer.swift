//
//  startGame.swift
//  Irrigate
//
//  Created by Dom Clemmer on 8/12/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class Trainer {
    
    var onFire:Bool = false
    var shotValue:Int = 0
    var arScene:ARSCNView?
    var finalScore:Int?
    
    func generateTargetCoordinates(sceneNode: ARSCNView) -> SCNVector3 {
        
        let randX = randomBetween(-2.475, 2.475)
        let randY = randomBetween(CGFloat(sceneNode.scene.rootNode.position.y), 1.5) - 0.63
        let randZ = -2.5
        
        return SCNVector3(randX, randY, CGFloat(randZ))
    }
    
    func randomBetween(_ firstNum: CGFloat, _ secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func start(scene: ARSCNView) {

        arScene = scene
        
        scene.scene.rootNode.enumerateChildNodes{ (node,_) in
            if node.name == "disabled" {
                node.removeFromParentNode()
            }
        }
        
        createTarget()
        createTarget()
        createTarget()
        
        createMenuTargets(scene: scene)
    }
        
    func createTarget() {
        let target = makeTarget()
        target.position = generateTargetCoordinates(sceneNode: arScene!)
        target.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: target, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: 0.14]))
        target.name = "target"
        target.geometry?.firstMaterial?.diffuse.contents = UIColor.purple

        target.physicsBody?.categoryBitMask = BitMaskCategory.trainingTargetCategory.rawValue
        target.physicsBody?.collisionBitMask = BitMaskCategory.noCategory.rawValue
        target.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
        
        arScene?.scene.rootNode.addChildNode(target)
    }
    
    func trackShotValue() {
        self.shotValue += 1
        //        print(self.shotValue)
    }
    
    func end() {
        print("inside end training function")
    }
    
    
}

