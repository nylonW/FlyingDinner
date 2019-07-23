//
//  PopupNode.swift
//  catchThis
//
//  Created by Marcin Slusarek on 21/07/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import SpriteKit

class PopupNode: SKSpriteNode {
    
    var scoreLabel: SKLabelNode!
    var titleLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.attributedText = NSAttributedString(string: "\(score)")
            scoreLabel.addStroke(color: .black, width: 2.0)
            scoreLabel.position = CGPoint(x: (self.size.width - (scoreLabel.attributedText?.size().width ?? 0)) / 2, y: ((self.size.height - 35) / 2))
        }
    }
    
    func setup(with title: String, name: String) {
        self.name = name
        let texture = SKTexture(imageNamed: "menu")
        self.texture = texture
        self.texture?.filteringMode = SKTextureFilteringMode.nearest
        self.size = texture.size().applying(CGAffineTransform(scaleX: 3, y: 3))
        anchorPoint = .zero
        //self.position = CGPoint(x: (self.scene?.size.width ?? 0 - self.size.width) / 2, y: 0)
        self.zPosition = 4
        
        titleLabel = getLabelWithAttributed(text: title)
        titleLabel.position = CGPoint(x: (self.size.width - (titleLabel.attributedText?.size().width ?? 0)) / 2, y: self.size.height - 70)
        self.addChild(titleLabel)
        
        let scoreTitleLabel = getLabelWithAttributed(text: "score")
        scoreTitleLabel.verticalAlignmentMode = .bottom
        
        scoreLabel = getLabelWithAttributed(text: "0")
        scoreLabel.position = CGPoint(x: (self.size.width - (scoreLabel.attributedText?.size().width ?? 0)) / 2, y: ((self.size.height - 35) / 2))
        scoreLabel.fontSize = 72
        
        scoreTitleLabel.position = CGPoint(x: (self.size.width - (scoreTitleLabel.attributedText?.size().width ?? 0)) / 2, y: scoreLabel.position.y + (scoreLabel.attributedText?.size().height ?? 0) + 18)
        
        self.addChild(scoreLabel)
        self.addChild(scoreTitleLabel)
    }
    
    func getAttributedText(text: String) -> NSAttributedString {
        let label = SKLabelNode()
        label.fontName = "ArcadeClassic"
        label.fontSize = 35
        label.fontColor = UIColor(red: 1.00, green: 0.88, blue: 0.08, alpha:1.0)
        label.text = text
        
        label.addStroke(color: .black, width: 2.0)
        label.horizontalAlignmentMode = .left
        
        label.zPosition = self.zPosition + 1
        
        return label.attributedText!
    }
    
    func getLabelWithAttributed(text: String) -> SKLabelNode {
        let label = SKLabelNode()
        label.fontName = "ArcadeClassic"
        label.fontSize = 35
        label.fontColor = UIColor(red: 1.00, green: 0.88, blue: 0.08, alpha:1.0)
        label.text = text
        
        label.addStroke(color: .black, width: 2.0)
        label.horizontalAlignmentMode = .left
        
        label.zPosition = self.zPosition + 1
        
        return label
    }
}
