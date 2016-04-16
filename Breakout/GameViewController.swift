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
    var gameRunning = false
    var _gameLoop: CADisplayLink? = nil
    
    var walls = SCNNode()
    var blocks = SCNNode()
//    var ballNode = Ball.createBall()
    var ball = Ball()
    let paddleNode = Paddle.createPaddle()
    
    var score = 0
    var scoreLabel = SKLabelNode(fontNamed: "San Francisco")
    
    // Ball bounds
//    let maxX = 50.0
//    let minX = 0.0
//    let maxY = 45.0
    let minY = -25.0
    
    // Ball speed
    var vectorX = 25.0
    var vectorY = 25.0
    
    let musicURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("MarbleZone", ofType: "mp3")!)
    var musicAudioPlayer = AVAudioPlayer()
    
    
    let soundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tock", ofType: "caf")!)
    var tockSound: SystemSoundID = 0
    
    var initialPaddlePosition: Float = 24.0    // Paddle starts at x = 24
    
    var ballHasFallenOff = false    // Use this to let the game loop know to not keep adding velocity vector to regenerated ball
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        cameraNode.position = SCNVector3Make(25, 0, 80)
        scene.rootNode.addChildNode(cameraNode)
        
        // --- TINO ADDED --- //
        

        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.text = String(score)
        scoreLabel.setScale(1.0)
        scoreLabel.position = CGPoint(x: 20, y: 40)
        
        scnView.overlaySKScene = SKScene(size: scnView.bounds.size)
//        scnView.overlaySKScene?.setScale(0.1)
//        scnView.overlaySKScene?.position = CGPoint(x: 10, y: 10)
        scnView.overlaySKScene?.addChild(scoreLabel)
        
        
        // set the scene to the view
        scnView.scene = scene
        //scnView.delegate = self // Implement update method
        
        // Set gravity to zero and create level
        scnView.scene!.physicsWorld.gravity = SCNVector3(x: 0, y: 0, z: 0)
        
        // Add blocks and walls
        self.instantiateLevel()
        
