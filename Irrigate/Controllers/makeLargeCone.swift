//
//  makeLargeCone.swift
//  Irrigate
//
//  Created by Dom Clemmer on 8/14/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

func makeLargeCone() -> SCNNode {
    
    let targetConeScene = SCNScene(named: "art.scnassets/largeCone.scn")
    let targetNode = targetConeScene?.rootNode.childNode(withName: "LargeCone", recursively: false)
    
    return targetNode!
    
}
