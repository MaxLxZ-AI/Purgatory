import SpriteKit

protocol DialogTriggering: SKNode {
    func characterDidEnter(_ character: Character)
    func firstDialog()
    func secondDialog()
}

class DialogTriggerNode: SKSpriteNode {
    private var charactersInRange: [Character] = []
    var dialogManager: DialogManager
    private var triggerRadius: TriggerRadius
    private var isDialogActive = false
    private var activeCharacters: Set<Character> = []
    
    init(texture: SKTexture, size: CGSize, dialogManager: DialogManager, triggerRadius: TriggerRadius) {
        self.dialogManager = dialogManager
        self.triggerRadius = triggerRadius
        super.init(texture: texture, color: .clear, size: size)
        setupPhysics()
        setUpRadius()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpRadius() {
        triggerRadius = TriggerRadius(radius: size.width * 2)
        triggerRadius.zPosition = 10
        addChild(triggerRadius)
        
    }
    

    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.dialogTrigger
        physicsBody?.collisionBitMask = PhysicsCategory.dialogTrigger
        physicsBody?.contactTestBitMask = PhysicsCategory.character
    }
    
    func update(with characters: [Character]) {
        guard !isDialogActive else { return }
        
        
    }
    
    func firstDialog() {
        
    }
    
    func secondDialog() {
        
    }

    
    func startDialogBetween(characters: [Character]) {
        isDialogActive = true
        
        characters.forEach { $0.stopMoving() }
    }
}

extension DialogTriggerNode: DialogTriggering {
    func characterDidEnter(_ character: Character) {
        activeCharacters.insert(character)
        checkForDialog()
    }
    
    func characterDidExit(_ character: Character) {
        activeCharacters.remove(character)
    }
    
    private func checkForDialog() {
        guard activeCharacters.count >= 0, !isDialogActive else { return }
        startDialogBetween(characters: Array(activeCharacters.prefix(2)))
    }
    

}

final class BloodWallWriting: DialogTriggerNode {
    override func firstDialog() {
        
        dialogManager.presentSequence([
            ("Do you see this blood writing", SKTexture(image: .defaultEmma)),
            ("You are right, we need to guess the word, let select who is gonna do that.", SKTexture(image: .defaultEnri)),
            ("Yea, let's do it", SKTexture(image: .defaultEmma))
        ])
        
    }
    
    override func secondDialog() {
        dialogManager.presentSequence([
            ("", SKTexture(image: .defaultEnri))
        ])
    }
}
