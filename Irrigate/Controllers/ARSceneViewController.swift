
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
    @IBOutlet weak var ret: UIImageView!
    
    var gameStart:Bool = false
    var isTraining:Bool = false
    var gameWorldAdded: Bool = false
    var power:Float = 1
    let powerTimer = Each(0.05).seconds
    let newGame = Game()
    let trainer = Trainer()
    var gameTimer = Each(1.00).seconds
    let scoreTimer = Each(0.01).seconds
    var navController:UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        hideReticle()
//        ret.isHidden = true

        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
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
        
        // below line prevents rest from firing multiple times for one collision
        if contact.nodeA.parent != nil && contact.nodeB.parent != nil {
            
            // begin training
            if (maskA == BitMaskCategory.startTrainingCategory.rawValue || maskB == BitMaskCategory.startTrainingCategory.rawValue) {
                if self.isTraining == false {
                    self.isTraining = true
                    DispatchQueue.main.async {
                        self.ret.isHidden = false
                    }
                    self.scoreTimer.stop()
                    
                    if maskA == BitMaskCategory.startTrainingCategory.rawValue {
                        contact.nodeA.removeFromParentNode()
                        
                    } else {
                        contact.nodeB.removeFromParentNode()
                    }
                    
                    self.sceneView.scene.rootNode.enumerateChildNodes{ (node,_) in
                        if node.name == "target" || node.name == "setUpGameCone" {
                            node.removeFromParentNode()
                        }
                    }
                    
                    self.trainer.start(scene: sceneView)
                    print("start training")
                    
                    DispatchQueue.main.async {
                        self.navLabelTop.text = "Hit green to play"
                        self.navLabelBottom.text = "Hit purple to train"
                    }
                }
                
            }
            
            // respond to training targets
            if (maskA == BitMaskCategory.trainingTargetCategory.rawValue || maskB == BitMaskCategory.trainingTargetCategory.rawValue) {
                if maskA == BitMaskCategory.trainingTargetCategory.rawValue {
                    contact.nodeA.removeFromParentNode()
                } else {
                    contact.nodeB.removeFromParentNode()
                }
                self.scoreTimer.stop()
                self.trainer.createTarget()
            }
            
            // quit game
            if (maskA == BitMaskCategory.quitCategory.rawValue || maskB == BitMaskCategory.quitCategory.rawValue) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                    self.performSegue(withIdentifier: "quitGame", sender: self)
                    self.gameTimer.stop()
                }
            }
            
            // setup gameplay
            if (maskA == BitMaskCategory.startConeCategory.rawValue || maskB == BitMaskCategory.startConeCategory.rawValue) {

                self.isTraining = false
                self.sceneView.scene.rootNode.enumerateChildNodes{ (node,_) in
                    if node.name == "target" || node.name == "startCone" || node.name == "setUpGameCone" || node.name == "disabled" {
                        node.removeFromParentNode()
                    }
                }
                createMenuTargets(scene: sceneView)
                self.newGame.setup(scene: sceneView, sender: self)
                
                DispatchQueue.main.async {
                    self.ret.isHidden = true
                }
                
                DispatchQueue.main.async {
                    self.navLabelTop.text = "Hit first target"
                    self.navLabelBottom.text = "to start game"
                }
            }
            
            // detect game target being hit
            if (maskA == BitMaskCategory.targetCategory.rawValue || maskB == BitMaskCategory.targetCategory.rawValue) {
                print("\(gameStart)")
                if gameStart == false {
                    gameStart = true
                    newGame.restart(scene: sceneView)
                } else {
                    newGame.createTarget(scene: sceneView)
                }
                if maskA == BitMaskCategory.targetCategory.rawValue {
                    print("nodeA is a target, track score: \(String(describing: contact.nodeA.name))")
                    print("nodeB is ball: \(String(describing: contact.nodeB.name))")
                    contact.nodeA.removeFromParentNode()
                } else {
                    print("nodeB is a target, track score: \(String(describing: contact.nodeB.name))")
                    print("nodeA is ball: \(String(describing: contact.nodeA.name))")
                    contact.nodeB.removeFromParentNode()
                }
                
                self.scoreTimer.stop()
                newGame.recordHit()
                // use ui updating function with added params for score
                DispatchQueue.main.async {
                    self.navLabelTop.text = "Score: \(self.newGame.score)"
                    self.navLabelBottom.text = "Shot Value: \(self.newGame.shotValue)"
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

            sceneView.scene.rootNode.addChildNode(makeSetupGameCone())
            sceneView.scene.rootNode.addChildNode(makeStartTrainingCone())
            sceneView.scene.rootNode.addChildNode(makeQuitCone())
            
            navLabelTop.text = "Choose a target"
            navLabelBottom.text = "Tap help for meaning"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                self.gameWorldAdded = true
            }
        }
    }
    
//    func showReticle() {
//            ret.isHidden = false
//    }
//    
//    func hideReticle() {
//            ret!.isHidden = true
//    }
    
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
    
    func makeSetupGameCone() -> SCNNode {
        let startCone = makeTarget()
        startCone.position = SCNVector3(x: 0.0, y: 0, z: -2.5)
        startCone.name = "setUpGameCone"
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
        DispatchQueue.main.async {
            self.navLabelTop.text = "Score: 0"
            self.navLabelBottom.text = "Shot Value: 0"
        }
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
        ballNode.physicsBody?.collisionBitMask = BitMaskCategory.startConeCategory.rawValue | BitMaskCategory.targetCategory.rawValue | BitMaskCategory.floorCategory.rawValue | BitMaskCategory.crossBarCategory.rawValue | BitMaskCategory.netCategory.rawValue | BitMaskCategory.quitCategory.rawValue
        ballNode.physicsBody?.contactTestBitMask = BitMaskCategory.startConeCategory.rawValue | BitMaskCategory.targetCategory.rawValue | BitMaskCategory.crossBarCategory.rawValue | BitMaskCategory.netCategory.rawValue | BitMaskCategory.quitCategory.rawValue

        ballNode.name = "ball"
     
        // Provide force to the ball. Setting asImpulse=true gives acceleration to the ball body
        ballNode.physicsBody?.applyForce(SCNVector3(orientation.x * power, orientation.y * power, orientation.z * power), asImpulse: true)
        self.sceneView.scene.rootNode.addChildNode(ballNode)
        
        self.newGame.shotValue = 0
        scoreTimer.perform(closure: { () -> NextStep in
            if self.isTraining == true {
                self.trainer.trackShotValue()
                return .continue
            } else {
                self.newGame.trackShotValue()
                return .continue
            }
            
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
            if self.gameWorldAdded == false {
                self.navLabelTop.text = "Touch the ground"
                self.navLabelBottom.text = "to place goal"
            }
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

