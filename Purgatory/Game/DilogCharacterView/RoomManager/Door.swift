import SpriteKit

final class Door: SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let id: String
    var wasEntered: Bool
    
    init(id: String, wasEntered: Bool, size: CGSize) {
        self.id = id
        self.wasEntered = wasEntered
        super.init(texture: SKTexture(image: .wft), color: .clear, size: size)
        setUpTriggerRadius()
    }
    
    private func setUpTriggerRadius() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.door
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.character
    }
    
}
