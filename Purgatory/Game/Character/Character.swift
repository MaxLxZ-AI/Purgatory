import SpriteKit

class GameCharacter: SKSpriteNode {
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
    var lastDirection: Direction = .none
    
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
        physicsBody?.collisionBitMask = PhysicsCategory.dialogTrigger | PhysicsCategory.wall | PhysicsCategory.door
        physicsBody?.contactTestBitMask = PhysicsCategory.dialogTrigger | PhysicsCategory.firstDialogTrigger | PhysicsCategory.wall | PhysicsCategory.door

        
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
        
        let newPosition = CGPoint(
            x: position.x + currentDirection.vector.dx * moveSpeed * 0.016,
            y: position.y + currentDirection.vector.dy * moveSpeed * 0.016
        )
        
        guard let scene = scene else { return }
        
        guard scene.size.width > 0 && scene.size.height > 0 else { return }
        
        let sceneSize = scene.size
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        
        let minX = halfWidth
        let maxX = sceneSize.width - halfWidth
        let minY = halfHeight
        let maxY = sceneSize.height - halfHeight
        
        if newPosition.x < minX || newPosition.x > maxX ||
           newPosition.y < minY || newPosition.y > maxY {
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
        if !canMoveInDirection(direction) {
//            print("Cannot move in direction: \(direction) - obstacle detected")
            return
        }
        
        currentDirection = direction
        isWalking = true
    }
    
    private func canMoveInDirection(_ direction: Direction) -> Bool {
        guard let scene = scene else { return false }
        
        // Дополнительная проверка на валидность scene
        guard scene.size.width > 0 && scene.size.height > 0 else { return false }
        
        let checkDistance: CGFloat = size.width / 2 + 5
        let checkPosition = CGPoint(
            x: position.x + direction.vector.dx * checkDistance,
            y: position.y + direction.vector.dy * checkDistance
        )
        
        let bodies = scene.physicsWorld.body(at: checkPosition)
        if let body = bodies {
            if body.categoryBitMask == PhysicsCategory.wall {
                return false
            }
        }
        
        return true
    }
    
    func stopMoving() {
        lastDirection = currentDirection
        isWalking = false
        physicsBody?.velocity = .zero
        currentDirection = .none
    }
    
    func moveToPosition(_ position: CGPoint, duration: TimeInterval, completion: (() -> Void)? = nil) {
        let dx = position.x - self.position.x
        let dy = position.y - self.position.y
        if abs(dx) > abs(dy) {
            currentDirection = dx > 0 ? .right : .left
        } else {
            currentDirection = dy > 0 ? .up : .down
        }
        updateDirection()
        isWalking = true

        let moveAction = SKAction.move(to: position, duration: duration)
        let stopAction = SKAction.run { [weak self] in
            self?.isWalking = false
            self?.stopMoving()
            completion?()
        }
        let sequence = SKAction.sequence([moveAction, stopAction])
        run(sequence)
    }
}


final class Enri: GameCharacter {
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

final class Emma: GameCharacter {
    
    weak var leader: GameCharacter?
    var followDistance: CGFloat = 100.0
    var followDelay: TimeInterval = 0.3
    private var lastLeaderPosition: CGPoint?
    private var leaderPositions: [CGPoint] = []
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
    
    func setupFollowing(leader: GameCharacter) {
        self.leader = leader
        self.lastLeaderPosition = leader.position
    }
    
    func removeLeader() {
        self.leader = nil
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
                
               
                
                if !isWalking {
                    updateFollowingDirection(dx: directionX, dy: directionY)
                    isWalking = true
                }
               
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
        updateDirection()
    }
}


