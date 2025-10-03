import SpriteKit

enum TriggerIdentity {
    case bloodWriting
    case magicRune
    case cursedMirror
    case corpseStrappedToATable
    case pillar
}

enum PlaceableObjects {
    case CrackedHolySymbol
    case BloodySurgicalKnife
    case MeltedCandle
}

protocol DialogTriggering: AnyObject {
    var identity: TriggerIdentity { get }
    var wasDialogTriggered: Bool { get set }
    var wasPazzledSolved: Bool { get set }
    func characterDidEnter(_ character: GameCharacter)
    func firstDialog(onDialogEnd: (() -> Void)?)
    func secondDialog(onDialogEnd: (() -> Void)?)
    func solved(onDialogEnd: (() -> Void)?)
}

class DialogTriggerNode: SKSpriteNode, DialogTriggering {
    var wasPazzledSolved: Bool
    
    var charactersInRange: [GameCharacter] = []
    var dialogManager: DialogManager
    private var triggerRadius: TriggerRadius
    let identity: TriggerIdentity
    private var isDialogActive = false
    var wasDialogTriggered = false
    private var activeCharacters: Set<GameCharacter> = []
    
    init(texture: SKTexture, size: CGSize, dialogManager: DialogManager, wasPazzledSolved: Bool, triggerRadius: TriggerRadius, identity: TriggerIdentity) {
        self.dialogManager = dialogManager
        self.triggerRadius = triggerRadius
        self.identity = identity
        self.wasPazzledSolved = wasPazzledSolved
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
    
    func solved(onDialogEnd: (() -> Void)?) {
        
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
        guard activeCharacters.count > 0, !isDialogActive else { return }
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
    
    override func solved(onDialogEnd: (() -> Void)?) {
        dialogManager.presentSequence([
            ("", SKTexture(image: .defaultEnri))
        ])
        
        dialogManager.onDialogEnd = {
            onDialogEnd?()
        }
    }

    
    override func secondDialog(onDialogEnd: (() -> Void)?) {
        dialogManager.presentSequence([
            ("I speak without a mouth and hear without ears. I have no body, but I come alive with wind. What am I?", SKTexture(image: .defaultEmma)),
            ("I suppose we should choose someone who can guess the word, who will it be?", SKTexture(image: .defaultEmma))
        ])
        
        dialogManager.onDialogEnd = {
            onDialogEnd?()
        }
    }
}

final class Courpse: DialogTriggerNode {
    override func firstDialog(onDialogEnd: (() -> Void)?) {
        dialogManager.presentSequence([
            ("Do you see this courpse", SKTexture(image: .defaultEmma)),
            ("You are right, we need to take this shard from him, let select who is gonna do that.", SKTexture(image: .defaultEnri)),
            ("Yea, let's do it", SKTexture(image: .defaultEmma))
        ])
        dialogManager.onDialogEnd = {
            onDialogEnd?()
        }
        
    }
    
    override func solved(onDialogEnd: (() -> Void)?) {
        dialogManager.presentSequence([
            ("", SKTexture(image: .defaultEnri))
        ])
        
        dialogManager.onDialogEnd = {
            onDialogEnd?()
        }
    }

    
    override func secondDialog(onDialogEnd: (() -> Void)?) {
        dialogManager.presentSequence([
            ("Do you see this courpse", SKTexture(image: .defaultEmma)),
            ("You are right, we need to take this shard from him, let select who is gonna do that.", SKTexture(image: .defaultEmma)),
            ("", SKTexture(image: .defaultEnri)),
            ("Yea, let's do it", SKTexture(image: .defaultEmma))
        ])
        
        dialogManager.onDialogEnd = {
            onDialogEnd?()
        }
    }
}

final class Pillar: DialogTriggerNode {
    var object: PlaceableObject?
    var wasObjectTaken = false
    init(object: PlaceableObject? = nil, texture: SKTexture, size: CGSize, dialogManager: DialogManager, wasPazzledSolved: Bool, triggerRadius: TriggerRadius, identity: TriggerIdentity) {
        self.object = object
        super.init(texture: texture, size: size, dialogManager: dialogManager, wasPazzledSolved: wasPazzledSolved, triggerRadius: triggerRadius, identity: identity)
        setUpObject()
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func secondDialog(onDialogEnd: (() -> Void)?) {
        dialogManager.presentSequence([
            ("", SKTexture(image: .defaultEnri))
        ])
        
        dialogManager.onDialogEnd = {
            onDialogEnd?()
        }
    }
    
    func setUpObject() {
        guard let obj = object else { return }
        obj.position = CGPoint(x: self.position.x, y: self.position.y + self.size.height / 2)
        obj.zPosition = self.zPosition + 1
        self.addChild(obj)
    }
    
}

final class PlaceableObject: SKSpriteNode {
    let type: PlaceableObjects
    init(texture: SKTexture, size: CGSize, type: PlaceableObjects) {
        self.type = type
        super.init(texture: texture, color: .clear, size: size)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
