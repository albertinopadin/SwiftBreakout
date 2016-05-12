//
//  Level.swift
//  Breakout
//
//  Created by Albertino Padin on 10/27/14.
//  Copyright (c) 2014 Albertino Padin. All rights reserved.
//

import Foundation
import SceneKit

class Level
{
    class func createLevel() -> (levelNode: SCNNode, blocks: SCNNode, walls: SCNNode)
    {
        let typesOfLevels = 2
        let randomLevelType = Int(arc4random_uniform(UInt32(typesOfLevels))) + 1
        
        let randomLevelClosure = { (randLevel: Int) -> SCNNode in
            switch randLevel
            {
            case 1:
                return self.createSquareLevel()
            case 2:
                return self.createTriangleLevel()
            default:
                return self.createSquareLevel()
            }
        }
        
        let blocks = randomLevelClosure(randomLevelType)
        let levelNode = SCNNode()
        levelNode.addChildNode(blocks)
        // Add Walls
        let walls = generateWalls()
        levelNode.addChildNode(walls)
        
        return (levelNode, blocks, walls)
    }

    
    class func createSquareLevel() -> SCNNode
    {
        let levelNode = SCNNode()
        
        for i in 1...9
        {
            for j in 1...9
            {
                let blockNode = randomBlock()
                let width:Float = Float((blockNode.geometry as! SCNBox).width)
                let height:Float = Float((blockNode.geometry as! SCNBox).height)
                let jFloat = Float(j) * (width + 1)
                let iFloat = Float(i) * (height + 1)
                blockNode.position = SCNVector3Make(jFloat, iFloat, 0)
                levelNode.addChildNode(blockNode)
            }
        }
        
        return levelNode
    }
    
    
    class func createTriangleLevel() -> SCNNode
    {
        let levelNode = SCNNode()
        
        for i in 1...9
        {
            for j in 1...i
            {
                let blockNode = randomBlock()
                let width:Float = Float((blockNode.geometry as! SCNBox).width)
                let height:Float = Float((blockNode.geometry as! SCNBox).height)
                let jFloat = Float(j) * (width + 1)
                let iFloat = Float(i) * (height + 1)
                blockNode.position = SCNVector3Make(jFloat, iFloat, 0)
                levelNode.addChildNode(blockNode)
            }
        }
        
        return levelNode
    }
    
    
    class func sideWallGeometry() -> SCNGeometry
    {
        let sideWallGeometry = SCNBox(width: 2, height: 90, length: 8, chamferRadius: 0.5)
        sideWallGeometry.firstMaterial!.diffuse.contents = UIColor.darkGrayColor()
        sideWallGeometry.firstMaterial!.specular.contents = UIColor.whiteColor()
        
        return sideWallGeometry
    }
    
    class func sideWallPhysicsBody() -> SCNPhysicsBody
    {
        let sideWallPhysicsShape = SCNPhysicsShape(geometry: sideWallGeometry(), options: nil)
        let sideWallPhysicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: sideWallPhysicsShape)
        return sideWallPhysicsBody
    }
    
    
    class func generateWalls() -> SCNNode
    {
        let wallNode = SCNNode()
        
        
        let leftWall = SCNNode(geometry: sideWallGeometry())
        leftWall.position = SCNVector3Make(-2, 2, 0)
        leftWall.physicsBody = sideWallPhysicsBody()
        setContactBitMasks(leftWall)
        leftWall.name = "Wall"
        wallNode.addChildNode(leftWall)
        
        
        let topWallGeometry = SCNBox(width: 56, height: 2, length: 8, chamferRadius: 0.5)
        topWallGeometry.firstMaterial!.diffuse.contents = UIColor.darkGrayColor()
        topWallGeometry.firstMaterial!.specular.contents = UIColor.whiteColor()
        
        let topWallPhysicsShape = SCNPhysicsShape(geometry: topWallGeometry, options: nil)
        let topWallPhysics = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: topWallPhysicsShape)
        
        let topWall = SCNNode(geometry: topWallGeometry)
        topWall.position = SCNVector3Make(24, 47, 0)
        topWall.physicsBody = topWallPhysics
        setContactBitMasks(topWall)
        topWall.name = "Wall"
        wallNode.addChildNode(topWall)
        
        
        
        let rightWall = SCNNode(geometry: sideWallGeometry())
        rightWall.position = SCNVector3Make(52, 2, 0)
        rightWall.physicsBody = sideWallPhysicsBody()
        setContactBitMasks(rightWall)
        rightWall.name = "Wall"
        wallNode.addChildNode(rightWall)
        
        return wallNode
    }
    
    
    class func setContactBitMasks(wallNode: SCNNode)
    {
        wallNode.physicsBody!.categoryBitMask = 1 << 0
        wallNode.physicsBody!.collisionBitMask = 1 << 0
        
        if #available(iOS 9.0, *) {
            wallNode.physicsBody!.contactTestBitMask = 1
        } else {
            // Fallback on earlier versions
            // By default will be the same as the collisionBitMask
        }
    }
    
    
    
    class func createLevel_Simple() -> SCNNode
    {
        let blockNode = SCNNode()
        
        let blueNode = SCNNode(geometry: Block.blueBlock())
        blueNode.position = SCNVector3Make(0, 0, 0)
        blockNode.addChildNode(blueNode)
        
        let redNode = SCNNode(geometry: Block.redBlock())
        redNode.position = SCNVector3Make(+6, 0, 0)
        blockNode.addChildNode(redNode)
        
        let greenNode = SCNNode(geometry: Block.greenBlock())
        greenNode.position = SCNVector3Make(-6, 0, 0)
        blockNode.addChildNode(greenNode)
        
        return blockNode
    }
    
    
    
    class func randomBlock() -> SCNNode
    {
        // Generate random number to pick block color
        let numberOfColors: UInt32 = UInt32(BlockColor.numberOfColors())
        let randomNumber = Int(arc4random_uniform(numberOfColors)) + 1
        let randomColor: BlockColor = BlockColor(rawValue: randomNumber)!
        
        //return Block.generateBlockNodeOfColor(randomColor)
        return Block(color: randomColor)
    }
    
}
