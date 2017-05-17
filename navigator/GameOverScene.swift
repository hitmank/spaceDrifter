import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, score:Int) {
        
        super.init(size: size)
        
        // 1
        backgroundColor = SKColor.white
        
        // 2
        //let message = won ? "You Won!" : "You Lose :["
        let message = "You scored : " + String.init(score)
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)

        
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
