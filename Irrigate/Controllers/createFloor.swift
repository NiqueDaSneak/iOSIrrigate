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
    floor.reflectivity = 0
    let floorTexture = SCNMaterial()
    floorTexture.transparency = 1
    floorTexture.diffuse.contents = hexStringToUIColor(hex: "#7cfc00")
    
    floor.materials = [floorTexture]
    
    floor.length = 1000
    floor.width = 1000
    let floorNode = SCNNode(geometry: floor)
    let floorPhysicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: SCNBox(width: 100, height: 0.01, length: 1000, chamferRadius: 0)))
    floorPhysicsBody.allowsResting = true
    
    floorNode.name = "floor"
    
    floorNode.physicsBody = floorPhysicsBody
    floorNode.physicsBody?.categoryBitMask = BitMaskCategory.floorCategory.rawValue
    floorNode.physicsBody?.collisionBitMask = BitMaskCategory.targetCategory.rawValue | BitMaskCategory.ballCategory.rawValue | BitMaskCategory.startConeCategory.rawValue | BitMaskCategory.trainingTargetCategory.rawValue
    floorNode.physicsBody?.contactTestBitMask = BitMaskCategory.noCategory.rawValue
    
    return floorNode
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
