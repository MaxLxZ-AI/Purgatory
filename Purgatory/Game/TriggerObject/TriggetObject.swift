import SpriteKit

protocol DialogTriggering {
    func characterDidEnter(_ character: GameCharacter)
    func firstDialog(onDialogEnd: (() -> Void)?)
    func secondDialog(onDialogEnd: (() -> Void)?)
}

class DialogTriggerNode: SKSpriteNode, DialogTriggering {
    var charactersInRange: [GameCharacter] = []
    var dialogManager: DialogManager
    private var triggerRadius: TriggerRadius
    private var isDialogActive = false
    private var activeCharacters: Set<GameCharacter> = []
    
    init(texture: SKTexture, size: CGSize, dialogManager: DialogManager, triggerRadius: TriggerRadius) {
        self.dialogManager = dialogManager
        self.triggerRadius = triggerRadius
        super.init(texture: texture, color: .clear, size: size)
        setupPhysics()
//        setUpRadius()
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
    
    func update(with characters: [GameCharacter]) {
        guard !isDialogActive else { return }
        
        
    }
    
    func firstDialog(onDialogEnd: (() -> Void)?) {
        
    }
    
    func secondDialog(onDialogEnd: (() -> Void)?) {
        
    }

    func characterDidEnter(_ character: GameCharacter) {
        activeCharacters.insert(character)
        checkForDialog()
    }
    
    func characterDidExit(_ character: GameCharacter) {
        activeCharacters.remove(character)
    }
    
    private func checkForDialog() {
        guard activeCharacters.count >= 0, !isDialogActive else { return }
        startDialogBetween(characters: Array(activeCharacters.prefix(2)))
    }
    
    func startDialogBetween(characters: [GameCharacter]) {
        isDialogActive = true
        
        characters.forEach { $0.stopMoving() }
    }
}

final class BloodWallWriting: DialogTriggerNode {
    override func firstDialog(onDialogEnd: (() -> Void)?) {
        dialogManager.presentSequence([
            ("Do you see this blood writing", SKTexture(image: .defaultEmma)),
            ("You are right, we need to guess the word, let select who is gonna do that.", SKTexture(image: .defaultEnri)),
            ("Yea, let's do it", SKTexture(image: .defaultEmma))
        ])
        dialogManager.onDialogEnd = {
            onDialogEnd?()
        }
        
    }

    
    override func secondDialog(onDialogEnd: (() -> Void)?) {
        dialogManager.presentSequence([
            ("", SKTexture(image: .defaultEnri))
        ])
        
        dialogManager.onDialogEnd = {
            onDialogEnd?()
        }
    }
}
