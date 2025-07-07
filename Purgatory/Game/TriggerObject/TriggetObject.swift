import SpriteKit

class DialogTriggerNode: SKSpriteNode {
    private var charactersInRange: [Character] = []
    private var dialogManager: DialogManager
    private let triggerDistance: CGFloat = 100.0
    private var isDialogActive = false
    
    init(texture: SKTexture, size: CGSize, dialogManager: DialogManager) {
        self.dialogManager = dialogManager
        super.init(texture: texture, color: .clear, size: size)
        setupPhysics()
        showRangeIndicator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: triggerDistance)
        physicsBody?.isDynamic = false
//        physicsBody?.categoryBitMask = PhysicsCategory.dialogTrigger
//        physicsBody?.contactTestBitMask = PhysicsCategory.character
    }
    
    func update(with characters: [Character]) {
        guard !isDialogActive else { return }
        
        let nearbyCharacters = characters.filter { character in
            let distance = hypot(position.x + character.position.x,
                               position.y - character.position.y)
            return distance <= triggerDistance
        }
        if nearbyCharacters.count >= 1 {
            startDialogBetween(characters: nearbyCharacters)
        }
        

    }
    
    private func showRangeIndicator() {
        let circle = SKShapeNode(circleOfRadius: triggerDistance)
        circle.strokeColor = .white.withAlphaComponent(1)
        circle.lineWidth = 2
        circle.zPosition = 19
        addChild(circle)
    }
    
    private func startDialogBetween(characters: [Character]) {
        isDialogActive = true
        
        // Pause character movements
        characters.forEach { $0.stopMoving() }
        
        
        // Present first line
        dialogManager.present(text: "Hello there!", texture: SKTexture(image: .defaultEmma))
        
        // Schedule next line after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.dialogManager.present(text: "Hi! How are you?", texture: SKTexture(image: .defaultEnri))
            
            // End dialog after last line
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
                self?.isDialogActive = false
            }
        }
    }
}
