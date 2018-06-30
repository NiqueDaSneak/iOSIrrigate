//
//  ARSceneViewController.swift
//  For Irrigate
//
//  Created by Clemmer, Dom on 6/18/18.
//  Copyright © 2018 IrrigateMsg. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Each

class ARSceneViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate{
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var navLabel: UILabel!
    
    var gameStart: Bool = false
    var gameWorldAdded: Bool = false
    var power:Float = 1
    let powerTimer = Each(0.05).seconds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        sceneView.scene.physicsWorld.contactDelegate = self as SCNPhysicsContactDelegate
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, .showPhysicsShapes]
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.delegate = self
        sceneView.showsStatistics = true

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)

        let tapGesturerecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGesturerecognizer)
        tapGesturerecognizer.cancelsTouchesInView = false
        
    }
    
    @objc func handleTap(sender:UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
        if !hitTestResult.isEmpty{
            self.addGameWorld(hitTestResult: hitTestResult.first!)
            print("the hit test was successful")
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        print("node a: \(contact.nodeA.physicsBody?.categoryBitMask)")
//        print("node b: \(contact.nodeB.physicsBody?.categoryBitMask)")
        let maskA = contact.nodeA.physicsBody?.categoryBitMask
        let maskB = contact.nodeB.physicsBody?.categoryBitMask

//        // handle starting game
        if gameStart == false {
            if (maskA == BitMaskCategory.startConeCategory.rawValue || maskB == BitMaskCategory.startConeCategory.rawValue) {
                if maskA == BitMaskCategory.startConeCategory.rawValue {
                    print("nodeA is start cone, begin game: \(String(describing: contact.nodeA.name))")
                    print("nodeB is ball: \(String(describing: contact.nodeB.name))")
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        contact.nodeA.removeFromParentNode()
                    }
                } else {
                    print("nodeb is start cone, begin game: \(String(describing: contact.nodeB.name))")
                    print("nodea is ball: \(String(describing: contact.nodeA.name))")
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        contact.nodeA.removeFromParentNode()
                    }
                }
                gameStart = true
                
                let goalNode = startGame()
                sceneView.scene.rootNode.addChildNode(startGame())
                
            }
            // FOR NORMAL TARGETS
        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
//                for liveNode in self.sceneView.scene.rootNode.childNodes {
//                if liveNode.name == contact.nodeA.name || liveNode.name == contact.nodeB.name {
//
//                    if (maskA == BitMaskCategory.targetCategory.rawValue || maskB == BitMaskCategory.targetCategory.rawValue) {
//                        if maskA == BitMaskCategory.targetCategory.rawValue {
//                            print("nodeA is target, score increase: \(String(describing: contact.nodeA.name))")
//                            print("nodeB is ball: \(String(describing: contact.nodeB.name))")
//
//                                contact.nodeA.removeFromParentNode()
//
//
//
//                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
//                                let newTarget = createTarget(forStart: false)
//                                newTarget.position = contact.nodeA.position
//                                self.sceneView.scene.rootNode.addChildNode(newTarget)
//                            }
//                        }
//                        } else {
//                            print("nodeb is target, score increase: \(String(describing: contact.nodeB.name))")
//                            print("nodea is ball: \(String(describing: contact.nodeA.name))")
//
//                                contact.nodeB.removeFromParentNode()
//
//                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
//                                let newTarget = createTarget(forStart: false)
//                                newTarget.position = contact.nodeA.position
//                                self.sceneView.scene.rootNode.addChildNode(newTarget)
//                            }
//                        }
//                    }
//                }
//            }
        }
    }

    func addGameWorld(hitTestResult: ARHitTestResult) {
        if gameWorldAdded == false {
//            let gameScene = SCNScene(named: "art.scnassets/largeCone.scn")
            let startConeNode = createTarget(forStart: true)
            let floorNode = createFloor()
            
            let positionOfPlane = hitTestResult.worldTransform.columns.3
            let xCoord = positionOfPlane.x
            let yCoord = positionOfPlane.y
            let zCoord = positionOfPlane.z
            
            startConeNode.position = SCNVector3(x: 0.1, y: yCoord, z: -1)
            floorNode.position = SCNVector3(x: xCoord, y: yCoord, z: zCoord)
           
            self.sceneView.scene.rootNode.addChildNode(floorNode)
            self.sceneView.scene.rootNode.addChildNode(startConeNode)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                self.gameWorldAdded = true
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        powerTimer.perform(closure: { () -> NextStep in
            self.power = self.power + 1
            return .continue
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.powerTimer.stop()
            self.shootball()
        self.power = 1
    }
    
    func addVectors(first:SCNVector3,second:SCNVector3) -> SCNVector3{
        return SCNVector3Make(first.x + second.x, first.y + second.y, first.z + second.z)
    }
    
    func removeBalls(){
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node,_) in
            if node.name == "ball"{
                node.removeFromParentNode()
            }
        }
    }
    
    func shootball(){
        guard let pointOfView = self.sceneView.pointOfView else {return}
        self.removeBalls()
        // self.power = 10
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let position = self.addVectors(first: location, second: orientation)
        
        let ball = SCNSphere(radius: 0.11)
        let soccerTexture = SCNMaterial()
        soccerTexture.diffuse.contents = UIImage(named: "art.scnassets/ball-texture.jpg")
        ball.materials = [soccerTexture]
        let ballNode = SCNNode()
        
        ballNode.geometry = ball

        ballNode.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.11)))
        // Energy lost when two objects collide
        //if val == 1, ball returns back with same speed/energy
        body.restitution = 0.5
        ballNode.physicsBody = body
        ballNode.physicsBody?.categoryBitMask = BitMaskCategory.ballCategory.rawValue
        ballNode.physicsBody?.collisionBitMask = BitMaskCategory.startConeCategory.rawValue | BitMaskCategory.targetCategory.rawValue | BitMaskCategory.floorCategory.rawValue
        ballNode.physicsBody?.contactTestBitMask = BitMaskCategory.startConeCategory.rawValue | BitMaskCategory.targetCategory.rawValue

        ballNode.name = "ball"
     
       
        // Provide force to the ball. Setting asImpulse=true gives acceleration to the ball body
        ballNode.physicsBody?.applyForce(SCNVector3(orientation.x * power, orientation.y * power, orientation.z * power), asImpulse: true)
        self.sceneView.scene.rootNode.addChildNode(ballNode)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            self.navLabel.text = "Touch the ground with dots"
//            self.planeDetected.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
//            self.planeDetected.isHidden = true
            self.navLabel.text = "Ground detected"
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}

