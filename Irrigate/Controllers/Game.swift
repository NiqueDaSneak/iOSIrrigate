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

    func countUp() {
        howMuchTime += 1
//        print("count up called: \(howMuchTime)")
        if howMuchTime == 60 {
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
    
    func start(scene: ARSCNView) {
        
        self.startTimeOver()
        print("Start func called")
        print("start adding targets to screen")
        createTarget(scene: scene)
    }
    
    func createTarget(scene: ARSCNView) {
        let sceneView = scene
        
        let target = makeTarget()
        target.position = generateTargetCoordinates(sceneNode: sceneView)
        target.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: target, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: 0.14]))
        target.name = "target"
        target.physicsBody?.categoryBitMask = BitMaskCategory.targetCategory.rawValue
        target.physicsBody?.collisionBitMask = BitMaskCategory.noCategory.rawValue
        target.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
        
        sceneView.scene.rootNode.addChildNode(target)
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
        print("End game")
    }
    

}

