import SpriteKit

final class Character: SKSpriteNode {
    var calmState: SKTexture
    var walkingTextures: [SKTexture] = Constants.Characters.Enri.Walk.down
    var isWalking = false {
        didSet {
            updateMovement()
            updateAnimation()
            
        }
    }
    
    private var walkingAction: SKAction?
    private var moveSpeed: CGFloat = 150.0
    
    private var currentDirection: Direction = .none
    private var lastDirection: Direction = .none
    
    private var lastState = SKTexture()
    
    init(calmState: SKTexture, size: CGSize) {
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
    
    private func updateDirection() {
        switch currentDirection {
        case .up:
            walkingTextures = Constants.Characters.Enri.Walk.up
            calmState = Constants.Characters.Enri.Calm.up
            lastState = calmState
        case .down:
            walkingTextures = Constants.Characters.Enri.Walk.down
            calmState = Constants.Characters.Enri.Calm.down
            lastState = calmState
        case .left:
            walkingTextures = Constants.Characters.Enri.Walk.leftEnri
            calmState = Constants.Characters.Enri.Calm.left
            lastState = calmState
        case .right:
            walkingTextures = Constants.Characters.Enri.Walk.right
            calmState = Constants.Characters.Enri.Calm.right
            lastState = calmState
        case .none:
            calmState = lastState
        }
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
    
    private func updateMovement() {
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
