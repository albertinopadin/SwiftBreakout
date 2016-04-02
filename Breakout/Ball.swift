//
//  Ball.swift
//  Breakout
//
//  Created by Albertino Padin on 10/29/14.
//  Copyright (c) 2014 Albertino Padin. All rights reserved.
//

import Foundation
import SceneKit

class Ball
{
    class func createBall() -> SCNNode
    {
        let ball = SCNSphere(radius: 1.0)
        ball.firstMaterial!.diffuse.contents = UIColor.yellowColor()
        ball.firstMaterial!.specular.contents = UIColor.whiteColor()
        
        let ballNode = SCNNode(geometry: ball)
        let ballShape = SCNPhysicsShape(geometry: ball, options: nil)
        ballNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: ballShape)
        ballNode.physicsBody!.mass = 0.1
        
        setContactBitMasks(ballNode)
        
        //let particleSysDirectory = NSBundle.mainBundle().pathForResource("BallParticleSystem", ofType: "scnp")
        // Apparently do not need to set the directory when creating the particle system... wtf?
        let particleSystem = SCNParticleSystem(named: "BallParticleSystem", inDirectory: nil)
        ballNode.addParticleSystem(particleSystem!)
        
        return ballNode
    }
    
    class func setContactBitMasks(ballNode: SCNNode)
    {
        ballNode.physicsBody!.categoryBitMask = 1 << 0
        ballNode.physicsBody!.collisionBitMask = 1 << 0
        
        if #available(iOS 9.0, *) {
            ballNode.physicsBody!.contactTestBitMask = 1
        } else {
            // Fallback on earlier versions
            // By default will be the same as the collisionBitMask
        }
    }
}