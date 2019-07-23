//
//  GameScene.swift
//  catchThis
//
//  Created by Marcin Slusarek on 16/07/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit
import UIKit

enum GameState {
    case title, ready, playing, gameOver
}

class GameScene: SKScene, GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        
    }
    
    
    var touching = false
    var touchPoint = CGPoint()
    var catchableItem: CatchableItem?
    var items: [CatchableItem] = []
    var playButton: MSButtonNode!
    
    var state: GameState = .title
    
    var menuNode: PopupNode!
    var highScoreLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.attributedText = NSAttributedString(string: String(score))
            scoreLabel.addStroke(color: .black, width: 2.0)
        }
    }
    
    var highScore = UserDefaults.standard.integer(forKey: "highScore") {
        didSet {
            UserDefaults.standard.set(highScore, forKey: "highScore")
            highScoreLabel.attributedText = NSAttributedString(string: String(highScore))
            highScoreLabel.addStroke(color: .black, width: 2.0)
        }
    }
    
    override func didMove(to view: SKView) {
        
        playButton = childNode(withName: "playButton") as? MSButtonNode
        let background = childNode(withName: "background") as! SKSpriteNode
        background.texture?.filteringMode = SKTextureFilteringMode.nearest
        
        menuNode = PopupNode()
        menuNode.setup(with: "Game Over", name: "menu")
        menuNode.position = CGPoint(x: (self.size.width - menuNode.size.width) / 2, y: (self.size.height - menuNode.size.height) / 2)
        menuNode.isHidden = true
        self.addChild(menuNode)

        if state == .ready {
            playButton.isHidden = true
            let wait = SKAction.wait(forDuration: 0.8)
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
        scoreLabel.addStroke(color: .black, width: 2.0)
        
        highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode
        highScoreLabel.attributedText = NSAttributedString(string: "High score: \(highScore)")
        highScoreLabel.addStroke(color: .black, width: 2.0)
        
    }
    
    func throwNewItem() {
        let item = CatchableItem(texture: SKTexture(imageNamed: "item"))
        self.addChild(item)
        item.setupItem()
        
        item.zPosition = 1
        
        let random = arc4random_uniform(100)
        if random <= 49 {
            item.position = CGPoint(x: 367, y: 220 + Int(random * 2))
            item.physicsBody?.velocity = CGVector(dx: -600 - 2 * CGFloat(score), dy: CGFloat(400 + 2 * score))
        } else {
            item.position = CGPoint(x: -40, y: 220 + Int(random - 50) * 2)
            item.physicsBody?.velocity = CGVector(dx: 600 + 2 * CGFloat(score), dy: CGFloat(400 + 2 * score)                                                                   )
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
            
            if item.position.y < 0 && item.position.x >= 0 && item.position.x <= 320 && item.catched == false {
                score += 1
                item.catched = true
            } else if item.position.y < 0 && score != 0 && item.catched == false {
                gameOver()
            } else if item.position.y < -1000 {
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
        
        //MARK: LEADERBOARDS
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = GameViewController.LEADERBOARD_ID
        self.inputViewController?.present(gcVC, animated: true, completion: nil)
        
        menuNode.isHidden = false
        menuNode.score = score
        
        if score > highScore {
            highScore = score
        }
        
        playButton.selectedHandler = {
            let skView = self.view as SKView?
            guard let scene = SKScene(fileNamed: "GameScene") as! GameScene? else { return }
            
            scene.scaleMode = .aspectFill
            scene.state = .ready
            skView?.presentScene(scene)
        }
    }
}
