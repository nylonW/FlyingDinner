//
//  GameViewController.swift
//  catchThis
//
//  Created by Marcin Slusarek on 16/07/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GameManager {
    
    var gcEnabled = Bool()
    var gcDefaultLeaderBoard = String()
    var score = 0
    
    static let LEADERBOARD_ID = "grp.nylon.catch"
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.gameDelegate = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
        
        authenticateLocalPlayer()
        
    }
    
    func shareScreenShot() {
        ScreenShareHelper.app.captrueAndShare(in: self)
    }
    
    //MARK: LEADERBOARDS
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { (ViewController, error) -> Void in
            if let vc = ViewController {
                self.present(vc, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                self.gcEnabled = true
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardId, error) in
                    if let error = error {
                        print(error)
                    } else {
                        print(leaderboardId)
                        self.gcDefaultLeaderBoard = leaderboardId!
                    }
                })
            } else {
                self.gcEnabled = false
                print("Local player not authenticated")
                print(error as Any)
            }
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
