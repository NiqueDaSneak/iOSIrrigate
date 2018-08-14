//
//  startGame.swift
//  Irrigate
//
//  Created by Dom Clemmer on 7/6/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

//import SwiftyTimer
//import Each

class Game {
    
    var howMuchTime:Int = 0
    var score:Int = 0
    var onFire:Bool = false
    var shotValue:Int = 0
    var arScene:ARSCNView?
    var finalScore:Int?

    func countUp(gameStart:Bool) {
        howMuchTime += 1
        print("count up called: \(howMuchTime): \(gameStart)")
        if howMuchTime == 10 && gameStart == true {
            self.end()
        }
    }
    
    func startTimeOver() {
        howMuchTime = 0
    }
    
    func generateTargetCoordinates(sceneNode: ARSCNView) -> SCNVector3 {

        let randX = randomBetween(-2.475, 2.475)
        let randY = randomBetween(CGFloat(sceneNode.scene.rootNode.position.y), 1.5) - 0.63
        let randZ = -2.5
        
        return SCNVector3(randX, randY, CGFloat(randZ))
    }
    
    func randomBetween(_ firstNum: CGFloat, _ secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func setup(scene:ARSCNView) {
//        print("SHOULDNT BE FIRING")
        arScene = scene
//        createTarget(scene: scene)
        let target = makeTarget()
        target.position = generateTargetCoordinates(sceneNode: scene)
        target.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: target, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: 0.14]))
        target.name = "startGameTarget"
        target.physicsBody?.categoryBitMask = BitMaskCategory.targetCategory.rawValue
        target.physicsBody?.collisionBitMask = BitMaskCategory.noCategory.rawValue
        target.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
        
        arScene?.scene.rootNode.addChildNode(target)

    }
    
    func start(scene:ARSCNView) {
//        arScene = scene
        
//        self.startTimeOver()
        score = 0
        print("Start func called")
        print("start adding targets to screen")
        createTarget(scene: scene)
    }
    
    func createTarget(scene: ARSCNView) {
        let target = makeTarget()
        target.position = generateTargetCoordinates(sceneNode: arScene!)
        target.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: target, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: 0.14]))
        target.name = "target"
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
        
        ARSceneViewController().gameStart = false
        
        let childNodes = arScene?.scene.rootNode.childNodes
        
        for node in childNodes! {
            if node.name == "target" {
                node.name = "disabled"
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
                node.physicsBody?.categoryBitMask = BitMaskCategory.disabledTargetCategory.rawValue
                node.physicsBody?.collisionBitMask = BitMaskCategory.ballCategory.rawValue
                node.physicsBody?.contactTestBitMask = BitMaskCategory.noCategory.rawValue
            }
        }
        
//        createMenuTargets(scene: arScene!)
        print("End game")
        
        UserDefaults.standard.set(score, forKey: "currentScore")
        if UserDefaults.standard.integer(forKey: "highScore") < UserDefaults.standard.integer(forKey: "currentScore") {
             UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "currentScore"), forKey: "highScore")
        }
    }
    

}

