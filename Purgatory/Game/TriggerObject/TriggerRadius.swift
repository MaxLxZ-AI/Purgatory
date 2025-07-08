import SpriteKit

class TriggerRadius: SKSpriteNode {
    var wasDialogTriggered = false
    weak var parentTrigger: DialogTriggerNode?
    init(radius: CGFloat) {
        super.init(texture: nil, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        setUpTriggerRadius()
    }
    
    private func setUpTriggerRadius() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.firstDialogTrigger
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.character
        
        // Optional debug visualization
        let circle = SKShapeNode(circleOfRadius: size.width/2)
        circle.strokeColor = .green.withAlphaComponent(0.3)
        circle.lineWidth = 2
        circle.fillColor = .clear
        addChild(circle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
