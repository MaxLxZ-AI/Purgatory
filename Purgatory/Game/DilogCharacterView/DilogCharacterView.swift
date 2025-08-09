import SpriteKit

final class DilogCharacterView: SKSpriteNode {
    
    private let label = SKLabelNode()
    private let character = SKSpriteNode()
    
    let text: String
    let characterTexture: SKTexture?
    
    init(text: String, charcterTexture: SKTexture?, size: CGSize) {
        self.text = text
        self.characterTexture = charcterTexture
        super.init(texture: SKTexture(image: .dilogWindow), color: .clear, size: size)
        self.alpha = 0
        self.position = CGPoint(x: frame.midX, y: frame.maxY)
        setUpCharacter()
        setUpText()
        
    }
    
    private func setUpCharacter() {
        guard let texture = characterTexture else { return }
        character.texture = texture
        character.size = texture.size()
        character.position = CGPoint(x: size.width / 2 + 25, y: frame.maxY)
        addChild(character)
    }
    
    private func setUpText() {
        label.text = text
        label.fontSize = 20
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = size.width - 100
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 20 - size.width / 2, y: 0)
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
