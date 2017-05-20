//
//  GameEndScene.swift
//  navigator
//
//  Created by Karan Balakrishnan on 5/19/17.
//  Copyright © 2017 Karan Balakrishnan. All rights reserved.
//

import SpriteKit

class GameEndScene : SKScene {
  
    public var isHighScore : Bool = false
    public var scoreAchieved : Int = 0
    override func didMove(to view: SKView) {
        
        let _ = self.childNode(withName: "titleLabel")
        
        
        if self.isHighScore{
            if let highScoreLabel = self.childNode(withName: "highScore_label") as? SKLabelNode {
                highScoreLabel.isHidden = false
            }
        }
        if let scoreLabel = self.childNode(withName: "score_label") as? SKLabelNode {
            scoreLabel.text = String.init(self.scoreAchieved)
        }
    }
  
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let mainAreaScene : GameScene = SKScene(fileNamed: "GameScene") as! GameScene
        
        if let view = self.view {
            
            mainAreaScene.scaleMode = .aspectFill
            
            view.presentScene(mainAreaScene)
            
            view.ignoresSiblingOrder = true

        }
        
    }
}
