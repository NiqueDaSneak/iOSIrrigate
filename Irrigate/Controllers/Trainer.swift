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
    
    var score:Int = 0
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
        
        print("Start trainer func called")
        print("trainer adding targets to screen")
        createTarget()
        createTarget()
        createTarget()
        createTarget()
        
        createMenuTargets()
    }
    
    func createMenuTargets() {
        let greenTarget = makeLargeCone()
        greenTarget.position = SCNVector3(0,(arScene?.scene.rootNode.position.y)!,5)
        greenTarget.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: greenTarget, options: [SCNPhysicsShape.Option.scale: 0.135]))
        greenTarget.name = "startCone"
        greenTarget.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        
        greenTarget.physicsBody?.categoryBitMask = BitMaskCategory.startConeCategory.rawValue
        greenTarget.physicsBody?.collisionBitMask = BitMaskCategory.floorCategory.rawValue | BitMaskCategory.ballCategory.rawValue
        greenTarget.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
        
        arScene?.scene.rootNode.addChildNode(greenTarget)
        
        let redTarget = makeLargeCone()
        redTarget.position = SCNVector3(1,(arScene?.scene.rootNode.position.y)!,5)
        redTarget.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: greenTarget, options: [SCNPhysicsShape.Option.scale: 0.135]))
        redTarget.name = "target"
        redTarget.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        
        redTarget.physicsBody?.categoryBitMask = BitMaskCategory.quitCategory.rawValue
        redTarget.physicsBody?.collisionBitMask = BitMaskCategory.floorCategory.rawValue | BitMaskCategory.ballCategory.rawValue
        redTarget.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
        
        arScene?.scene.rootNode.addChildNode(redTarget)


        
    }
    
    func createTarget() {
        let target = makeTarget()
        target.position = generateTargetCoordinates(sceneNode: arScene!)
        target.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: target, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: 0.14]))
        target.name = "target"
        target.geometry?.firstMaterial?.diffuse.contents = UIColor.purple

        target.physicsBody?.categoryBitMask = BitMaskCategory.targetCategory.rawValue
        target.physicsBody?.collisionBitMask = BitMaskCategory.noCategory.rawValue
        target.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
        
        arScene?.scene.rootNode.addChildNode(target)
    }
    
    func trackShotValue() {
        self.shotValue += 1
        //        print(self.shotValue)
    }
    
    func recordHit() {
        print("Target hit for \(self.shotValue) points!")
        self.score = self.score + self.shotValue
    }
    
    func end() {
        print("inside end training function")
    }
    
    
}

