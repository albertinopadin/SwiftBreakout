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
    var ballNode: SCNNode
    
    // Default init:
    init()
    {
        ballNode = Ball.createBall(1.0, color: UIColor.yellowColor())
    }
    
    init(radius: Double, color: UIColor)
    {
        ballNode = Ball.createBall(radius, color: color)
    }
    
    
    class func createBall(radius: Double, color: UIColor) -> SCNNode
    {
        let ball = SCNSphere(radius: 1.0)
        ball.firstMaterial!.diffuse.contents = color
        ball.firstMaterial!.specular.contents = UIColor.whiteColor()
        
        let bNode = SCNNode(geometry: ball)
        let ballShape = SCNPhysicsShape(geometry: ball, options: nil)
        bNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: ballShape)
        bNode.physicsBody!.mass = 0.1
        
        setContactBitMasks(bNode)
        
        let particleSystem = SCNParticleSystem(named: "BallParticleSystem", inDirectory: nil)
        bNode.addParticleSystem(particleSystem!)
        
        return bNode
    }
    
    
    class func setContactBitMasks(bNode: SCNNode)
    {
        bNode.physicsBody!.categoryBitMask = 1 << 0
        bNode.physicsBody!.collisionBitMask = 1 << 0
        
        if #available(iOS 9.0, *) {
            bNode.physicsBody!.contactTestBitMask = 1
        } else {
            // Fallback on earlier versions
            // By default will be the same as the collisionBitMask
        }
    }
    
    
    func getVelocityVector() -> SCNVector3
    {
        return self.ballNode.physicsBody!.velocity
    }
    
    func setVelocityVector(velocityVector: SCNVector3)
    {
        self.ballNode.physicsBody!.velocity = velocityVector
    }
    
    
    func getPositionVector() -> SCNVector3
    {
        return self.ballNode.position
    }
    
    func setPositionVector(positionVector: SCNVector3)
    {
        self.ballNode.position = positionVector
    }
    
}