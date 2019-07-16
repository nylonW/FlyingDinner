//
//  CatchableItem.swift
//  catchThis
//
//  Created by Marcin Slusarek on 16/07/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import SpriteKit

class CatchableItem: SKSpriteNode {
    
    var catched = false
    var removed = false {
        didSet {
            trailNode.removeFromParent()
        }
    }
    var touching = false
    var trailNode: SKNode!
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupItem() {
        self.physicsBody?.isDynamic = true
        
        var textures = [String]()
        textures.append("Apple")
        textures.append("Brownie")
        textures.append("Eggs")
        textures.append("Fish")
        //textures.append("Honey")
        textures.append("Shrimp")
        textures.append("Strawberry")
        //textures.append("Bomb")
        //textures.append("Cat")
        //textures.append("r2d2")
        
        let random = arc4random_uniform(UInt32(textures.count))
        let texture = SKTexture(imageNamed: textures[Int(random)])
        
        trailNode = SKNode()
        trailNode.physicsBody?.mass = 0
        trailNode.zPosition = 0
        self.parent?.addChild(trailNode)
        let trail = SKEmitterNode(fileNamed: "spark.sks")!
        trail.targetNode = trailNode
        self.addChild(trail)

        self.size = CGSize(width: self.size.width * 3, height: self.size.height * 3)
        
        texture.filteringMode = SKTextureFilteringMode.nearest
        self.texture = texture
        self.physicsBody?.angularVelocity = 10
        self.physicsBody?.allowsRotation = true
        self.physicsBody = SKPhysicsBody(texture: texture, size: size)
    }
}
