import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, score:Int, isHighScore:Bool) {
        
        super.init(size: size)
        
        backgroundColor = SKColor.white
        let message = "You scored : " + String.init(score)
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        if isHighScore {
            let label = SKLabelNode(fontNamed: "Chalkduster")
            label.text = "NEW HIGH SCORE !!!"
            label.fontSize = 60
            label.fontColor = SKColor.orange
            label.position = CGPoint(x: size.width/2, y: (size.height*2)/3)
            addChild(label)
        }
        let label_playAgain = SKLabelNode(fontNamed: "Chalkduster")
        label_playAgain.text = "Think you can do better?"
        label_playAgain.fontSize = 50
        label_playAgain.fontColor = SKColor.blue
        label_playAgain.position = CGPoint(x: size.width/2, y: size.height/3)
        addChild(label_playAgain)
      //  let playAgainButton = UIButton.init(type: .roundedRect)
      //  playAgainButton.target(forAction: Selector(("playAgain")), withSender: nil)
      //  playAgainButton.setTitle("Play Again!", for: .normal)
      //  playAgainButton.center = CGPoint.init(x: size.width/2, y: label_playAgain.position.y + label_playAgain.frame.size.height + 20)
      //  self.view!.addSubview(playAgainButton)
        
    }
    func playAgain(){
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(fileNamed: "GameScene")
        let transition = SKTransition.flipVertical(withDuration: 1.0)

        let mainAreaScene : GameScene = SKScene(fileNamed: "GameScene") as! GameScene
        
        for uiview in self.view!.subviews{
            uiview.removeFromSuperview()
        }
        
        if let view = self.view as! SKView? {

            mainAreaScene.scaleMode = .aspectFill
            
            view.presentScene(mainAreaScene)

            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }

    }
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
