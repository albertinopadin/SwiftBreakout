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
        let blockNode = SCNNode()
        
        for i in 1...10
        {
            for j in 1...10
            {
                var blueNode = SCNNode(geometry: Block.blueBlock())
                let width:Float = Float((blueNode.geometry as SCNBox).width)
                let height:Float = Float((blueNode.geometry as SCNBox).height)
                let jFloat = Float(j) * (width + 1)
                let iFloat = Float(i) * (height + 1)
                blueNode.position = SCNVector3Make(jFloat, iFloat, 0)
                blockNode.addChildNode(blueNode)
            }
        }
        
        return blockNode
    }
    
}
