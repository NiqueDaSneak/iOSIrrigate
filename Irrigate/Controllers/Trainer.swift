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
        createTarget(scene: scene)
        createTarget(scene: scene)
        createTarget(scene: scene)
        createTarget(scene: scene)

    }
    
    func createTarget(scene: ARSCNView) {
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
//        //        PopOverViewController().gameScore = score
//        //        print("PopOverViewController().gameScore: \(PopOverViewController().gameScore)")
//        //        print("Real Score: \(score)")
//        //        PopOverViewController().setScore(score: score)
//        let childNodes = arScene?.scene.rootNode.childNodes
//        
//        for node in childNodes! {
//            if node.name == "target" {
//                node.name = "disabled"
//                node.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
//                node.physicsBody?.collisionBitMask = BitMaskCategory.ballCategory.rawValue
//                node.physicsBody?.contactTestBitMask = BitMaskCategory.noCategory.rawValue
//            }
//            // change the nodes so that the collision detection and such are no longer functional
//            
//            // perhaps just remove them
//        }
//        
//        // loadGameOverview(finalScore: score, username: session.username???)
//        print("End game")
//        
//        UserDefaults.standard.set(score, forKey: "currentScore")
//        if UserDefaults.standard.integer(forKey: "highScore") < UserDefaults.standard.integer(forKey: "currentScore") {
//            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "currentScore"), forKey: "highScore")
//        }
    }
    
    
}

