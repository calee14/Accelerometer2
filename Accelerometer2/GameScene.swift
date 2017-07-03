//
//  GameScene.swift
//  Acellerometer
//
//  Created by Cappillen on 6/23/17.
//  Copyright © 2017 Cappillen. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import Foundation

enum Direction {
    case up, down, right, left, still
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let motionManager = CMMotionManager()
    var dir: Direction = .still
    
    //Fixed Delta
    var fixedDelta: CFTimeInterval = 1.0/60.0 //60 FPS
    //Connect objects
    var spaceShip: SKSpriteNode!
    var obstaclelayer: SKNode!
    var obstacleSource: SKNode!
    var spawnTimer: CFTimeInterval = 0
    var scrollSpd: CGFloat = 100
    var prevCount = 4
    var count = 4
    var prevSpacePosition: CGPoint!
    
    override func didMove(to view: SKView) {
        //Start your scene here
        
        physicsWorld.contactDelegate = self
        //Get reference to the UI objects
        
        //Connect spaceShip
        spaceShip = self.childNode(withName: "node") as! SKSpriteNode
        //Connect obstacleLayer
        obstaclelayer = self.childNode(withName: "obstacleLayer")
        //Connect obstacle
        obstacleSource = self.childNode(withName: "obstacle")
        
        //Declaring swipe gestures
        //Creating the Swipe Right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GameScene().swiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view?.addGestureRecognizer(swipeRight)
        //Creating the Swipe Down
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GameScene().swiped(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view?.addGestureRecognizer(swipeDown)
        //Creating the SwipeUp
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GameScene().swiped(_:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view?.addGestureRecognizer(swipeUp)
        //Creating the SwipeLeft
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameScene().swiped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view?.addGestureRecognizer(swipeLeft)
        
        //Creates a border the size of the frame
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        //self.physicsBody = border
        
        //Starts the accelerometer updates
        motionManager.startAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = 0.1
        print("starting up the acceleromter")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let shakeScene = SKAction.run({
            let shake = SKAction.init(named: "Shake")
            for node in self.children {
                node.run(shake!)
            }
        })
        self.spaceShip.run(shakeScene)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        if nodeA.name == "node" {
            prevSpacePosition = spaceShip.position
            count -= 1
        } else if nodeB.name == "node" {
            prevSpacePosition = spaceShip.position
            count -= 1
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        checkIfCollided()
        //Warp thingy
        warpy()
        
        //The accelerometer
        updateAcellerometerData()
        
        //Check direction
        //checkDirection()
        
        //Spawns the obstacles
        updateObstacles()
        spawnTimer += fixedDelta
        
    }
    
    func checkIfCollided() {
        if prevCount > count {
            if spaceShip.position.x > prevSpacePosition.x - 72.5 {
                spaceShip.position.x -= 1.25
            } else if prevCount > count {
                prevSpacePosition = spaceShip.position
                prevCount -= 1
            }
        }
    }
    func swiped(_ gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            //Switch function if the player swiped up, down, left, right
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                dir = .right
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
                dir = .down
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                dir = .left
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                dir = .up
            default:
                break
            }
        }
    }
    
    func checkDirection() {
        if dir == .right {
            spaceShip.position.x += 5
        } else if dir == .left {
            spaceShip.position.x -= 5
        } else if dir == .up {
            spaceShip.position.y += 5
        } else if dir == .down {
            spaceShip.position.y -= 5
        } else if dir == .still {
            return
        }
    }
    
    
    func updateAcellerometerData() {
        //While accelerometerData is active and force is being applied Clamp speed
        spaceShip.physicsBody?.velocity.dx.clamp(v1: -600, 600)
        spaceShip.physicsBody?.velocity.dy.clamp(v1: -600, 600)
        
        //TODO: Check the data
        //print("turbines to speed")
        guard let data = motionManager.accelerometerData else { return }
        
        //Applying the force to the spaceShip
        /*spaceShip.physicsBody?.applyForce(CGVector(dx: 700 * CGFloat(data.acceleration.y), dy: -700 * CGFloat(data.acceleration.x))) */
        
        //Applying movement according to the data
        spaceShip.position = CGPoint(x: spaceShip.position.x, y: CGFloat(spaceShip.position.y) + CGFloat(-7 * data.acceleration.x))
        //print("other \(data)")
    }
    
    func warpy() {
        //Creates the warp
        if spaceShip.position.x < 0 {
            spaceShip.position.x = 583
        } else if spaceShip.position.x > 583 {
            spaceShip.position.x = 0
        }
        if spaceShip.position.y < 0 {
            spaceShip.position.y = 320
        } else if spaceShip.position.y > 320{
            spaceShip.position.y = 0
        }
    }
    
    func updateObstacles() {
        /* Update obstacles*/
        
        obstaclelayer.position.x -= scrollSpd * CGFloat(fixedDelta)
        
        //Loop through the obstacle layer nodes
        for obstacles in obstaclelayer.children as! [SKSpriteNode] {
            
            //Set reference to the obstacle position
            let obstaclePosition = obstaclelayer.convert(obstacles.position, to: self)
            
            //Check if the obstacle left the scene
            if obstaclePosition.x <= -26 {
                //26 if half of the objects width
                
                //Remove the obstacle node
                obstacles.removeFromParent()
            }
        }
        //Add new obstacles
        if spawnTimer >= 2.5 {
            
            //Set reference of the new obstacle
            let newObstacle = obstacleSource.copy() as! SKNode
            obstaclelayer.addChild(newObstacle)
            
            //Generate new random y position
            let randomPosition = CGPoint(x: obstacleSource.position.x, y: CGFloat.random(min: 160, max: 295))
            
            //Converts new obstacles position to the new position to the obstacle layer
            newObstacle.position = self.convert(randomPosition, to: obstaclelayer)
            
            //Add second obstacle to bottom half
            let secondObstacle = obstacleSource.copy() as! SKNode
            obstaclelayer.addChild(secondObstacle)
            
            //Generate the random y position
            let secondRandomPosition = CGPoint(x: obstacleSource.position.x , y: CGFloat.random(min: 25, max: 145))
            
            //Conver the new postion to the new obstacle
            secondObstacle.position = self.convert(secondRandomPosition, to: obstaclelayer)
            
            //Reset Timer
            spawnTimer = 0
            
        }
    }

    func stopUpdates() {
        print("stop updating the data")
        motionManager.stopAccelerometerUpdates()
    }
}

