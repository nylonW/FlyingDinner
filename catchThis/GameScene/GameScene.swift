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

protocol GameManager {
    func shareScreenShot()
    func showLeaderboard()
}

class GameScene: SKScene, GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    var touching = false
    var touchPoint = CGPoint()
    var catchableItem: CatchableItem?
    var items: [CatchableItem] = []
    var playButton: MSButtonNode!
    var background: SKSpriteNode!
    
    var state: GameState = .title
    var gameDelegate: GameManager?
    var hintNode: SKSpriteNode!
    
    var menuNode: PopupNode!
    var highScoreLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var settingsButton: MSButtonNode!
    var pop = SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false)
    var fail = SKAction.playSoundFileNamed("fail.mp3", waitForCompletion: false)
    
    var leaderboardButton: MSButtonNode!
    
    var score = 0 {
        didSet {
            scoreLabel.attributedText = NSAttributedString(string: String(score))
            scoreLabel.addStroke(color: .black, width: 2.0)
            if score > 0 {
                if let hint = hintNode {
                    hint.isHidden = true
                }
            } else {
                hintNode.isHidden = false
            }
        }
    }
    
    var highScore = UserDefaults.standard.integer(forKey: "highScore") {
        didSet {
            UserDefaults.standard.set(highScore, forKey: "highScore")
            highScoreLabel.attributedText = NSAttributedString(string: "Highscore: \(highScore)")
            highScoreLabel.addStroke(color: .black, width: 2.0)
        }
    }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        //self.size = CGSize(width: UIScreen.main.nativeBounds.size.width / 4, height: UIScreen.main.nativeBounds.height / 4)
        //if UIScreen.main.sizeType == .iPhoneXS {
        //self.scene?.size.height = (self.scene?.size.width ?? 0) / (1125/2436)
        
        
        
        self.scaleMode = .aspectFill
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        hintNode = childNode(withName: "hint") as? SKSpriteNode
        hintNode.texture?.filteringMode = .nearest
        
        let pot = childNode(withName: "pot") as? SKSpriteNode
        pot?.texture?.filteringMode = .nearest
        
        settingsButton = childNode(withName: "settingsButton") as? MSButtonNode
        settingsButton.texture?.filteringMode = .nearest
        settingsButton.isHidden = true // TODO: REMOVE
        settingsButton.selectedHandler = {
            
        }
        
        playButton = childNode(withName: "playButton") as? MSButtonNode
        leaderboardButton = childNode(withName: "leaderboards") as? MSButtonNode
        leaderboardButton.isHidden = true
        leaderboardButton.selectedHandler = {
            self.gameDelegate?.showLeaderboard()
        }
        
        background = childNode(withName: "background") as? SKSpriteNode
        background.texture?.filteringMode = .nearest
        
        menuNode = PopupNode()
        menuNode.setup(with: "Game Over", name: "menu")
        
        menuNode.isHidden = true
        
        let shareButton = MSButtonNode(texture: SKTexture(imageNamed: "ShareButton"))
        shareButton.size = shareButton.texture?.size() ?? .zero
        
        shareButton.position = CGPoint(x: (menuNode.size.width - shareButton.size.width) / 2, y: (menuNode.size.height / 2) - shareButton.size.height * 2)
        shareButton.zPosition = menuNode.zPosition + 2
        shareButton.anchorPoint = .zero
        
        shareButton.selectedHandler = {
            self.gameDelegate?.shareScreenShot()
        }
        
        menuNode.addChild(shareButton)
        
        self.addChild(menuNode)

        if state == .ready {
            playButton.isHidden = true
            settingsButton.isHidden = true
            let wait = SKAction.wait(forDuration: 0.4)
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
            self.settingsButton.isHidden = true
            
            let wait = SKAction.wait(forDuration: 0.4)
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
        
        let sizeType = UIScreen.main.sizeType
        
        if sizeType == .iPhoneXS || sizeType == .iPhoneXR || sizeType == .iPhoneXSMax {
            self.size.height = self.size.height + 100
            self.scaleMode = .aspectFill
            background.size.height = self.size.height
            highScoreLabel.position = CGPoint(x: highScoreLabel.position.x + 8, y: highScoreLabel.position.y + 70)
            settingsButton.position = CGPoint(x: settingsButton.position.x - 16, y: settingsButton.position.y + 10)
            
        }
        menuNode.position = CGPoint(x: (self.size.width - menuNode.size.width) / 2, y: (self.size.height - menuNode.size.height) / 2)
        
    }
    
    func throwNewItem() {
        let item = CatchableItem(texture: SKTexture(imageNamed: "item"))
        self.addChild(item)
        item.setupItem()
        
        item.zPosition = 1
        
        let random = arc4random_uniform(100)
        if random <= 49 {
            item.position = CGPoint(x: 367, y: 220 + Int(random * 2))
            item.physicsBody?.velocity = CGVector(dx: -600 - 1.5 * CGFloat(score), dy: CGFloat(400 + CGFloat(score)))
        } else {
            item.position = CGPoint(x: -40, y: 220 + Int(random - 50) * 2)
            item.physicsBody?.velocity = CGVector(dx: 600 + 1.5 * CGFloat(score), dy: CGFloat(400 + CGFloat(score))                                                                   )
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
                playSound(sound: pop)
            } else if (item.position.x < 0 || item.position.x > self.size.width) && score != 0 && item.catched == false && item.enteredScene {
                gameOver()
            } else if item.position.y < -1000 {
                item.removeFromParent()
                item.removed = true
            } else if item.position.x >= 0 && item.position.x <= 320 && score != 0 {
                item.enteredScene = true
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
        playSound(sound: fail)
        //self.settingsButton.isHidden = false
        
        //MARK: LEADERBOARDS
        
        menuNode.score = score
        
        if score > highScore {
            highScore = score
            menuNode.titleLabel.attributedText = menuNode.getAttributedText(text: "New record!")
            menuNode.titleLabel.position = CGPoint(x: (menuNode.size.width - (menuNode.titleLabel.attributedText?.size().width ?? 0)) / 2, y: menuNode.size.height - 70)
            
            let bestScoreInt = GKScore(leaderboardIdentifier: GameViewController.LEADERBOARD_ID)
            bestScoreInt.value = Int64(highScore)
            GKScore.report([bestScoreInt]) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Best Score submitted to your Leaderboard!")
                }
            }
        }
        
        menuNode.isHidden = false
        playButton.isHidden = false
        
        playButton.position = CGPoint(x: playButton.position.x - (playButton.size.width / 2) - 1, y: playButton.position.y)
        leaderboardButton.isHidden = false
        leaderboardButton.position = CGPoint(x: playButton.position.x + playButton.size.width + 1, y: playButton.position.y)
        
        playButton.selectedHandler = {
            let skView = self.view as SKView?
            guard let scene = SKScene(fileNamed: "GameScene") as! GameScene? else { return }
            
            scene.scaleMode = .aspectFill
            scene.state = .ready
            scene.gameDelegate = self.gameDelegate
            
            skView?.presentScene(scene)
        }
    }
    
    func playSound(sound : SKAction) {
        run(sound)
    }
}
