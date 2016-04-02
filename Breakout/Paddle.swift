//
//  Paddle.swift
//  Breakout
//
//  Created by Albertino Padin on 11/2/14.
//  Copyright (c) 2014 Albertino Padin. All rights reserved.
//

import Foundation
import SceneKit


class Paddle
{
    class func createPaddle() -> SCNNode
    {
        //let paddle = SCNBox(width: 8, height: 2, length: 1, chamferRadius: 2.0)
        let paddle = SCNCapsule(capRadius: 1.0, height: 8)
        paddle.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        paddle.firstMaterial!.specular.contents = UIColor.whiteColor()
        
        let paddleNode = SCNNode(geometry: paddle)
        let paddleShape = SCNPhysicsShape(geometry: paddle, options: nil)
        paddleNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: paddleShape)
        //paddleNode.geometry!.subdivisionLevel = 1
        // Rotate pill 90 degrees
        paddleNode.rotation = SCNVector4Make(0, 0, 1, Float(M_PI_4 * 2))
        //paddleNode.physicsBody!.restitution = 1.0
        //paddleNode.physicsBody!.mass = CGFloat.infinity     // Infinite mass, so collisions do not move it
        
        setContactBitMasks(paddleNode)
        
        return paddleNode
    }
    
    class func setContactBitMasks(paddleNode: SCNNode)
    {
        paddleNode.physicsBody!.categoryBitMask = 1 << 0
        paddleNode.physicsBody!.collisionBitMask = 1 << 0
        
        if #available(iOS 9.0, *) {
            print("Setting contact test bit mask")
            paddleNode.physicsBody!.contactTestBitMask = 1
        } else {
            // Fallback on earlier versions
            // By default will be the same as the collisionBitMask
        }
    }
}