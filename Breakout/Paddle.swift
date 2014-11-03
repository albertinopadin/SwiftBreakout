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
        let paddle = SCNBox(width: 8, height: 1, length: 1, chamferRadius: 0.5)
        paddle.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        paddle.firstMaterial!.specular.contents = UIColor.whiteColor()
        
        let paddleNode = SCNNode(geometry: paddle)
        let paddleShape = SCNPhysicsShape(geometry: paddle, options: nil)
        paddleNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: paddleShape)
        //paddleNode.physicsBody!.restitution = 1.0
        paddleNode.physicsBody!.mass = CGFloat.infinity     // Infinit mass, so collisions do not move it
        return paddleNode
    }
}