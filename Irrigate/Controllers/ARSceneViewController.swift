
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
//import SwiftyTimer

class ARSceneViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var navLabelTop: UILabel!
    @IBOutlet weak var navLabelBottom: UILabel!
    @IBOutlet weak var navMenuButton: UIButton!
    
    var gameStart: Bool = false
    var gameWorldAdded: Bool = false
    var power:Float = 1
    let powerTimer = Each(0.05).seconds
    let newGame = Game()
    var gameTimer = Each(1.00).seconds
    let scoreTimer = Each(0.01).seconds
    var navController:UINavigationController?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        gameTimer.perform(closure: { () -> NextStep in
            self.newGame.countUp(gameStart: self.gameStart)
            return .continue
        })

        
        sceneView.scene.physicsWorld.contactDelegate = self as SCNPhysicsContactDelegate
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, .showPhysicsShapes]
        
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
        
        navLabelTop.text = "Point camera at ground"
        navLabelBottom.text = "to detect playing field"
        
    }
    
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.preferredContentSize = CGSize(width: 300, height: 500)
        navController = UINavigationController(rootViewController: vc)
        navController?.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver = navController?.popoverPresentationController
        popOver?.delegate = self
        navController?.popoverPresentationController?.sourceView = sender
        
        self.present(navController!, animated: true, completion: nil)
    }
    
    func endGameShowPopover() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        navController = UINavigationController(rootViewController: vc)
        navController?.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver = navController?.popoverPresentationController
        popOver?.delegate = self
        navController?.popoverPresentationController?.sourceView = navMenuButton
        
        self.present(navController!, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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

        let maskA = contact.nodeA.physicsBody?.categoryBitMask
        let maskB = contact.nodeB.physicsBody?.categoryBitMask

//        // handle starting game
        if contact.nodeA.parent != nil && contact.nodeB.parent != nil {
            if gameStart == false {
//              FOR STARTING GAME TARGET
                if (maskA == BitMaskCategory.startConeCategory.rawValue || maskB == BitMaskCategory.startConeCategory.rawValue) {
                    gameStart = true
                    
                    self.newGame.start(scene: sceneView)
                    
                    DispatchQueue.main.async {
                        self.addGameStartHeaders()
                    }
                    if maskA == BitMaskCategory.startConeCategory.rawValue {
                        print("nodeA is start cone, begin game: \(String(describing: contact.nodeA.name))")
                        print("nodeB is ball: \(String(describing: contact.nodeB.name))")
                        contact.nodeA.removeFromParentNode()
                    } else {
                        print("nodeB is start cone, begin game: \(String(describing: contact.nodeB.name))")
                        print("nodeA is ball: \(String(describing: contact.nodeA.name))")
                        contact.nodeB.removeFromParentNode()
                    }
                    DispatchQueue.main.async {
                        self.navLabelBottom.text = "Shot Value: 0"
                        self.navLabelTop.text = "Score: 0"
                    }
                }
            }
            
            if contact.nodeA.name == "target" || contact.nodeB.name == "target" {
//              FOR NORMAL TARGETS
                if (maskA == BitMaskCategory.targetCategory.rawValue || maskB == BitMaskCategory.targetCategory.rawValue) {
                    if maskA == BitMaskCategory.targetCategory.rawValue {
                        print("nodeA is a target, track score: \(String(describing: contact.nodeA.name))")
                        print("nodeB is ball: \(String(describing: contact.nodeB.name))")
                        contact.nodeA.removeFromParentNode()
                    } else {
                        print("nodeB is a target, track score: \(String(describing: contact.nodeB.name))")
                        print("nodeA is ball: \(String(describing: contact.nodeA.name))")
                        contact.nodeB.removeFromParentNode()
                    }
                    
                    newGame.createTarget(scene: sceneView)
                    self.scoreTimer.stop()
                    
                    self.newGame.recordHit()
                    
                    // use ui updating function with added params for score
                    DispatchQueue.main.async {
                        self.navLabelBottom.text = "Shot Value: \(self.newGame.shotValue)"
                        self.navLabelTop.text = "Score: \(self.newGame.score)"
                    }
                }
//                FOR STARTING TRAINING
                if (maskA == BitMaskCategory.startTrainingCategory.rawValue || maskB == BitMaskCategory.startTrainingCategory.rawValue) {
                    if maskA == BitMaskCategory.startTrainingCategory.rawValue {
                        print("nodeA is the training cone: \(contact.nodeA.name)")
                        print("nodeB is the ball: \(contact.nodeB.name)")
                        contact.nodeA.removeFromParentNode()
                        
                    } else {
                        print("nodeA is the ball: \(contact.nodeA.name)")
                        print("nodeB is the training cone: \(contact.nodeB.name)")
                        contact.nodeB.removeFromParentNode()
                    }
                    self.sceneView.scene.rootNode.enumerateChildNodes{ (node,_) in
                        if node.name == "target" || node.name == "startCone" {
                            node.removeFromParentNode()
                        }
                    }
                    print("start training")
                }

            }
        }
    }

    func addGameWorld(hitTestResult: ARHitTestResult) {
        if gameWorldAdded == false {

            let floorNode = createFloor()
            
            let positionOfPlane = hitTestResult.worldTransform.columns.3
            let xCoord = positionOfPlane.x
            let yCoord = positionOfPlane.y
            let zCoord = positionOfPlane.z
            
            floorNode.position = SCNVector3(x: xCoord, y: yCoord, z: zCoord)
           
            self.sceneView.scene.rootNode.addChildNode(floorNode)
            let goalNode = placeGoal()
            goalNode.position = SCNVector3(x: 0.0, y: yCoord, z: -3.5)

            sceneView.scene.rootNode.addChildNode(goalNode)

            sceneView.scene.rootNode.addChildNode(makeStartGameCone())
            sceneView.scene.rootNode.addChildNode(makeStartTrainingCone())
            sceneView.scene.rootNode.addChildNode(makeQuitCone())
            
            navLabelTop.text = "Hit first target"
            navLabelBottom.text = "to start game"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                self.gameWorldAdded = true
            }
        }
    }
    
    func makeQuitCone() -> SCNNode {
        let quitCone = makeTarget()
        quitCone.position = SCNVector3(x: 1.0, y: 0, z: -2.5)
        quitCone.name = "target"
        quitCone.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        quitCone.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: quitCone, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: 0.14]))
        
        quitCone.physicsBody?.categoryBitMask = BitMaskCategory.quitCategory.rawValue
        quitCone.physicsBody?.collisionBitMask = BitMaskCategory.noCategory.rawValue
        quitCone.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
        return quitCone
    }
    
    func makeStartTrainingCone() -> SCNNode {
        let trainingCone = makeTarget()
        trainingCone.position = SCNVector3(x: -1.0, y: 0, z: -2.5)
        trainingCone.name = "target"
        
        trainingCone.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
        trainingCone.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: trainingCone, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: 0.14]))
        trainingCone.physicsBody?.categoryBitMask = BitMaskCategory.startTrainingCategory.rawValue
        trainingCone.physicsBody?.collisionBitMask = BitMaskCategory.noCategory.rawValue
        trainingCone.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
        return trainingCone
    }
    
    func makeStartGameCone() -> SCNNode {
        let startCone = makeTarget()
        startCone.position = SCNVector3(x: 0.0, y: 0, z: -2.5)
        startCone.name = "startCone"
        startCone.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        startCone.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: startCone, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull, SCNPhysicsShape.Option.scale: 0.14]))
        
        startCone.physicsBody?.categoryBitMask = BitMaskCategory.startConeCategory.rawValue
        startCone.physicsBody?.collisionBitMask = BitMaskCategory.noCategory.rawValue
        startCone.physicsBody?.contactTestBitMask = BitMaskCategory.ballCategory.rawValue
        return startCone
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
    
    func addGameStartHeaders() {
        navLabelTop.text = "Score: 0"
        navLabelBottom.text = "Shot Value: 0"
    }
    
    func shootball(){
        guard let pointOfView = self.sceneView.pointOfView else {return}
        self.removeBalls()
        if self.power > 15 {
            self.power = 15
        }
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
        ballNode.physicsBody?.collisionBitMask = BitMaskCategory.startConeCategory.rawValue | BitMaskCategory.targetCategory.rawValue | BitMaskCategory.floorCategory.rawValue | BitMaskCategory.crossBarCategory.rawValue | BitMaskCategory.netCategory.rawValue
        ballNode.physicsBody?.contactTestBitMask = BitMaskCategory.startConeCategory.rawValue | BitMaskCategory.targetCategory.rawValue | BitMaskCategory.crossBarCategory.rawValue | BitMaskCategory.netCategory.rawValue

        ballNode.name = "ball"
     
       
        // Provide force to the ball. Setting asImpulse=true gives acceleration to the ball body
        ballNode.physicsBody?.applyForce(SCNVector3(orientation.x * power, orientation.y * power, orientation.z * power), asImpulse: true)
        self.sceneView.scene.rootNode.addChildNode(ballNode)
        
        self.newGame.shotValue = 0
        scoreTimer.perform(closure: { () -> NextStep in
            self.newGame.trackShotValue()
            return .continue
        })
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
            self.navLabelTop.text = "Touch the ground"
            self.navLabelBottom.text = "to place goal"
//            self.planeDetected.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
//            self.planeDetected.isHidden = true
//            self.navLabelTop.text = "Ground detected"
        }
    }

    func updateScore() {
        navLabelTop.text = "Score: \(newGame.score)"
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

