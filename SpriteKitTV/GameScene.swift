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
    static let Goal      : UInt32 = 0b1000    // 8
    static let Border    : UInt32 = 0b10000   // 16

}

class GameConstants {
    static let playerAngularVelocity = CGFloat(1)
    static let playerVelocity = 100.0
    
    static let moveDistance = CGFloat(5.0)
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
    
    var goalCount = 0
    
    // 1
    let player = SKSpriteNode(imageNamed: "tank")
    let grass = SKSpriteNode(imageNamed: "grass")
    
    override func didMoveToView(view: SKView) {
        
        
        
        setupControls()
        setupBorders()
        setupGoal()
        setupPlayer()
        setupBackground()
        
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(fireBullet),
                SKAction.waitForDuration(0.75)
                ])
            ))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addField),
                SKAction.waitForDuration(5.0)
                ])
            ))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addField2),
                SKAction.waitForDuration(3.3)
                ])
            ))
        
        
    }
    
    func setupPlayer() {
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        player.zRotation = CGFloat(180.0.degreesToRadians)
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        if let physics = player.physicsBody {
            physics.affectedByGravity = false
            physics.allowsRotation = false
            physics.dynamic = true
            physics.categoryBitMask = PhysicsCategory.Player
            physics.contactTestBitMask = PhysicsCategory.Monster
            physics.collisionBitMask = PhysicsCategory.Border | PhysicsCategory.Monster | PhysicsCategory.Goal
            //            physics.pinned = true
            //            physics.angularDamping = 1.0
        }
        
        
        addChild(player)
    }
    
    func setupBackground() {
        grass.anchorPoint = CGPointMake(0.5, 0.5)
        grass.size.height = size.height
        grass.size.width = size.width
        grass.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        //        addChild(grass)
        
        
        backgroundColor = SKColor.blackColor()
        
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.3)
        physicsWorld.contactDelegate = self
        
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    
    func setupGoal() {
        
        let goal = SKSpriteNode(imageNamed: "nemo")
        
        goal.xScale = 0.1
        goal.yScale = 0.1
        goal.position = CGPointMake(100, size.height - 100)
        goal.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "nemo"), size: goal.size)
        if let physics = goal.physicsBody {
            physics.dynamic = false
            physics.affectedByGravity = false
            physics.categoryBitMask = PhysicsCategory.Goal
            physics.contactTestBitMask = PhysicsCategory.Projectile
            physics.collisionBitMask = PhysicsCategory.None
        }
        
        let startingPosition = goal.position
        let finalPosition = CGPoint(x: size.width - 100, y: size.height - 100)
        let action1 = SKAction.moveTo(finalPosition, duration: Double(4.0))
        let action2 = SKAction.moveTo(startingPosition, duration: Double(4.0))
        goal.runAction(SKAction.repeatActionForever(SKAction.sequence([action1, action2])))
            
        
        addChild(goal)
        
    }
    
    func setupBorders() {
        
        let border1 = SKSpriteNode(color: UIColor.blueColor(), size: CGSize(width: size.width*2, height: 100))
        let border2 = SKSpriteNode(color: UIColor.blueColor(), size: CGSize(width: size.width*2, height: 100))
        let border3 = SKSpriteNode(color: UIColor.blueColor(), size: CGSize(width: 100, height: size.height*2))
        let border4 = SKSpriteNode(color: UIColor.blueColor(), size: CGSize(width: 100, height: size.height*2))
        
        border1.position = CGPoint(x: size.width/2, y: size.height + 100)
        border2.position = CGPoint(x: size.width/2, y: -100)
        border3.position = CGPoint(x: size.width + 100, y: size.height/2)
        border4.position = CGPoint(x: -100, y: size.height/2)
        
        let borders = [border1, border2, border3, border4]
        
        for border in borders {
            border.physicsBody = SKPhysicsBody(rectangleOfSize: border.size)
        
            if let physics = border.physicsBody {
                physics.pinned = true
                physics.allowsRotation = false
                physics.affectedByGravity = false
                physics.dynamic = false
                physics.categoryBitMask = PhysicsCategory.Border
                physics.contactTestBitMask = PhysicsCategory.Projectile
                physics.collisionBitMask = PhysicsCategory.None
                physics.usesPreciseCollisionDetection = true
            }
            addChild(border)
        }
        
    }

    
    func fireBullet () {
        
        let projectile = SKSpriteNode(imageNamed: "bubble")
        projectile.position = player.position
        projectile.xScale = 0.1
        projectile.yScale = 0.1

        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        if let physics = projectile.physicsBody {
            physics.dynamic = true
            physics.affectedByGravity = true
            physics.allowsRotation = true
            physics.categoryBitMask = PhysicsCategory.Projectile
            physics.contactTestBitMask = PhysicsCategory.Monster
            physics.collisionBitMask = PhysicsCategory.None
            physics.usesPreciseCollisionDetection = true
            physics.angularVelocity = 5.0
        }
        
        let offset = CGPoint(x: sin(player.zRotation), y: -cos(player.zRotation))

        
        let direction = offset.normalized() * 200
        
        projectile.physicsBody?.velocity = CGVectorMake(direction.x, direction.y)
        
        
        addChild(projectile)
        
        
    }
    
    func addField() {

        
        let actualY = random(min: size.height/2, max: size.height - 200)
        
        let fish = SKSpriteNode(imageNamed: "fish2")
        fish.xScale = 0.3
        fish.yScale = 0.3
        fish.position = CGPointMake(size.width, actualY)
        fish.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "fish2"), alphaThreshold: 0.999, size: fish.size)
        if let physics = fish.physicsBody {
            physics.dynamic = true
            physics.affectedByGravity = false
            physics.categoryBitMask = PhysicsCategory.Monster
            physics.contactTestBitMask = PhysicsCategory.Projectile
            physics.collisionBitMask = PhysicsCategory.None
        }
        addChild(fish)
        
        // Determine where to spawn the monster along the Y axis
        
        let finalPosition = CGPoint(x: 0.0, y: actualY)
     
