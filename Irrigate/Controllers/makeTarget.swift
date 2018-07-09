//
//  placeStartTarget.swift
//  Irrigate
//
//  Created by Dom Clemmer on 7/5/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

func makeTarget() -> SCNNode {
    
    let targetConeScene = SCNScene(named: "art.scnassets/smallCone.scn")
    let targetNode = targetConeScene?.rootNode.childNode(withName: "SmallCone", recursively: false)
    
    return targetNode!
    
}
