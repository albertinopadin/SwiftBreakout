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
    
    class func createLevel() -> SCNNode
    {
        let levelNode = SCNNode()
        
        for i in 1...9
        {
            for j in 1...9
            {
                var blockNode = randomBlock()
                let width:Float = Float((blockNode.geometry as SCNBox).width)
                let height:Float = Float((blockNode.geometry as SCNBox).height)
                let jFloat = Float(j) * (width + 1)
                let iFloat = Float(i) * (height + 1)
                blockNode.position = SCNVector3Make(jFloat, iFloat, 0)
                levelNode.addChildNode(blockNode)
            }
        }
        
        return levelNode
    }
    
    class func randomBlock() -> SCNNode
    {
        // Generate random number to pick block color
        let numberOfColors: UInt32 = UInt32(BlockColor.numberOfColors())
        let randomNumber = Int(arc4random_uniform(numberOfColors)) + 1
        let randomColor: BlockColor = BlockColor(rawValue: randomNumber)!
        
        return Block.generateBlockNodeOfColor(randomColor)
    }
    
}