//        var field : SKFieldNode
        
//        let randomInt = Int(arc4random_uniform(4))
        
//        field = SKFieldNode.vortexField()
        let radialGravityField = SKFieldNode.radialGravityField()
//        let radialGravityField = SKFieldNode.dragField()
//        let radialGravityField = SKFieldNode.springField()
        
        radialGravityField.position = CGPoint(x: size.width, y: actualY)
        radialGravityField.strength = 2
        radialGravityField.falloff = 0.6
        radialGravityField.physicsBody?.categoryBitMask = PhysicsCategory.None
        radialGravityField.physicsBody?.contactTestBitMask = PhysicsCategory.None
        radialGravityField.physicsBody?.collisionBitMask = PhysicsCategory.None
        radialGravityField.region = SKRegion(radius: 300.0)
        
        addChild(radialGravityField)
        
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(4.0), max: CGFloat(8.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(finalPosition, duration: Double(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
//        let loseAction = SKAction.runBlock() {
//            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
//            let gameOverScene = GameOverScene(size: self.size, won: false)
//            self.view?.presentScene(gameOverScene, transition: reveal)
//        }
        radialGravityField.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        fish.runAction(SKAction.sequence([actionMove,actionMoveDone]))
        
    }
    
    func addField2() {
        
        
        let actualY = random(min: 200, max: size.height/2)
        
        let fish = SKSpriteNode(imageNamed: "fish1")
        fish.xScale = 0.3
        fish.yScale = 0.3
        fish.position = CGPointMake(0.0, actualY)
        fish.physicsBody = SKPhysicsBody(circleOfRadius: fish.size.height/2)
        if let physics = fish.physicsBody {
            physics.dynamic = true
            physics.affectedByGravity = false
            physics.categoryBitMask = PhysicsCategory.Monster
            physics.contactTestBitMask = PhysicsCategory.Projectile
            physics.collisionBitMask = PhysicsCategory.None
        }
        addChild(fish)
        
        // Determine where to spawn the monster along the Y axis
        
        let finalPosition = CGPoint(x: size.width, y: actualY)
        
        //        var field : SKFieldNode
        
        //        let randomInt = Int(arc4random_uniform(4))
        
        //        field = SKFieldNode.vortexField()
        let radialGravityField = SKFieldNode.radialGravityField()
        //        let radialGravityField = SKFieldNode.dragField()
        //        let radialGravityField = SKFieldNode.springField()
        
        radialGravityField.position = CGPoint(x: 0.0, y: actualY)
        radialGravityField.strength = 3
        radialGravityField.falloff = 0.6
        radialGravityField.physicsBody?.categoryBitMask = PhysicsCategory.None
        radialGravityField.physicsBody?.contactTestBitMask = PhysicsCategory.None
        radialGravityField.physicsBody?.collisionBitMask = PhysicsCategory.None
        radialGravityField.region = SKRegion(radius: 400.0)
        
        addChild(radialGravityField)
        
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(4.0), max: CGFloat(8.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(finalPosition, duration: Double(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        //        let loseAction = SKAction.runBlock() {
        //            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        //            let gameOverScene = GameOverScene(size: self.size, won: false)
        //            self.view?.presentScene(gameOverScene, transition: reveal)
        //        }
        radialGravityField.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        fish.runAction(SKAction.sequence([actionMove,actionMoveDone]))
        
    }
    
    func setupControls() {
        let uipgr = UIPanGestureRecognizer(target: self, action: "slidePlayer:")
        
        view?.addGestureRecognizer(uipgr)
    }
    
    func rotatePlayer(gesture: UIPanGestureRecognizer) {
//        let relativeLocation = gesture.translationInView(self.view)
        let relativeVelocity = gesture.velocityInView(self.view)
//        print("\(relativeLocation) : \(relativeVelocity)")
        
        switch gesture.state {
        case .Changed:
            if (relativeVelocity.x < 1) {
                player.physicsBody?.angularVelocity = GameConstants.playerAngularVelocity
            } else if (relativeVelocity.x > -1) {
                player.physicsBody?.angularVelocity = -GameConstants.playerAngularVelocity
            }
        default:
            player.physicsBody?.angularVelocity = 0.0
        }
    }
    
    func slidePlayer(gesture: UIPanGestureRecognizer) {
//        let relativeLocation = gesture.translationInView(self.view)
        let relativeVelocity = gesture.velocityInView(self.view)
        //        print("\(relativeLocation) : \(relativeVelocity)")
        
        switch gesture.state {
        case .Changed:
            let dx = (player.physicsBody?.velocity.dx)! + relativeVelocity.x/100.0
            let dy = (player.physicsBody?.velocity.dy)! - relativeVelocity.y/100.0
            
            player.physicsBody?.velocity = CGVectorMake(dx, dy)
            
            
        default:
            break
        }
    }
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func projectileDidCollideWithBorder(projectile:SKSpriteNode) {
//        print("Border")
        projectile.removeFromParent()
    }
    
    func projectileDidCollideWithGoal(projectile:SKSpriteNode) {
//        print("Goal")
        projectile.removeFromParent()
        ++self.goalCount
        
        if (goalCount > 30) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
    }
    
    
    func monsterDidCollideWithProjectile(projectile:SKSpriteNode) {
//        print("Monster")
        projectile.removeFromParent()
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Projectile != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Border != 0)) {
                if let node = firstBody.node {
                    projectileDidCollideWithBorder(node as! SKSpriteNode)
                }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Projectile != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Goal != 0)) {
                if let node = firstBody.node {
                    projectileDidCollideWithGoal(node as! SKSpriteNode)
                }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
                if let node = secondBody.node {
                    monsterDidCollideWithProjectile(node as! SKSpriteNode)
                }
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
