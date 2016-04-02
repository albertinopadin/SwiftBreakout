//
//  Block.swift
//  Breakout
//
//  Created by Albertino Padin on 10/27/14.
//  Copyright (c) 2014 Albertino Padin. All rights reserved.
//

import Foundation
import SceneKit


enum BlockColor: Int
{
    case    BlueColor = 1,
            RedColor,
            GreenColor,
            GrayColor
    
    static func numberOfColors() -> Int
    {
        return 4
    }
}



class Block
{
    class func generateBlockNodeOfColor(color: BlockColor) -> SCNNode
    {
        var nodeGeometry: SCNGeometry
        
        switch color
        {
            case .BlueColor:
                nodeGeometry = blueBlock()
            case .RedColor:
                nodeGeometry = redBlock()
        	case .GreenColor:
                nodeGeometry = greenBlock()
            case .GrayColor:
                nodeGeometry = grayBlock()
//            default:
//                nodeGeometry = blueBlock()
        }
        
        let blockNode = SCNNode(geometry: nodeGeometry)
        let blockShape = SCNPhysicsShape(geometry: nodeGeometry, options: nil)
        blockNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: blockShape)
        blockNode.physicsBody!.mass = 0
        
        setContactBitMasks(blockNode)
        
        return blockNode
    }
    
    
    class func setContactBitMasks(blockNode: SCNNode)
    {
        blockNode.physicsBody!.categoryBitMask = 1 << 0
        blockNode.physicsBody!.collisionBitMask = 1 << 0
        
        if #available(iOS 9.0, *) {
            blockNode.physicsBody!.contactTestBitMask = 1
        } else {
            // Fallback on earlier versions
            // By default will be the same as the collisionBitMask
        }
    }
    
    /* NODES */
    
    class func blueBlockNode() -> SCNNode
    {
        let blueNode = SCNNode(geometry: blueBlock())
        let blueShape = SCNPhysicsShape(geometry: blueBlock(), options: nil)
        blueNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: blueShape)
        blueNode.physicsBody!.mass = 0
        return blueNode
    }
    
    class func redBlockNode() -> SCNNode
    {
        let redNode = SCNNode(geometry: redBlock())
        let redShape = SCNPhysicsShape(geometry: redBlock(), options: nil)
        redNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: redShape)
        redNode.physicsBody!.mass = 0
        return redNode
    }
    
    class func greenBlockNode() -> SCNNode
    {
        let greenNode = SCNNode(geometry: greenBlock())
        let greenShape = SCNPhysicsShape(geometry: greenBlock(), options: nil)
        greenNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: greenShape)
        greenNode.physicsBody!.mass = 0
        return greenNode
    }
    
    class func grayBlockNode() -> SCNNode
    {
        let grayNode = SCNNode(geometry: grayBlock())
        let grayShape = SCNPhysicsShape(geometry: grayBlock(), options: nil)
        grayNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: grayShape)
        grayNode.physicsBody!.mass = 0
        return grayNode
    }
    
    
    
    /* GEOMETRIES */
    
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