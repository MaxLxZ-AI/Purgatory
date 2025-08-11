import SpriteKit

final class Wall: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let wallTexture: SKTexture?
    
    init(wallTexture: SKTexture?, size: CGSize) {
        self.wallTexture = wallTexture
        super.init(texture: wallTexture, color: .blue, size: size)
        setUpWall()
    }
    
    private func setUpWall() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.wall
        physicsBody?.collisionBitMask = PhysicsCategory.character
        physicsBody?.contactTestBitMask = PhysicsCategory.character
    }
}
