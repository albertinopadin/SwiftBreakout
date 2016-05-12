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
    var ball = Ball()
    let paddleNode = Paddle(color: UIColor.whiteColor())
    
    var score = 0
    var scoreLabel = SKLabelNode(fontNamed: "San Francisco")
    
    var previousContactNodes = Array<SCNNode>()
    
    // Ball bounds
//    let maxX = 50.0
//    let minX = 0.0
//    let maxY = 45.0
    let minY = -45.0
    
    // Ball speed
    let defaultVectorX = 25.0
    let defaultVectorY = 25.0
    
    var vectorX: Double = 25.0
    var vectorY: Double = 25.0
    
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
        scnView.overlaySKScene?.addChild(scoreLabel)
        
        
        // set the scene to the view
        scnView.scene = scene
        //scnView.delegate = self // Implement update method
        
        // Set gravity to zero and create level
        scnView.scene!.physicsWorld.gravity = SCNVector3(x: 0, y: 0, z: 0)
        
        // Add blocks and walls
        self.instantiateLevel()
        
        
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
        
        
        var gestureRecognizers:[UIGestureRecognizer] = []
        
        createAndAddGestureRecognizer(UITapGestureRecognizer.self,
                                      action: #selector(handleTap),
                                      numOfTapsRequired: 1,
                                      recognizerArray: &gestureRecognizers)
        
        createAndAddGestureRecognizer(UIPanGestureRecognizer.self,
                                      action: #selector(handlePan),
                                      numOfTapsRequired: nil,
                                      recognizerArray: &gestureRecognizers)
        
        createAndAddGestureRecognizer(UITapGestureRecognizer.self,
                                      action: #selector(pauseAndResumeGame),
                                      numOfTapsRequired: 2,
                                      recognizerArray: &gestureRecognizers)
        
        
        // Removing default gesture recognizers
        scnView.gestureRecognizers = gestureRecognizers
        
        AudioServicesCreateSystemSoundID(soundURL, &tockSound)
        
        // Start music
        startMusicPlayer()
        
        // Game Loop
        startGameLoop()
    }
    
    
    func createAndAddGestureRecognizer(recognizerType: UIGestureRecognizer.Type,
                                       action: Selector,
                                       numOfTapsRequired: Int?,
                                       inout recognizerArray: [UIGestureRecognizer])
    {
        let gestureRecognizer = recognizerType.init(target: self, action: action)
        gestureRecognizer.delegate = self
        
        if let gr = gestureRecognizer as? UITapGestureRecognizer
        {
            gr.numberOfTapsRequired = numOfTapsRequired!
        }
        
        recognizerArray.append(gestureRecognizer)
    }
    
    
    func startGameLoop()
    {
        self.vectorX = defaultVectorX
        self.vectorY = defaultVectorY
        
        self._gameLoop = CADisplayLink(target: self, selector: #selector(gameLoop))
        self._gameLoop!.frameInterval = 1
        self._gameLoop!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.gameRunning = true     // Consider placing this inside the game loop perhaps?
        
        // TESTING!
        //ball.setVelocityVector(SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0))
    }
    
    
    func startMusicPlayer()
    {
        musicAudioPlayer = try! AVAudioPlayer(contentsOfURL: musicURL)
        musicAudioPlayer.numberOfLoops = -1     // Infinite loop
        musicAudioPlayer.prepareToPlay()
        musicAudioPlayer.play()
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
    {
//        print("CONTACT!")
//        print("ContactNormal: x: \(contact.contactNormal.x), y: \(contact.contactNormal.y)")
        
        if !ballHasFallenOff && (contact.nodeA == ball.ballNode || contact.nodeB == ball.ballNode) &&
           !(previousContactNodes.contains(contact.nodeA) && previousContactNodes.contains(contact.nodeB))
        {
            // didBeginContact can be called multiple times for the same contact, so need to check that the nodes are not the same.
            // Storing the current contact nodes to check on next call to didBeginContact:
            previousContactNodes.removeAll()
            previousContactNodes = [contact.nodeA, contact.nodeB]
            
            // contactNormal is a unitary vector, so when it is at 45 degrees to the horizon (corner contact),
            // it will satisfy the equation 1 = x^2 + y^2, with x = y = sqrt(0.5)
            if contact.contactNormal.x <= -sqrt(0.5) || contact.contactNormal.x >= sqrt(0.5)
            {
                vectorX *= -1
            }
            
            if contact.contactNormal.y <= -sqrt(0.5) || contact.contactNormal.y >= sqrt(0.5)
            {
                vectorY *= -1
            }
            
            
            if (contact.nodeA == ball.ballNode && contact.nodeB == paddleNode) ||
               (contact.nodeA == paddleNode && contact.nodeB == ball.ballNode)
            {
                // Change vectorX depending on Paddle movement:
                let paddleSpeed = self.paddleNode.physicsBody!.velocity.x
                print("Paddle Speed = \(paddleSpeed) m/s")
                vectorX += (Double)(0.1 * -paddleSpeed)
                
                // Vibrate (using Pop)!
                AudioServicesPlaySystemSound(Taptics.Pop.rawValue)
            }
            
            ball.setVelocityVector(SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0))
            AudioServicesPlaySystemSound(tockSound)
            
            
            if contact.nodeA is Block || contact.nodeB is Block
            {
                // Is a block
                
                if contact.nodeA is Block
                {
                    contact.nodeA.removeFromParentNode()
                }
                else
                {
                    contact.nodeB.removeFromParentNode()
                }
                
                score += 1
                scoreLabel.text = String(score)
                
                print("Score: \(score)")
                print("ScoreLabel.text: \(scoreLabel.text)")
            }
            
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
//        print("ball.position.x = \(self.ball.getPositionVector().x)")
//        print("ball.presentationNode.position.x = \(self.ball.ballNode.presentationNode.position.x)")
//        print("ball.position.y = \(self.ball.getPositionVector().y)")
//        print("ball.presentationNode.position.y = \(self.ball.ballNode.presentationNode.position.y)")
        
//        print("Ball presentation node Z position: \(self.ball.getPresentationNode().position.z)")
//        print("Ball presentation node Z velocity: \(self.ball.getPresentationNode().physicsBody?.velocity.z)")
        
        if self.ball.getPresentationNode().physicsBody != nil &&
           (self.ball.getVelocityVector().z != 0 ||
           self.ball.getPresentationNode().position.z != 0)
        {
            print("Ball has aquired Z velocity or position.z != 0!")
            self.ball.setVelocityVector(SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0))
            let ballPosVect = self.ball.getPositionVector()
            self.ball.setPositionVector(SCNVector3(x: ballPosVect.x, y: ballPosVect.y, z: 0))
        }
        
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
            
            // TODO: This won't be necessary once code to control ball angle using paddle motion is implemented.
            // To make sure ball doesn't get stuck in an infinite vertical or horizontal movement
            if (vectorX < 0.09 && vectorX > -0.09)
            {
                vectorX += 0.20
            }
            
            if (vectorY < 0.09 && vectorY > -0.09)
            {
                vectorY += 0.20
            }
            
//            print("Vector X: \(vectorX)")
//            print("Vector Y:\(vectorY)")
//            print("Ball node velocity before update: \(ball.getVelocityVector())")
            
            ball.setVelocityVector(SCNVector3(x: Float(vectorX), y: Float(vectorY), z: 0))
            
//            print("Ball node velocity after update: \(ball.getVelocityVector())")
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
            if vectorY <= 0
            {
                vectorY = defaultVectorY
            }
            
            ballHasFallenOff = false // Start ball moving again
        }
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
        else    // iPhone
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
