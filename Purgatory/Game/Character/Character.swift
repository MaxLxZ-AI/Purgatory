import SpriteKit

class Character: SKSpriteNode {
    var calmState: SKTexture
    let character: Characters
    var walkingTextures: [SKTexture] = Constants.CharactersTextures.Enri.Walk.down
    var isWalking = false {
        didSet {
            updateMovement()
            updateAnimation()
        }
    }
    
    private var walkingAction: SKAction?
    var moveSpeed: CGFloat = 150.0
    
    var currentDirection: Direction = .none
    private var lastDirection: Direction = .none
    
    private var lastState = SKTexture()
    
    init(character: Characters, calmState: SKTexture, size: CGSize) {
        self.character = character
        self.calmState = calmState
        super.init(texture: calmState, color: .clear, size: size)
        setupCharacter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCharacter() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.character
        physicsBody?.collisionBitMask = PhysicsCategory.dialogTrigger
        physicsBody?.contactTestBitMask = PhysicsCategory.dialogTrigger | PhysicsCategory.firstDialogTrigger

        
        createWalkingAction()
    }
    private func createWalkingAction() {
        walkingAction = SKAction.repeatForever(
            SKAction.animate(with: walkingTextures, timePerFrame: 0.15)
        )
    }
    
    
   private func updateAnimation() {
        removeAllActions()
        
        if isWalking {
            createWalkingAction()
            run(walkingAction!)
            
        } else {
            texture = calmState
        }
    }
    
    func updateDirection() {
    }
    

    

    
    private func updateVelocity() {
        if currentDirection == .none && isWalking {
            stopMoving()
            return
        }
        
        let velocity = CGVector(
            dx: currentDirection.vector.dx * moveSpeed,
            dy: currentDirection.vector.dy * moveSpeed
        )
        
        physicsBody?.velocity = velocity
    }
    
    func updateMovement() {
        updateDirection()
        updateVelocity()
    }
    
    func startMoving(in direction: Direction) {
        currentDirection = direction
        isWalking = true
    }
    
    func stopMoving() {
        lastDirection = currentDirection
        isWalking = false
        physicsBody?.velocity = .zero
        currentDirection = .none
    }
}


final class Enri: Character {
    override func updateDirection() {
        enriTextures()
    }
    
    private func enriTextures() {
        if let walk = currentDirection.enriWalkTextures {
            walkingTextures = walk
        }
        
        if let calm = currentDirection.enriCalmTextures {
            calmState = calm
        }
    }
}

final class Emma: Character {
    
    weak var leader: Character?  // The character to follow (Enri)
    var followDistance: CGFloat = 100.0  // Distance to maintain from leader
    var followDelay: TimeInterval = 0.3  // Delay before starting to follow
    private var lastLeaderPosition: CGPoint?
    private var leaderPositions: [CGPoint] = []  // Trail of leader positions
    private let maxTrailLength = 10
    
    override func updateDirection() {
        emmaTextures()
    }
    
    private func emmaTextures() {
        if let walk = currentDirection.emmaWalkTextures {
            walkingTextures = walk
        }
        
        if let calm = currentDirection.emmaCalmTextures {
            calmState = calm
        }
    }
    
    func setupFollowing(leader: Character) {
        self.leader = leader
        self.lastLeaderPosition = leader.position
    }
    
    func updateFollowing() {
        guard let leader = leader else { return }
        
        // Record leader's position
        leaderPositions.append(leader.position)
        if leaderPositions.count > maxTrailLength {
            leaderPositions.removeFirst()
        }
        
        // Only move if leader has moved sufficiently
        let distanceToLeader = hypot(position.x - leader.position.x,
                                   position.y - leader.position.y)
        
        if distanceToLeader > followDistance {
            let targetIndex = min(Int(followDelay * 10), leaderPositions.count - 1)
            let targetPosition = leaderPositions[max(0, targetIndex)]
            
            // Calculate direction to target
            let dx = targetPosition.x - position.x
            let dy = targetPosition.y - position.y
            let distance = hypot(dx, dy)
            
            // Normalize direction and apply speed
            if distance >=   5 {
                let directionX = dx / distance
                let directionY = dy / distance
                
                updateFollowingDirection(dx: directionX, dy: directionY)
                
                if !isWalking {
                    isWalking = true
                }
               
                print(currentDirection)
                physicsBody?.velocity = CGVector(
                                   dx: (dx / distance) * moveSpeed ,
                                   dy: (dy / distance) * moveSpeed
                               )
            } else {
                stopMoving()
            }
        } else {
            stopMoving()
        }
    }
    
    private func updateFollowingDirection(dx: CGFloat, dy: CGFloat) {
        if abs(dx) > abs(dy) {
            currentDirection = dx > 0 ? .right : .left
        } else {
            currentDirection = dy > 0 ? .up : .down
        }
        updateDirection() // Update textures based on direction
    }
}
