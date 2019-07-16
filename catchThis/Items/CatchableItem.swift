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
    var removed = false
    var touching = false
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupItem() {
        self.physicsBody?.isDynamic = true
        let texture = SKTexture(imageNamed: "item")
        self.size = CGSize(width: self.size.width * 3, height: self.size.height * 3)
        self.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "item"), size: size)
    }
}