//        let levelAndWalls = Level.createLevel()
//        blocks = levelAndWalls.blocks
//        walls = levelAndWalls.walls
//        scnView.scene!.rootNode.addChildNode(levelAndWalls.levelNode)
        
        
        // Adding paddle
        paddleNode.position = SCNVector3Make(+24, -15, 0)
        scnView.scene!.rootNode.addChildNode(paddleNode)
        
        ball.setPositionVector(SCNVector3Make(+8, -4, 0))
        scnView.scene!.rootNode.addChildNode(ball.ballNode)
        scnView.scene!.physicsWorld.contactDelegate = self;
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true

        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        var gestureRecognizers:[UIGestureRecognizer] = []
        gestureRecognizers.append(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        gestureRecognizers.append(panGesture)
        
        // Double tap for pause game:
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(pauseAndResumeGame))
        doubleTapGesture.delegate = self
        doubleTapGesture.numberOfTapsRequired = 2
        gestureRecognizers.append(doubleTapGesture)
        
        
        // Removing default gesture recognizers
        scnView.gestureRecognizers = gestureRecognizers
        
        AudioServicesCreateSystemSoundID(soundURL, &tockSound)
        
        //ballNode.physicsBody!.velocity = SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0)
        
        
        // Start music
        musicAudioPlayer = try! AVAudioPlayer(contentsOfURL: musicURL)
        musicAudioPlayer.numberOfLoops = -1     // Infinite loop
        musicAudioPlayer.prepareToPlay()
        musicAudioPlayer.play()
        
        
        // Game Loop
        self._gameLoop = CADisplayLink(target: self, selector: #selector(gameLoop))
        self._gameLoop!.frameInterval = 1
        self._gameLoop!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        self.gameRunning = true     // Consider placing this inside the game loop perhaps?
        
    }
    
    func instantiateLevel()
    {
        let scnView = view as! SCNView
        
        let levelAndWalls = Level.createLevel()
        
        if walls.childNodes.count == 0
        {
            walls = levelAndWalls.walls
            scnView.scene!.rootNode.addChildNode(walls)
        }
        
        blocks = levelAndWalls.blocks
        scnView.scene!.rootNode.addChildNode(blocks)
    }
    
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact)
//    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact)
    {
//        print("CONTACT!")
        //println("Ball position x coord: \(ballNode.presentationNode().position.x)")
        
        //println("ContactNormal: x: \(contact.contactNormal.x), y: \(contact.contactNormal.y)")
        
        
//        let closure = { (nodeToTest: SCNNode, allWalls: SCNNode) -> Bool in
//            for node in allWalls.childNodes
//            {
//                if nodeToTest == node 
//                {
//                    return true
//                }
//            }
//            
//            return false    // nodeToTest isn't a wall.
//        }
        
        
//        if (contact.nodeA == paddleNode && closure(contact.nodeB, walls)) ||
//            (closure(contact.nodeA, walls) && contact.nodeB == paddleNode)
        if (contact.nodeA == paddleNode && contact.nodeB.name == "Wall") ||
            (contact.nodeA.name == "Wall" && contact.nodeB == paddleNode)
        {
            // Don't change ball's motion
//            print("PADDLE WALL CONTACT")
        }
        else if !ballHasFallenOff
        {
            // contactNormal is a unitary vector, so when it is at 45 degrees to the horizon (corner contact),
            // it will satisfy the equation 1 = x^2 + y^2, with x = y = sqrt(0.5)
            if contact.contactNormal.x <= sqrt(0.5) && contact.contactNormal.x >= -sqrt(0.5)
            {
                vectorY *= -1
            }
            
            if contact.contactNormal.y <= sqrt(0.5) && contact.contactNormal.y >= -sqrt(0.5)
            {
                vectorX *= -1
            }
            
            ball.setVelocityVector(SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0))
            //ballNode.physicsBody!.applyForce(SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0), impulse: true)
            AudioServicesPlaySystemSound(tockSound)
            
            if contact.nodeA != ball.ballNode && contact.nodeA != paddleNode && contact.nodeA.name != "Wall"
            {
                // Is a block
                contact.nodeA.removeFromParentNode()
                score += 1
                scoreLabel.text = String(score)
            }
            
            if contact.nodeB != ball.ballNode && contact.nodeB != paddleNode && contact.nodeB.name != "Wall"
            {
                // Is a block
                contact.nodeB.removeFromParentNode()
                score += 1
                scoreLabel.text = String(score)
            }
            
            print("Score: \(score)")
            print("ScoreLabel.text: \(scoreLabel.text)")
            
            // Check to see if there are no more blocks:
            if blocks.childNodes.count == 0
            {
                // Add blocks again
                instantiateLevel()
            }
        }
    }
    
    
    
    func gameLoop()
    {
        print("ball.position.x = \(self.ball.getPositionVector().x)")
        print("ball.presentationNode.position.x = \(self.ball.ballNode.presentationNode.position.x)")
        print("ball.position.y = \(self.ball.getPositionVector().y)")
        print("ball.presentationNode.position.y = \(self.ball.ballNode.presentationNode.position.y)")
        
        if !ballHasFallenOff
        {
            if (self.ball.ballNode.presentationNode.position.y <= Float(minY) && vectorY < 0)
            {
                // Regenerate ball on top of paddle:
                ballHasFallenOff = true
                self.ball.ballNode.removeFromParentNode()
                self.ball.setPositionVector(SCNVector3Make(paddleNode.position.x + 1, paddleNode.position.y + 2, 0))
                self.ball.setVelocityVector(SCNVector3Make(0, 0, 0))
                let scnView = self.view as! SCNView
                scnView.scene!.rootNode.addChildNode(self.ball.ballNode)
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
            
            print("Vector X: \(vectorX)")
            print("Vector Y:\(vectorY)")
            print("Ball node velocity before update: \(ball.getVelocityVector())")
            
            ball.setVelocityVector(SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0))
            //ballNode.physicsBody!.applyForce(SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0), impulse: true)
            
            print("Ball node velocity after update: \(ball.getVelocityVector())")
        }
        else
        {
            // Set ball on top of paddle
            ball.setVelocityVector(SCNVector3Make(0, 0, 0))
            ball.setPositionVector(SCNVector3Make(paddleNode.position.x + 1, paddleNode.position.y + 2, 0))
        }
        
    }
    
    
    func pauseAndResumeGame(gestureRecognizer: UIGestureRecognizer) {
        
        if(self.gameRunning)
        {
            self.musicAudioPlayer.pause()
            self._gameLoop!.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            self.ball.setVelocityVector(SCNVector3Make(0, 0, 0))
            self.gameRunning = false
        }
        else
        {
            self.musicAudioPlayer.prepareToPlay()
            self._gameLoop!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            self.musicAudioPlayer.play()
            self.ball.setVelocityVector(SCNVector3Make(Float(self.vectorX), Float(self.vectorY), 0)) // Save the Velocity vector
            self.gameRunning = true
        }
        
    }
    
    
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        
        if ballHasFallenOff
        {
            ballHasFallenOff = false // Start ball moving again
        }
        
        // Below code is from default starting example:
        /*
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        let hitResults = scnView.hitTest(p, options: nil)
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
            SCNTransaction.setCompletionBlock
            {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.redColor()
            
            SCNTransaction.commit()
        }
        */
        
    }
    
    
    // Move Paddle!
    func handlePan(gestureRecognizer: UIGestureRecognizer)
    {
        let scnView = self.view as! SCNView
        
        let panRecognizer = gestureRecognizer as! UIPanGestureRecognizer
        
        let translation = panRecognizer.translationInView(scnView)
        
        //println("Translation.x (raw): \(translation)")
        
        // Using uproject point to go from 2D View coordinated to the actual 3D scene coordinates.
        let convertedTranslation = scnView.unprojectPoint(SCNVector3Make(Float(translation.x), Float(translation.y), 1.0))
        
        var xSceneTranslation = convertedTranslation.x
        
        
        // This discrepancy probably has to do with the different screen scales
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        {
            // WTF?
            // The converted translation is more negative than it should be
            xSceneTranslation += 16.5
        }
        else
        {
            xSceneTranslation += 7.5
        }
        
        // Limits of paddle motion
        if self.paddleNode.position.x <= 3 && initialPaddlePosition + xSceneTranslation < 3  // Don't move further to the left
        {
            self.paddleNode.position.x = 3
        }
        else if self.paddleNode.position.x >= 47 && initialPaddlePosition + xSceneTranslation > 47 // Don't move further to the right
        {
            self.paddleNode.position.x = 47
        }
        else
        {
            self.paddleNode.position.x = xSceneTranslation + initialPaddlePosition
        }
        
        
        if panRecognizer.state == UIGestureRecognizerState.Ended || panRecognizer.state == UIGestureRecognizerState.Cancelled
        {
            initialPaddlePosition = self.paddleNode.presentationNode.position.x
        }
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
