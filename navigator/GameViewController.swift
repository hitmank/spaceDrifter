//
//  GameViewController.swift
//  navigator
//
//  Created by Karan Balakrishnan on 5/12/17.
//  Copyright © 2017 Karan Balakrishnan. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let mainAreaScene : GameScene = SKScene(fileNamed: "GameScene") as! GameScene
        
        if let view = self.view as! SKView? {
            mainAreaScene.scaleMode = .aspectFill
            view.presentScene(mainAreaScene)
            view.ignoresSiblingOrder = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
