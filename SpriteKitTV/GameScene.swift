//
//  GameScene.swift
//  SpriteKitTV
//
//  Created by Avinash Mudivedu on 4/16/16.
//  Copyright (c) 2016 Avinash Mudivedu. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
    static let Player    : UInt32 = 0b100     // 4
}

class GameConstants {
    static let moveDistance = CGFloat(20.0)
    static let moveDuration = 0.1
    static let moveLeft = CGPoint(x: -moveDistance, y: 0.0)
    static let moveRight = CGPoint(x: moveDistance, y: 0.0)
    static let moveUp = CGPoint(x: 0.0, y: moveDistance)
    static let moveDown = CGPoint(x: 0.0, y: -moveDistance)
}

extension Int {
    var degreesToRadians: Double { return Double(self) * M_PI / 180 }
    var radiansToDegrees: Double { return Double(self) * 180 / M_PI }
}

extension Double {
    var degreesToRadians: Double { return self * M_PI / 180 }
    var radiansToDegrees: Double { return self * 180 / M_PI }
}

extension CGFloat {
    var doubleValue:      Double  { return Double(self) }
    var degreesToRadians: CGFloat { return CGFloat(doubleValue * M_PI / 180) }
    var radiansToDegrees: CGFloat { return CGFloat(doubleValue * 180 / M_PI) }
}

extension Float  {
    var doubleValue:      Double { return Double(self) }
    var degreesToRadians: Float  { return Float(doubleValue * M_PI / 180) }
    var radiansToDegrees: Float  { return Float(doubleValue * 180 / M_PI) }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    
    /*
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 65
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)
    }
     */
    
    var monstersDestroyed = 0
    
    // 1
    let player = SKSpriteNode(imageNamed: "tank")
    let grass = SKSpriteNode(imageNamed: "grass")
    
    override func didMoveToView(view: SKView) {
        
        
        
        setupControls()

        grass.anchorPoint = CGPointMake(0.5, 0.5)
        grass.size.height = size.height
        grass.size.width = size.width
        grass.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        addChild(grass)
        
        
        //backgroundColor = SKColor.darkGrayColor()
        // 3
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.zRotation = CGFloat(90.0.degreesToRadians)
        // 4
        addChild(player)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    
    func upArrow(gesture: UITapGestureRecognizer) {
        
        let moveBy = CGPoint(x: sin(-player.zRotation), y: cos(player.zRotation)) * -GameConstants.moveDistance
        //        print(player.zRotation)
        //        print(moveBy)
        let newPosition = player.position + moveBy
        let action = SKAction.moveTo(newPosition, duration:GameConstants.moveDuration)
        self.player.runAction(action)
    }
    func downArrow(gesture: UITapGestureRecognizer) {
        let moveBy = CGPoint(x: sin(-player.zRotation), y: cos(player.zRotation)) * GameConstants.moveDistance
        let newPosition = player.position + moveBy
        let action = SKAction.moveTo(newPosition, duration:GameConstants.moveDuration)
        self.player.runAction(action)
    }
    func leftArrow(gesture: UITapGestureRecognizer) {
        let newPosition = player.position + GameConstants.moveLeft
        //        let action = SKAction.moveTo(newPosition, duration:GameConstants.moveDuration)
        let action2 = SKAction.rotateByAngle(CGFloat(M_PI/2.0), duration:GameConstants.moveDuration)
        self.player.runAction(action2)
    }
    func rightArrow(gesture: UITapGestureRecognizer) {
        let newPosition = player.position + GameConstants.moveRight
        //        let action = SKAction.moveTo(newPosition, duration:GameConstants.moveDuration)
        let action2 = SKAction.rotateByAngle(CGFloat(-M_PI/2.0), duration:GameConstants.moveDuration)
        self.player.runAction(action2)
    }
    
    
    
    
    func setupControls() {
        let tapRecognizer1 = UITapGestureRecognizer(target: self, action: "upArrow:")
        tapRecognizer1.allowedPressTypes = [NSNumber(integer: UIPressType.UpArrow.rawValue)];
        self.view!.addGestureRecognizer(tapRecognizer1)
        
        let tapRecognizer2 = UITapGestureRecognizer(target: self, action: "downArrow:")
        tapRecognizer2.allowedPressTypes = [NSNumber(integer: UIPressType.DownArrow.rawValue)];
        self.view!.addGestureRecognizer(tapRecognizer2)
        
        let tapRecognizer3 = UITapGestureRecognizer(target: self, action: "leftArrow:")
        tapRecognizer3.allowedPressTypes = [NSNumber(integer: UIPressType.LeftArrow.rawValue)];
        self.view!.addGestureRecognizer(tapRecognizer3)
        
        let tapRecognizer4 = UITapGestureRecognizer(target: self, action: "rightArrow:")
        tapRecognizer4.allowedPressTypes = [NSNumber(integer: UIPressType.RightArrow.rawValue)];
        self.view!.addGestureRecognizer(tapRecognizer4)
    }
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {

        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "tank")
        monster.color = UIColor.redColor()
        
        monster.colorBlendFactor = 0.9
        monster.zRotation = CGFloat(-90.0.degreesToRadians)
        
        
        // Determine where to spawn the monster along the Y axis
        let actualX = random(min: 0, max: size.width)
        let actualY = random(min: 0, max: size.height)
        
        let choice = Int(arc4random_uniform(4))
        
        switch choice {
        case 0:
            monster.position = CGPoint(x: 0, y: actualY)
        case 1:
            monster.position = CGPoint(x: size.width, y: actualY)
        case 2:
            monster.position = CGPoint(x: actualX, y: 0)
        case 3:
            monster.position = CGPoint(x: actualX, y: size.height)
        default:
            break
        }
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
//        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Add the monster to the scene
        addChild(monster)
        
        
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(player.position, duration: 10.0)
        let actionMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.runAction(SKAction.sequence([actionMove]))
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
//        print(touchLocation)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width*2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.affectedByGravity = true
        
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
        
//        monstersDestroyed += 1
//        if (monstersDestroyed > 30) {
//            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
//            let gameOverScene = GameOverScene(size: self.size, won: true)
//            self.view?.presentScene(gameOverScene, transition: reveal)
//        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
    }
}

// MARK: - Operator overloads

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}
