//
//  GameViewController.swift
//  Breakout
//
//  Created by Albertino Padin on 10/26/14.
//  Copyright (c) 2014 Albertino Padin. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import AVFoundation
import AudioToolbox
import SpriteKit

class GameViewController: UIViewController, SCNPhysicsContactDelegate, UIGestureRecognizerDelegate
{
    let ballNode = Ball.createBall()
    let paddleNode = Paddle.createPaddle()
    
    // Ball bounds
    let maxX = 50.0
    let minX = -10.0
    let maxY = 40.0
    let minY = -10.0
    
    // Ball speed
    var vectorX = 25.0
    var vectorY = 25.0
    
    let soundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tock", ofType: "caf")!)
//    var audioPlayer = AVAudioPlayer()
    var tockSound: SystemSoundID = 0
    
    let initialPaddlePosition = 24.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.dae")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        
        // animate the 3d object
        ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
    
        */
        
        // --- TINO ADDED --- //
        
        let scene = SCNScene()
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor(white: 0.67, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = SCNLightTypeOmni
        omniLightNode.light!.color = UIColor(white: 0.75, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 50, 50)
        scene.rootNode.addChildNode(omniLightNode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(30, 0, 90)
        scene.rootNode.addChildNode(cameraNode)
        
        // --- TINO ADDED --- //
        

        // retrieve the SCNView
        let scnView = self.view as SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // Set gravity to zero and create level
        scnView.scene!.physicsWorld.gravity = SCNVector3(x: 0, y: 0, z: 0)
        scnView.scene!.rootNode.addChildNode(Level.createLevel())
        
        
        // Adding paddle
        paddleNode.position = SCNVector3Make(+24, -10, 0)
        scnView.scene!.rootNode.addChildNode(paddleNode)
        
        ballNode.position = SCNVector3Make(+8, -4, 0)
        scnView.scene!.rootNode.addChildNode(ballNode)
        
        scnView.scene!.physicsWorld.contactDelegate = self;
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true

        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapGesture.delegate = self
        let gestureRecognizers = NSMutableArray()
        gestureRecognizers.addObject(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        panGesture.delegate = self
        gestureRecognizers.addObject(panGesture)
        
        
        // Removing default gesture recognizers
        scnView.gestureRecognizers = gestureRecognizers
        
        
        AudioServicesCreateSystemSoundID(soundURL, &tockSound)
        
        //ballNode.physicsBody!.velocity = SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0)
        
        // Game Loop
        let gameLoop = CADisplayLink(target: self, selector: "gameLoop")
        gameLoop.frameInterval = 1
        gameLoop.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
    }
    
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact)
    {
        //println("CONTACT!")
        //println("Ball position x coord: \(ballNode.presentationNode().position.x)")
        
        if contact.contactNormal.x < 0.5 && contact.contactNormal.x > -0.5
        {
            vectorY *= -1
        }
        
        if contact.contactNormal.y < 0.5 && contact.contactNormal.y > -0.5
        {
            vectorX *= -1
        }
        
        ballNode.physicsBody!.velocity = SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0)
        //ballNode.physicsBody!.applyForce(SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0), impulse: true)
        AudioServicesPlaySystemSound(tockSound)
        
        if contact.nodeA != ballNode && contact.nodeA != paddleNode
        {
            // Is a block
            contact.nodeA.removeFromParentNode()
        }
        
        if contact.nodeB != ballNode && contact.nodeB != paddleNode
        {
            contact.nodeB.removeFromParentNode()
        }
    }
    
    
    func gameLoop()
    {
        //println("ballNode.position.y = \(ballNode.position.y)")
        //println("ballNode.presentationNode().position.y = \(ballNode.presentationNode().position.y)")
        
        if (ballNode.presentationNode().position.x >= Float(maxX) && vectorX > 0) ||
            (ballNode.presentationNode().position.x <= Float(minX) && vectorX < 0)
        {
            vectorX *= -1
            
            let randVal = (Float(arc4random_uniform(5)) - 2.5)/10   // Random value between -0.25 and + 0.25
            vectorX += Double(randVal)
            
//            println("New vectorX: \(vectorX)")
            
            // Sound
            AudioServicesPlaySystemSound(tockSound)
        }
        
        if (ballNode.presentationNode().position.y >= Float(maxY) && vectorY > 0) ||
            (ballNode.presentationNode().position.y <= Float(minY) && vectorY < 0)
        {
            vectorY *= -1
            
            let randVal = (Float(arc4random_uniform(5)) - 2.5)/10   // Random value between -0.25 and + 0.25
            vectorY += Double(randVal)

//            println("New vectorY: \(vectorY)")
            
            // Sound
            AudioServicesPlaySystemSound(tockSound)
        }
        
        // To make sure ball doesn't get stuck in an infinite vertical or horizontal movement
        if (vectorX < 0.09 && vectorX > -0.09)
        {
            vectorX += 0.20
        }
        
        if (vectorY < 0.09 && vectorY > -0.09)
        {
            vectorY += 0.20
        }
        
//        var ballMoveAnimation = CABasicAnimation(keyPath: "position")
//        ballMoveAnimation.fromValue = NSValue(SCNVector3: ballNode.position)
//        ballMoveAnimation.toValue = NSValue(SCNVector3: SCNVector3Make(ballNode.position.x + Float(vectorX),
//                                                                       ballNode.position.y + Float(vectorY),
//                                                                       ballNode.position.z))
//        ballMoveAnimation.duration = 1
//        ballNode.position.x += Float(vectorX)
//        ballNode.position.y += Float(vectorY)
//        ballNode.addAnimation(ballMoveAnimation, forKey: "ballMove")
        
        
        ballNode.physicsBody!.velocity = SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0)
        //ballNode.physicsBody!.applyForce(SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0), impulse: true)
    }
    
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        if let hitResults = scnView.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
                
                // get its material
                let material = result.node!.geometry!.firstMaterial!
                
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                // on completion - unhighlight
                SCNTransaction.setCompletionBlock {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                    
                    material.emission.contents = UIColor.blackColor()
                    
                    SCNTransaction.commit()
                }
                
                material.emission.contents = UIColor.redColor()
                
                SCNTransaction.commit()
            }
        }
    }
    
    
    // Move Paddle!
    func handlePanGesture(gestureRecognize: UIGestureRecognizer)
    {
        let scnView = self.view as SCNView
        
        let panRecognizer = gestureRecognize as UIPanGestureRecognizer
        
        let translation = panRecognizer.translationInView(scnView)
        
        println("Translation.x (raw): \(translation)")
        
        let convertedTranslation = scnView.unprojectPoint(SCNVector3Make(Float(translation.x), Float(translation.y), 1.0))
        
        let xSceneTranslation = convertedTranslation.x
        paddleNode.position.x = xSceneTranslation + Float(initialPaddlePosition)
        
        println("xSceneTranslation: \(xSceneTranslation)")
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
