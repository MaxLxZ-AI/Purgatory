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
    private var moveSpeed: CGFloat = 150.0
    
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
}
