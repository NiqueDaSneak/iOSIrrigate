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
    let timer = Each(0.05).seconds
    
    let floorCategory = 1
    let ballCategory = 2
    let startConeCategory = 3
    let targetCategory = 4
    let powerUpCategory = 5
    let noCategory = 0
    
    // define all scn scene files and the node in file that is the asset
    
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
//
//        // handle starting game
        if gameStart == false {
            if (maskA == startConeCategory || maskB == startConeCategory) {
                if maskA == startConeCategory {
                    print("nodeA is start cone, begin game: \(String(describing: contact.nodeA.name))")
                    print("nodeB is ball: \(String(describing: contact.nodeB.name))")
                } else {
                    print("nodeb is start cone, begin game: \(String(describing: contact.nodeB.name))")
                    print("nodea is ball: \(String(describing: contact.nodeA.name))")
                }
                gameStart = true
            }
        }
    }

    func addGameWorld(hitTestResult: ARHitTestResult){
        if gameWorldAdded == false {
            let gameScene = SCNScene(named: "art.scnassets/largeCone.scn")
            let coneNode = gameScene?.rootNode.childNode(withName: "LargeCone", recursively: false)
            coneNode?.name = "startCone"
            let floor = SCNFloor()
            floor.reflectivity = 0.1
            let floorTexture = SCNMaterial()
            floorTexture.diffuse.contents = UIColor.green
            floorTexture.transparency = 0.4
            floor.length = 1000
            floor.width = 1000
            let floorNode = SCNNode(geometry: floor)
            let floorPhysicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: SCNBox(width: 100, height: 0.01, length: 1000, chamferRadius: 0)))
            floorPhysicsBody.allowsResting = true
            let positionOfPlane = hitTestResult.worldTransform.columns.3
            let xCoord = positionOfPlane.x
            let yCoord = positionOfPlane.y
            let zCoord = positionOfPlane.z
            coneNode?.position = SCNVector3(x: 1.5, y: yCoord, z: zCoord)
            floorNode.position = SCNVector3(x: xCoord, y: yCoord, z: zCoord)
            floorNode.name = "floor"
            coneNode?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: coneNode!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: 0.200]))
            coneNode?.physicsBody?.categoryBitMask = startConeCategory
            coneNode?.physicsBody?.collisionBitMask = ballCategory | floorCategory
            coneNode?.physicsBody?.contactTestBitMask = ballCategory
            floorNode.position = SCNVector3(x: xCoord, y: yCoord, z: zCoord)
//            gameNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: gameNode!, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
            
            floorNode.physicsBody = floorPhysicsBody
            floorNode.physicsBody?.categoryBitMask = floorCategory
            floorNode.physicsBody?.collisionBitMask = targetCategory | ballCategory | startConeCategory
            floorNode.physicsBody?.contactTestBitMask = noCategory
            self.sceneView.scene.rootNode.addChildNode(floorNode)
            self.sceneView.scene.rootNode.addChildNode(coneNode!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                self.gameWorldAdded = true
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timer.perform(closure: { () -> NextStep in
            self.power = self.power + 1
            return .continue
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.timer.stop()
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
        ballNode.physicsBody?.categoryBitMask = ballCategory
        ballNode.physicsBody?.collisionBitMask = startConeCategory | targetCategory | floorCategory
        ballNode.physicsBody?.contactTestBitMask = startConeCategory | targetCategory

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

