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
        return ballNode
    }
}