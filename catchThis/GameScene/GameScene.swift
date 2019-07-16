//
//  GameScene.swift
//  catchThis
//
//  Created by Marcin Slusarek on 16/07/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState {
    case title, ready, playing, gameOver
}

class GameScene: SKScene {
    
    var touching = false
    var touchPoint = CGPoint()
    var catchableItem: CatchableItem?
    var items: [CatchableItem] = []
    var playButton: MSButtonNode!
    
    var state: GameState = .title
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    
    override func didMove(to view: SKView) {
        
        playButton = childNode(withName: "playButton") as? MSButtonNode
        let background = childNode(withName: "background") as! SKSpriteNode
        background.texture?.filteringMode = SKTextureFilteringMode.nearest
        
        if state == .ready {
            playButton.isHidden = true
            let wait = SKAction.wait(forDuration: 1)
            let update = SKAction.run( {
                self.throwNewItem()
            })
            
            let seq = SKAction.sequence([wait,update])
            let repeatAction = SKAction.repeatForever(seq)
            self.run(repeatAction)
        }
        
        playButton.selectedHandler = {
            self.state = .ready
            self.playButton.isHidden = true
            
            let wait = SKAction.wait(forDuration: 1)
            let update = SKAction.run( {
                self.throwNewItem()
            })
            
            let seq = SKAction.sequence([wait,update])
            let repeatAction = SKAction.repeatForever(seq)
            self.run(repeatAction)
        }
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        
    }
    
    func throwNewItem() {
        let item = CatchableItem(texture: SKTexture(imageNamed: "item"))
        self.addChild(item)
        item.setupItem()
        
        item.zPosition = 1
        
        let random = arc4random_uniform(100)
        if random <= 49 {
            item.position = CGPoint(x: 367, y: 220)
            item.physicsBody?.velocity = CGVector(dx: -600 - 1.5 * CGFloat(score), dy: CGFloat(400 + 2 * score))
        } else {
            item.position = CGPoint(x: -40, y: 220)
            item.physicsBody?.velocity = CGVector(dx: 600 + 1.5 * CGFloat(score), dy: CGFloat(400 + 2 * score)                                                                   )
        }
        
        self.items.append(item)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if state == .gameOver || state == .title {
            playButton.isHidden = false
            return
        }
        
        if state == .ready {
            state = .playing
            playButton.isHidden = true
        }
        
        let touch = touches.first!
        let location = touch.location(in: self)
        for catchableItem in items {
            if catchableItem.frame.contains(location) {
                touchPoint = location
                catchableItem.touching = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        touchPoint = location
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for item in items {
            item.touching = false
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        items.removeAll(where: { $0.removed })

        if state == .gameOver {
            self.playButton.isHidden = false
            removeItems()
            return
        } else if state != .playing {
            removeItems()
            return
        }

        for item in items {
            if item.touching {
                let dt: CGFloat = 1.0/60.0
                let distance = CGVector(dx: touchPoint.x - item.position.x, dy: touchPoint.y - item.position.y)
                let velocity = CGVector(dx: distance.dx / dt, dy: distance.dy / dt)
                item.physicsBody!.velocity = velocity
            }
            
            if item.position.y < 0 && item.position.x >= 0 && item.position.x <= 320  {
                score += 1
                item.removeFromParent()
                item.removed = true
            } else if item.position.y < 0 && score != 0 {
                gameOver()
                item.removeFromParent()
                item.removed = true
            } else if item.position.y < 0 {
                item.removeFromParent()
                item.removed = true
            }
        }
    }
    
    func removeItems() {
        for item in items {
            if item.position.y < 0 {
                item.removeFromParent()
                item.removed = true
            }
        }
    }
    
    func gameOver() {
        state = .gameOver
        
        playButton.selectedHandler = {
            let skView = self.view as SKView?
            guard let scene = SKScene(fileNamed: "GameScene") as! GameScene? else { return }
            
            scene.scaleMode = .aspectFill
            scene.state = .ready
            skView?.presentScene(scene)
        }
    }
}
