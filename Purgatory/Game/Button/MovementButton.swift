import SpriteKit

final class MovementButton: SKSpriteNode {
    
    init(size: CGSize) {
        super.init(texture: nil, color: .white, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setUpButton() {
        name = "down"
        alpha = 0.5
    }
}
