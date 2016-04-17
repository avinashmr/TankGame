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
    static let playerAngularVelocity = CGFloat(1)
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
        
//        addChild(grass)
        
        
        backgroundColor = SKColor.blackColor()
        
        // 3
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.zRotation = CGFloat(90.0.degreesToRadians)
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        if let physics = player.physicsBody {
            physics.affectedByGravity = false
            physics.allowsRotation = true
            physics.dynamic = true
            physics.categoryBitMask = PhysicsCategory.Player
            physics.contactTestBitMask = PhysicsCategory.Monster
            physics.collisionBitMask = PhysicsCategory.None
            physics.pinned = true
//            physics.angularDamping = 1.0
        }
        
        
        addChild(player)
        
        let radialGravityField = SKFieldNode.radialGravityField()
        radialGravityField.position = CGPoint(x: size.width/2, y: size.height/2)
        radialGravityField.strength = 10
        radialGravityField.region = SKRegion(radius: 200.0)
        
        addChild(radialGravityField)
        
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self

        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(fireBullet),
                SKAction.waitForDuration(1.0)
                ])
            ))
        
//        runAction(SKAction.repeatActionForever(
//            SKAction.sequence([
//                SKAction.runBlock(addField),
//                SKAction.waitForDuration(1.0)
//                ])
//            ))
        
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    


    
    func fireBullet () {
        
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        projectile.xScale = 3.0
        projectile.yScale = 3.0
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width*2)
        if let physics = projectile.physicsBody {
            physics.dynamic = true
            physics.affectedByGravity = true
            physics.allowsRotation = true
            physics.categoryBitMask = PhysicsCategory.Projectile
            physics.contactTestBitMask = PhysicsCategory.Monster
            physics.collisionBitMask = PhysicsCategory.None
            physics.usesPreciseCollisionDetection = true
        }
        
        let offset = CGPoint(x: sin(player.zRotation), y: -cos(player.zRotation))

        
        let direction = offset.normalized() * 200
        
        projectile.physicsBody?.velocity = CGVectorMake(direction.x, direction.y)
        
        
        addChild(projectile)
        
        
    }
    
    func addField() {
        
        
        
    }
    
    
    func setupControls() {
        let uipgr = UIPanGestureRecognizer(target: self, action: "rotatePlayer:")
        
        view?.addGestureRecognizer(uipgr)
    }
    
    func rotatePlayer(gesture: UIPanGestureRecognizer) {
        let relativeLocation = gesture.translationInView(self.view)
        let relativeVelocity = gesture.velocityInView(self.view)
//        print("\(relativeLocation) : \(relativeVelocity)")
        
        switch gesture.state {
        case .Changed:
            if (relativeVelocity.y < 1) {
                player.physicsBody?.angularVelocity = GameConstants.playerAngularVelocity
            } else if (relativeVelocity.y > -1) {
                player.physicsBody?.angularVelocity = -GameConstants.playerAngularVelocity
            }
        default:
            player.physicsBody?.angularVelocity = 0.0
        }
    }
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {

//        let radialGravityField = SKFieldNode.radialGravityField()
//        radialGravityField.position = CGPoint(x: size.width/2, y: size.height/2)
//        radialGravityField.strength = -1.0
//        
//        addChild(radialGravityField)
        
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "tank")
        monster.color = UIColor.redColor()
        
        monster.colorBlendFactor = 0.9
        monster.zRotation = CGFloat(-90.0.degreesToRadians)
        
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: 0, max: size.height)
        monster.position = CGPoint(x: size.width, y: actualY)
        
        
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.Monster // 5
        
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
//        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
//            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
//            projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
//        }
//        
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
