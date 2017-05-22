//
//  GameScene.swift
//  navigator
//
//  Created by Karan Balakrishnan on 5/12/17.
//  Copyright © 2017 Karan Balakrishnan. All rights reserved.
//

import SpriteKit
import GameplayKit
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Obsticle   : UInt32 = 0x1 << 1      // 1
    static let Food: UInt32 = 0x1 << 2
    static let Ship: UInt32 = 0x1 << 3
}

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    let backgroundMusicSoundFile : String = "bkg.mp3"
    let smallExplosionEmmiter : String = "boom.sks"
    let bigExplosionEmmitter : String = "boomBig.sks"
    
    let level_2_scoreLimit = 201
    let level_3_scoreLimit = 601
    let level_4_scoreLimit = 901
    
    let level_1_obsticle  : String = "obsticle_level_1"
    let level_2_obsticle  : String = "obsticle_level_2"
    let level_3_obsticle  : String = "obsticle_level_3"
    let level_4_obsticle  : String = "obsticle_level_4"
    
    let level_1_gem  : String = "gem_level_1"
    let level_2_gem  : String = "gem_level_2"
    let level_3_gem  : String = "gem_level_3"
    let level_4_gem  : String = "gem_level_4"
    
    let level_1_obsticleThreshold : Float = 0.5
    let level_2_obsticleThreshold : Float = 0.45
    let level_3_obsticleThreshold : Float = 0.4
    let level_4_obsticleThreshold : Float = 0.35

    let level_1_backgroundImage : String = "background_level_1"
    let level_2_backgroundImage : String  = "background_level_2"
    let level_3_backgroundImage : String  = "background_level_3"
    let level_4_backgroundImage : String  = "background_level_4"
    
    let shipImage : String  = "ship"
    let smokeImage : String  = "smoke"
    let scoreImage : String  = "scoreLabel"
    let highScoreStore : String  = "spaceHighScore"
    
    let kill_points_level_1 : Int = 25;
    let kill_points_level_2 : Int = 35;
    let kill_points_level_3 : Int = 45;
    let kill_points_level_4 : Int = 55;
    
    let perSecond_points_level_1 : Int = 1;
    let perSecond_points_level_2 : Int = 1;
    let perSecond_points_level_3 : Int = 1;
    let perSecond_points_level_4 : Int = 1;

    let gem_points_level_1 : Int = 20;
    let gem_points_level_2 : Int = 30;
    let gem_points_level_3 : Int = 40;
    let gem_points_level_4 : Int = 50;



    var ship : SKSpriteNode = SKSpriteNode.init()
    var smoke : SKNode = SKNode.init()
    var gem : SKSpriteNode = SKSpriteNode.init()
    var label : SKLabelNode = SKLabelNode()
    var currentHighScore = 0
    var isNewHighScore : Bool = false
    var scoreLabelColor : UIColor = UIColor.white;
    var currentLevel : Int = 1;
    var obsticleThreshold : Float = 0.5
    var foodThreshold : Float = 0.5
    var currentObsticleImage : String = "obsticle_level_1"
    var currentGemImage : String = "gem_level_1"
    var currentBackgroundImage : String = "background_level_1"
    var current_kill_points : Int = 20
    var current_per_second_points : Int = 10
    var current_gem_points : Int = 20
    
    func doBasicInitializations(){
        makeChangesForLevel(level: 1)
        self.ship = self.childNode(withName: shipImage) as! SKSpriteNode
        self.smoke = self.childNode(withName: smokeImage)!
        self.label = self.childNode(withName: scoreImage) as! SKLabelNode
        if UserDefaults.standard.value(forKey: highScoreStore) != nil{
            self.currentHighScore = UserDefaults.standard.integer(forKey: highScoreStore)
        }
        else{
            self.currentHighScore = 0

        }
        self.physicsWorld.contactDelegate = self;

        self.smoke.physicsBody = SKPhysicsBody(rectangleOf: self.smoke.frame.size)
        
        let shipTexture = SKTexture.init(imageNamed: shipImage)
        ship.physicsBody = SKPhysicsBody(texture: shipTexture, size: shipTexture.size())
        ship.physicsBody?.isDynamic = true
        ship.physicsBody?.categoryBitMask = PhysicsCategory.Ship
        ship.physicsBody?.contactTestBitMask = PhysicsCategory.Obsticle
        ship.physicsBody?.collisionBitMask = PhysicsCategory.None
        ship.physicsBody?.usesPreciseCollisionDetection = true
        ship.physicsBody?.affectedByGravity = false
    }

    var crazy = false;
    override func update(_ currentTime: TimeInterval) {
        moveBackground()
        updateScore()
    }
    
    func updateScore(){
        var currentScore = Int.init(label.text!)
        currentScore = currentScore! + self.current_per_second_points;
        label.text = String.init(currentScore!)
        if !self.isNewHighScore && (currentScore! > self.currentHighScore)  {
            self.isNewHighScore = true;
            self.scoreLabelColor = UIColor.orange
            label.fontColor = self.scoreLabelColor;
            UserDefaults.standard.set(currentScore!, forKey: highScoreStore)
        }
        if currentScore! == level_2_scoreLimit {
            makeChangesForLevel(level: 2)
        }
        if currentScore! == level_3_scoreLimit {
            makeChangesForLevel(level: 3)
        }
        if currentScore! == level_4_scoreLimit {
            makeChangesForLevel(level: 4)
        }
    }

    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if firstBody.node == nil || secondBody.node == nil {
            return;
        }
        if firstBody.node!.name == "ship" && (secondBody.node!.name == "rightMis" || secondBody.node!.name == "leftMis"){
            return;
        
        }
        else if secondBody.node!.name == "obsticle" && (firstBody.node!.name == "rightMis" || firstBody.node!.name == "leftMis"){
            secondBody.node!.alpha = secondBody.node!.alpha - 0.3;
            if secondBody.node!.alpha <= 0.1{
                blowUpAObsticle(obsticle: secondBody.node!)
            }
            else{
                explosionSmall(pos: contact.contactPoint)
            }
            firstBody.node!.removeFromParent()
            return;
        }
        else if secondBody.node!.name == "food" && (firstBody.node!.name == "rightMis" || firstBody.node!.name == "leftMis"){
         
            return;
        }
  
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Ship != 0) &&
            (secondBody.node!.name == "obsticle")) {
            
            if crazy {
                return;
            }
            crazy = true;
            let acc = SKAction.scale(to: 2.05, duration: 0.05)
            let acc2 = SKAction.scale(to: 1, duration: 0.05);
            
            self.childNode(withName: "bg")?.run(SKAction.sequence([acc,acc2]))
            
            let movex1 = SKAction.move(by: CGVector.init(dx: -17, dy: 0), duration: 0.05)
            let movex2 = SKAction.move(by: CGVector.init(dx: -20, dy: 0), duration: 0.05)
            let movex3 = SKAction.move(by: CGVector.init(dx: 17, dy: 0), duration: 0.05)
            let movex4 = SKAction.move(by: CGVector.init(dx: 20, dy: 0), duration: 0.05)

            let movey1 = SKAction.move(by: CGVector.init(dx: 0, dy: -17), duration: 0.05)
            let movey2 = SKAction.move(by: CGVector.init(dx: 0, dy: -20), duration: 0.05)
            let movey3 = SKAction.move(by: CGVector.init(dx: 0, dy: 17), duration: 0.05)
            let movey4 = SKAction.move(by: CGVector.init(dx: 0, dy: 20), duration: 0.05)
            
            
            let trembleX = SKAction.sequence([movex1,movex4,movex2,movex3])
            let trembleY = SKAction.sequence([movey1,movey4,movey2,movey3])

            var x = 1;
            
            if self.isNewHighScore {
                var currentScore = Int.init(label.text!)
                currentScore = currentScore! + 1;
                UserDefaults.standard.set(currentScore!, forKey: "spaceHighScore")
            }
            
            let seq = SKAction.sequence([trembleX,trembleY,SKAction.wait(forDuration: 0.3),SKAction.run {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let label = self.childNode(withName: "scoreLabel") as! SKLabelNode
                let currentScore = Int.init(label.text!)
             
                let gameOverScene : GameEndScene = SKScene.init(fileNamed: "GameOver") as! GameEndScene
                gameOverScene.scaleMode = .aspectFill
                gameOverScene.scoreAchieved = currentScore!
                gameOverScene.isHighScore = self.isNewHighScore
                 self.view?.presentScene(gameOverScene, transition: reveal)
            }])
            let boomShankar = SKAudioNode(fileNamed: "boom.mp3")
            self.addChild(boomShankar)
            let emitterNode = SKEmitterNode(fileNamed: "finalBoom.sks")
            emitterNode!.particlePosition = contact.contactPoint
            self.addChild(emitterNode!)
            self.ship.isHidden = true
          
           for child in self.children {
                x = x + 1;
                if x == self.children.count{
                    child.run(seq)
                }
                else{
                    child.run(trembleX)
                    child.run(trembleY)
                }
                
            }

        }
        else if(secondBody.node!.name == "food"){
            updateScoreBy(points: self.current_gem_points)
            run(SKAction.playSoundFileNamed("a.wav", waitForCompletion: false))
            secondBody.node!.removeFromParent()
            let gun = self.childNode(withName: "gun")
            if (gun?.alpha)! < CGFloat(1.0) {
                gun!.alpha = gun!.alpha + 0.1;
               
            }

        }
    }
    
    func explosionSmall(pos: CGPoint) {
        let emitterNode = SKEmitterNode(fileNamed: smallExplosionEmmiter)
        emitterNode!.particlePosition = pos
        self.addChild(emitterNode!)
        self.run(SKAction.wait(forDuration: 2), completion: { emitterNode!.removeFromParent() })
        
    }
    
    func explosionBig(pos: CGPoint) {
        let emitterNode = SKEmitterNode(fileNamed: bigExplosionEmmitter)
        emitterNode!.particlePosition = pos
        self.addChild(emitterNode!)
        self.run(SKAction.wait(forDuration: 2), completion: { emitterNode!.removeFromParent() })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = touches.first
        var newLoc = touches?.location(in: self.view)
        newLoc  = self.convertPoint(fromView: newLoc!)
        let node = self.nodes(at: newLoc!)
        if node[0].name == nil{
            return;
        }
        if node[0].name! == "gun"{
            
            if node[0].alpha > 0.9{
                fireGemGun()
                node[0].alpha = 0.1
            }
            
        }
        if node[0].name! == "leftNav"{
            
            moveShipLeft()
            
        }
        if node[0].name! == "rightNav"{
            
            moveShipRight()
            
        }
        if node[0].name! == "leftGun"{
            
            shootLeftMissile()
            
        }
        if node[0].name! == "rightGun"{
            
            shootRightMissile()
            
        }

        
    }
    
    func blowUpAObsticle(obsticle : SKNode){
        updateScoreBy(points: self.current_kill_points)
        explosionBig(pos: CGPoint.init(x: obsticle.position.x, y: obsticle.position.y - 200))
        obsticle.removeFromParent()
    }
    
    func fireGemGun(){
        self.gem = self.childNode(withName: "gun") as! SKSpriteNode
        for node in self.children {
            if node.name == "obsticle" {
                let beizerPath = UIBezierPath.init()
                beizerPath.move(to: self.gem.position)
                beizerPath.addCurve(to: node.position, controlPoint1: randomPoint(rect: self.frame), controlPoint2: randomPoint(rect: self.frame))
                let action = SKAction.follow(beizerPath.cgPath, asOffset: false, orientToPath: true, duration: 0.5)
                let newMissile = SKSpriteNode.init(fileNamed: "GemMissiles")!
                newMissile.position = ship.position;
                newMissile.name = "AtomBomb"
                newMissile.size = CGSize.init(width: 100, height: 100)
                self.addChild(newMissile)
                newMissile.run(SKAction.sequence([action,SKAction.run {
                    newMissile.removeFromParent()
                    self.blowUpAObsticle(obsticle: node)
                    }]))
            }
        }
    }
    
    func randomPoint(rect : CGRect) -> CGPoint{
        let x = (rect.minX + CGFloat.init(arc4random())).truncatingRemainder(dividingBy: rect.width)
        let y = (rect.minY + CGFloat.init(arc4random())).truncatingRemainder(dividingBy: rect.height)
        return CGPoint.init(x: x, y: y)
    }
    
    func shootLeftMissile(){
        let projectile = SKSpriteNode(imageNamed: "leftMis")
        projectile.position = CGPoint.init(x: self.ship.position.x - 30.0, y: self.ship.position.y)
        projectile.size = CGSize.init(width: 60, height: 70)
        projectile.name = "leftMis"

        addChild(projectile)
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Obsticle
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        let actionMove = SKAction.move(to: CGPoint.init(x: projectile.position.x, y: 2000), duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    func shootRightMissile(){
        let projectile = SKSpriteNode(imageNamed: "rightMis")
        projectile.position = CGPoint.init(x: self.ship.position.x + 30.0, y: self.ship.position.y)
        projectile.size = CGSize.init(width: 60, height: 70)
        projectile.name = "rightMis"
        addChild(projectile)
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Obsticle
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        let actionMove = SKAction.move(to: CGPoint.init(x: projectile.position.x, y: 2000), duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    func updateScoreBy(points : Int){
        var currentScore = Int.init(label.text!)
        if currentScore! > (level_2_scoreLimit - (points + 1)) && currentScore! < level_2_scoreLimit {
            makeChangesForLevel(level: 2)
        }
        if currentScore! > (level_3_scoreLimit - (points + 1)) && currentScore! < level_3_scoreLimit {
            makeChangesForLevel(level: 3)

        }
      
        currentScore = currentScore! + points;
        label.text = String.init(currentScore!)
        label.run(SKAction.sequence([SKAction.run {
            self.label.fontSize = 122.0;
            self.label.fontColor = UIColor.green
            },SKAction.run {
                self.label.fontSize = 72.0;
                self.label.fontColor = self.scoreLabelColor
            }]))
        if !self.isNewHighScore && (currentScore! > self.currentHighScore)  {
            self.isNewHighScore = true;
            self.scoreLabelColor = UIColor.orange
            label.fontColor = self.scoreLabelColor;
            UserDefaults.standard.set(currentScore!, forKey: highScoreStore)
        }
        
    }
    func moveShipLeft() {

        let currentPos = self.ship.position;
        var finalXPos = CGFloat(0.0);
        if currentPos.x <= 50{
            finalXPos = 50.0;
        }
        else{
            finalXPos = CGFloat(currentPos.x - 50);
        }
        
        self.ship.position = CGPoint.init(x: finalXPos, y: currentPos.y)
        self.smoke.physicsBody?.applyForce(CGVector.init(dx: 0, dy: 500))
    }
    func moveShipRight() {
        let currentPos = self.ship.position;
        var finalXPos = CGFloat(0.0);
        if currentPos.x >= 1025{
            finalXPos = 1030;
        }
        else{
            finalXPos = CGFloat(currentPos.x + 50);
        }
        
        self.ship.position = CGPoint.init(x: finalXPos, y: currentPos.y)
        let act = SKAction.moveTo(x: self.ship.position.x, duration: 0.02)
        self.smoke.run(act)
    
    }
    
    //TODO: change 0.8?
    override func didMove(to view: SKView) {
        doBasicInitializations()
               run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addObsticles),
                SKAction.wait(forDuration: 0.8)
                ])
        ))
        createBackground()
        let backgroundMusic = SKAudioNode(fileNamed: backgroundMusicSoundFile)
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    
    //MARK: Background stuff
    func createBackground(){
        
        if self.currentLevel == 1 {
        
            for i in 0...3{
                if i == 1 || i == 3{
                    let bg = SKSpriteNode.init(imageNamed: "lala")
                    bg.name = "bg"
                    bg.size = CGSize.init(width: self.size.width, height: self.size.height)
                    bg.position = CGPoint.init(x: 0, y: CGFloat(i) * self.size.height)
                    bg.anchorPoint = CGPoint.init(x: 0.0, y: 0.0)
                    bg.zPosition = -10;
                    self.addChild(bg)
                }
                else{
                    let bg = SKSpriteNode.init(imageNamed: self.currentBackgroundImage)
                    bg.name = "bg"
                    bg.size = CGSize.init(width: self.size.width, height: self.size.height)
                    bg.position = CGPoint.init(x: 0, y: CGFloat(i) * self.size.height)
                    bg.anchorPoint = CGPoint.init(x: 0.0, y: 0.0)
                    bg.zPosition = -10;
                    self.addChild(bg)
                }
            }
        }
        else{
            self.enumerateChildNodes(withName: "bg", using: ({
                
                (node,error) in
                
                (node as! SKSpriteNode).texture = SKTexture.init(imageNamed: self.currentBackgroundImage)
                
            }))
        }
        
        
        
    }
   
    func moveBackground() {
        self.enumerateChildNodes(withName: "bg", using: ({
        
        (node,error) in
            
            node.position.y = node.position.y - 20;
            
            if node.position.y  < -((self.size.height)){
                node.position.y = node.position.y + (self.size.height)*3
            }
        
        }))
    }
 
    //MARK: Random Number Generators
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addObsticles() {
        
        let typeOf = random();
        var object = SKSpriteNode()
        if Float.init(typeOf) > self.obsticleThreshold {
            let obsticleTexture = SKTexture(imageNamed: currentObsticleImage)
            object = SKSpriteNode(texture: obsticleTexture)
            object.physicsBody?.categoryBitMask = PhysicsCategory.Obsticle // 3
            object.physicsBody?.contactTestBitMask = PhysicsCategory.Ship // 4
            object.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: obsticleTexture.size().width, height: obsticleTexture.size().height))
 
            object.name = "obsticle"
            object.physicsBody?.usesPreciseCollisionDetection = true

        }
        else{
            object = SKSpriteNode.init(imageNamed: currentGemImage)
            object.physicsBody?.categoryBitMask = PhysicsCategory.Food // 3
            object.physicsBody?.contactTestBitMask = PhysicsCategory.None // 4
            object.name = "food"
            object.physicsBody = SKPhysicsBody(rectangleOf: object.size)


        }
        
        object.physicsBody?.isDynamic = true // 2
        object.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        
        let actualX = random(min: object.size.width/2, max: size.width - object.size.width/2)

        object.position = CGPoint(x: actualX, y: size.height - object.size.height/2)
        
        addChild(object)
        
        let actualDuration = random(min: CGFloat(4.0), max: CGFloat(8.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: 0), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.run() {
        }
        object.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
    }
    //MARK: LEVEL UPDATES
    func makeChangesForLevel(level: Int){
        switch level {
        case 1:
                self.currentLevel = 1;
                createBackground()
                self.currentGemImage = self.level_1_gem
                self.currentObsticleImage = self.level_1_obsticle
                self.obsticleThreshold = self.level_1_obsticleThreshold
                self.foodThreshold = 1 - self.level_1_obsticleThreshold
                self.currentBackgroundImage = self.level_1_backgroundImage
                self.current_per_second_points = self.perSecond_points_level_1
                self.current_kill_points = self.kill_points_level_1
                self.current_gem_points = self.gem_points_level_1
                break;
        case 2:
                self.currentLevel = 2;
                self.currentGemImage = self.level_2_gem
                self.currentObsticleImage = self.level_2_obsticle
                self.obsticleThreshold = self.level_2_obsticleThreshold
                self.foodThreshold = 1 - self.level_2_obsticleThreshold
                self.currentBackgroundImage = self.level_2_backgroundImage
                createBackground()
                self.current_per_second_points = self.perSecond_points_level_2
                self.current_kill_points = self.kill_points_level_2
                self.current_gem_points = self.gem_points_level_2
                break;
        case 3:
                self.currentLevel = 3;
                self.currentGemImage = self.level_3_gem
                self.currentObsticleImage = self.level_3_obsticle
                self.obsticleThreshold = self.level_3_obsticleThreshold
                self.foodThreshold = 1 - self.level_3_obsticleThreshold
                self.currentBackgroundImage = self.level_3_backgroundImage
                createBackground()
                self.current_per_second_points = self.perSecond_points_level_3
                self.current_kill_points = self.kill_points_level_3
                self.current_gem_points = self.gem_points_level_3
                break;
        case 4:
                self.currentLevel = 4;
                self.currentGemImage = self.level_4_gem
                self.currentObsticleImage = self.level_4_obsticle
                self.obsticleThreshold = self.level_4_obsticleThreshold
                self.foodThreshold = 1 - self.level_4_obsticleThreshold
                self.currentBackgroundImage = self.level_4_backgroundImage
                createBackground()
                self.current_per_second_points = self.perSecond_points_level_4
                self.current_kill_points = self.kill_points_level_4
                self.current_gem_points = self.gem_points_level_4
                break;
        default:
                self.currentLevel = 1;
                createBackground()
                self.currentGemImage = self.level_1_gem
                self.currentObsticleImage = self.level_1_obsticle
                self.obsticleThreshold = self.level_1_obsticleThreshold
                self.foodThreshold = 1 - self.level_1_obsticleThreshold
                self.currentBackgroundImage = self.level_1_backgroundImage
                self.current_per_second_points = self.perSecond_points_level_1
                self.current_kill_points = self.kill_points_level_1
                self.current_gem_points = self.gem_points_level_1
        }
    }
    
}
