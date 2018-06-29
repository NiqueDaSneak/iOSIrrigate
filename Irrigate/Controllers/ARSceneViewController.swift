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
    
    let floorCategoryBitMask = 1
    let ballCategoryBitMask = 2
    let startConeCategoryBitMask = 3
    let targetCategoryBitMask = 4
    let powerUpCategoryBitMask = 5
    let noCategoryBitMask = 6
    
//    let ballCollisionMask =

    
    
    // define all scn scene files and the node in file that is the asset
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.scene.physicsWorld.contactDelegate = self as? SCNPhysicsContactDelegate
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
        print("contact")
//        let maskA = contact.nodeA.physicsBody?.categoryBitMask
//        let maskB = contact.nodeB.physicsBody?.categoryBitMask
//
//        // handle starting game
//        if maskA == startConeCategoryBitMask || maskB == startConeCategoryBitMask {
//
//        }
    }

    func addGameWorld(hitTestResult: ARHitTestResult){
        if gameWorldAdded == false {
            let gameScene = SCNScene(named: "art.scnassets/largeCone.scn")
            let coneNode = gameScene?.rootNode.childNode(withName: "LargeCone", recursively: false)
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
            let yCoord = positionOfPlane.x
            let zCoord = positionOfPlane.z
            coneNode?.position = SCNVector3(x: xCoord, y: yCoord, z: zCoord)
//
            coneNode?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: coneNode!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: 0.200]))
            coneNode?.physicsBody?.categoryBitMask = startConeCategoryBitMask
            coneNode?.physicsBody?.collisionBitMask = ballCategoryBitMask | floorCategoryBitMask
            coneNode?.physicsBody?.contactTestBitMask = ballCategoryBitMask
            floorNode.position = SCNVector3(x: xCoord, y: yCoord, z: zCoord)
//            gameNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: gameNode!, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
            
            floorNode.physicsBody = floorPhysicsBody
            floorNode.physicsBody?.categoryBitMask = floorCategoryBitMask
            floorNode.physicsBody?.collisionBitMask = targetCategoryBitMask | ballCategoryBitMask | startConeCategoryBitMask
            floorNode.physicsBody?.contactTestBitMask = noCategoryBitMask
            self.sceneView.scene.rootNode.addChildNode(floorNode)
            self.sceneView.scene.rootNode.addChildNode(coneNode!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                self.gameWorldAdded = true
            }
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
//        // Run the view's session
//        sceneView.session.run(configuration)
//    }
    
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
//        ballNode.position = SCNVector3(x:0, y:0, z: 2 )
        ballNode.geometry = ball
        
//        let ball = SCNNode(geometry: SCNSphere(radius: 0.25))
//        ball.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "ball")
        ballNode.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.11)))
        // Energy lost when two objects collide
        //if val == 1, ball returns back with same speed/energy
        body.restitution = 0.5
        ballNode.physicsBody = body
        ballNode.physicsBody?.categoryBitMask = ballCategoryBitMask
        ballNode.physicsBody?.collisionBitMask = startConeCategoryBitMask | targetCategoryBitMask | floorCategoryBitMask
        ballNode.physicsBody?.contactTestBitMask = startConeCategoryBitMask | targetCategoryBitMask
        
//        ballNode.physicsBody?.collisionBitMask = startConeCategoryBitMask | targetCategoryBitMask | powerUpCategoryBitMask

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
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
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
    // Detect horizontal plane
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
//        if anchor is ARPlaneAnchor {
//            let planeAnchor = anchor as! ARPlaneAnchor
//
//            // Create plane for SceneKit and use planeAnchor values
//            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//
//            // create plane node for placement in scene
//            let planeNode = SCNNode()
//            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
//            // Rotate plane to be horizontal
//            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
//
//            // Overlay for plane
//            let gridMaterial = SCNMaterial()
//            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
//            plane.materials = [gridMaterial]
//
//            planeNode.geometry = plane
//
//            node.addChildNode(planeNode)
//        }
//    }
    
//    func createBall(){
//        let ball = SCNSphere(radius: 0.3)
//        let soccerTexture = SCNMaterial()
//        soccerTexture.diffuse.contents = UIImage(named: "art.scnassets/ball-texture.jpg")
//        ball.materials = [soccerTexture]
//        let ballNode = SCNNode()
//        ballNode.position = SCNVector3(x:0, y:0, z: 2 )
//        ballNode.geometry = ball
//
//        sceneView.scene.rootNode.addChildNode(ballNode)
//    }
    
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

