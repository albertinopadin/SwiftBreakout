//
//  Block.swift
//  Breakout
//
//  Created by Albertino Padin on 10/27/14.
//  Copyright (c) 2014 Albertino Padin. All rights reserved.
//

import Foundation
import SceneKit


class Block
{
    class func blueBlockNode() -> SCNNode
    {
        var blueNode = SCNNode(geometry: Block.blueBlock())
        let blueShape = SCNPhysicsShape(geometry: blueBlock(), options: nil)
        blueNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: blueShape)
        blueNode.physicsBody!.mass = 0
        return blueNode
    }
    
    class func blueBlock() -> SCNGeometry
    {
        let blueBlock = SCNBox(width: 4.0, height: 2.0, length: 1.0, chamferRadius: 0.5)
        blueBlock.firstMaterial!.diffuse.contents = UIColor.blueColor()
        blueBlock.firstMaterial!.specular.contents = UIColor.whiteColor()
        return blueBlock
    }
    
    class func redBlock() -> SCNGeometry
    {
        let redBlock = SCNBox(width: 4.0, height: 2.0, length: 1.0, chamferRadius: 0.5)
        redBlock.firstMaterial!.diffuse.contents = UIColor.redColor()
        redBlock.firstMaterial!.specular.contents = UIColor.whiteColor()
        return redBlock
    }
    
    class func greenBlock() -> SCNGeometry
    {
        let greenBlock = SCNBox(width: 4.0, height: 2.0, length: 1.0, chamferRadius: 0.5)
        greenBlock.firstMaterial!.diffuse.contents = UIColor.greenColor()
        greenBlock.firstMaterial!.specular.contents = UIColor.whiteColor()
        return greenBlock
    }
    
    class func grayBlock() -> SCNGeometry
    {
        let grayBlock = SCNBox(width: 4.0, height: 2.0, length: 1.0, chamferRadius: 0.5)
        grayBlock.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        grayBlock.firstMaterial!.specular.contents = UIColor.whiteColor()
        return grayBlock
    }
}