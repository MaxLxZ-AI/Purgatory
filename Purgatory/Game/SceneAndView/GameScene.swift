import SpriteKit



final class GameFortuneMergeScene: SKScene, SKPhysicsContactDelegate {
    var parentFortuneMergeView: GameFortuneMergeView?
    
    var enri: Enri!
    var emma: Emma!
    var moveLeftButton: SKSpriteNode!
    var moveRightButton: SKSpriteNode!
    
    var moveButtons: [Direction: MovementButton] = [:]
    
    var dilogManager: DialogManager!
    
    private var characters: [Character] = []
    private var dialogTriggers: [DialogTriggerNode] = []
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setUpBackground()
        setUpEnri()
        setUpEmma()

        setupControlButtons()
        dilogManager = DialogManager(scene: self)
        setUpTrigger()
        startIntroCutscene()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        enri.updateMovement()
        
        // Then update follower (Emma)
//        emma.updateMovement()
        emma.updateFollowing()
    }
    
    func startIntroCutscene() {
        let introCutscene = dilogManager.createIntroCutscene(enri: enri, emma: emma)
        dilogManager.playCutscene(introCutscene)
    }
    
    private func setUpTrigger() {
        let trigger = BloodWallWriting(texture: SKTexture(image: .wft),
                                       size: CGSize(width: 100, height: 100),
                                        dialogManager: dilogManager, triggerRadius: TriggerRadius(radius: 100))
        trigger.position = CGPoint(x: frame.maxX - 100, y: frame.midY)
        addChild(trigger)
        dialogTriggers.append(trigger)
    }
    
    private func setUpBackground() {
        let background = SKSpriteNode(texture: SKTexture(image: .firstRoom),
                                      size: CGSize(width: frame.width, height: frame.height))
        background.zPosition = 0
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)
    }
    
    private func setUpEnri() {
        let calmTexture = SKTexture(image: .upWalkingClmEnri)
        
        enri = Enri(
            character: .Enri, calmState: calmTexture,
            size: CGSize(width: 64, height: 64)
        )
        characters.append(enri)
        enri.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(enri)
    }
    
    private func setUpEmma() {
        let calmTexture = SKTexture(image: .downCalmEmma)
        
        emma = Emma(
            character: .Emma, calmState: calmTexture,
            size: CGSize(width: 64, height: 64)
        )
        emma.setupFollowing(leader: enri)

        // Position Emma behind Enri initially
        emma.position = CGPoint(x: enri.position.x, y: enri.position.y)
        characters.append(emma)
        addChild(emma)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        handleContact(characterBody: bodyA, otherBody: bodyB)
        handleContact(characterBody: bodyB, otherBody: bodyA)
    }
    
    private func handleContact(characterBody: SKPhysicsBody, otherBody: SKPhysicsBody) {
        guard characterBody.categoryBitMask == PhysicsCategory.character,
              let character = characterBody.node as? Character else { return }

        // First dialog trigger with radius
        if otherBody.categoryBitMask == PhysicsCategory.firstDialogTrigger,
           let radiusNode = otherBody.node as? TriggerRadius,
           let trigger = radiusNode.parentTrigger ?? otherBody.node?.parent as? DialogTriggering {

            trigger.characterDidEnter(character)
            
            if !radiusNode.wasDialogTriggered {
                enri.stopMoving()
                trigger.firstDialog(onDialogEnd: { [self] in
                    enri.moveToPosition(CGPoint(x: enri.position.x + 150, y: enri.position.y), duration: 2)
                })
                radiusNode.wasDialogTriggered = true
            }
        }

        // Dialog trigger without radius
        if otherBody.categoryBitMask == PhysicsCategory.dialogTrigger,
           let trigger = otherBody.node as? DialogTriggering {
            enri.stopMoving()
            trigger.characterDidEnter(character)
            trigger.secondDialog(onDialogEnd: { [self] in
                enri.moveToPosition(CGPoint(x: enri.position.x - 300, y: enri.position.y), duration: 5)
            })
            
        }
    }

    
//    func didEnd(_ contact: SKPhysicsContact) {
////        handleContact(contact, began: false)
//    }
//    
//    private func handleContact(_ contact: SKPhysicsContact, began: Bool) {
//        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
//        
//        if collision == (PhysicsCategory.character | PhysicsCategory.firstDialogTrigger) {
//            handleTriggerContact(contact, began: began, triggerType: .firstDialog)
//        }
//        else if collision == (PhysicsCategory.character | PhysicsCategory.dialogTrigger) {
//            handleTriggerContact(contact, began: began, triggerType: .regular)
//        }
//    }
//
//    private func handleTriggerContact(_ contact: SKPhysicsContact, began: Bool, triggerType: TriggerType) {
//        let characterNode = contact.bodyA.categoryBitMask == PhysicsCategory.character ?
//            contact.bodyA.node : contact.bodyB.node
//        let node = contact.bodyA.categoryBitMask == PhysicsCategory.dialogTrigger ?
//            contact.bodyA.node : contact.bodyB.node
//
//        
//        if let character = characterNode as? Character, let bloodWriting = node as? BloodWallWriting {
//            if began {
//                switch triggerType {
//                case .firstDialog:
//                    startFirstDialog(with: character)
//                case .regular:
////                    startDialog(with: character)
//                    bloodWriting.secondDialog()
//                }
//            } else {
//                characters.removeAll()
//            }
//        }
//    }
//
//    enum TriggerType {
//        case firstDialog
//        case regular
//    }
//    
//    private func startDialog(with character: Character) {
//        dilogManager.present(text: "Hello there!", texture: SKTexture(image: .defaultEmma))
//    }
//    
//    private func startFirstDialog(with character: Character) {
//        dilogManager.present(text: "Hello there!", texture: SKTexture(image: .defaultEnri))
//    }
    
    private func setupControlButtons() {
        let buttonSize = CGSize(width: 80, height: 80)
        
        let leftButton = MovementButton(size: buttonSize)
        leftButton.position = CGPoint(x: 100, y: 150)
        leftButton.name = "left"
        leftButton.alpha = 0.5
        addChild(leftButton)
        moveButtons[.left] = leftButton
        
        let rightButton = MovementButton(size: buttonSize)
        rightButton.position = CGPoint(x: 200, y: 150)
        rightButton.name = "right"
        rightButton.alpha = 0.5
        addChild(rightButton)
        moveButtons[.right] = rightButton
        
        let upButton = MovementButton(size: buttonSize)
        upButton.position = CGPoint(x: 150, y: 230)
        upButton.name = "up"
        upButton.alpha = 0.5
        addChild(upButton)
        moveButtons[.up] = upButton
        
        let downButton = MovementButton(size: buttonSize)
        downButton.position = CGPoint(x: 150, y: 70)

        addChild(downButton)
        moveButtons[.down] = downButton
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dilogManager.isDialogActive() {
            dilogManager.handleTap()
            return
        }
//        dilogManager.present(text: "The first version of this screen, something myght not work properly", texture: SKTexture(image: .defaultEnri))
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            
            
            for node in nodes {
                if let direction = moveButtons.first(where: { $0.value == node })?.key {
                    enri.startMoving(in: direction)
//                    emma.currentDirection = direction
                    node.alpha = 0.8
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for button in moveButtons.values {
            button.alpha = 0.5
        }
        
        var shouldStop = true
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            guard nodes.first(where: { node in
                moveButtons.values.contains { $0 === (node as? MovementButton) }
            }) == nil else {
                shouldStop = false
                continue
            }
        }
        
        if shouldStop {
            enri.stopMoving()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for button in moveButtons.values {
            button.alpha = 0.5
        }
        enri.stopMoving()
    }
}

// Helper extension for vector normalization
extension CGVector {
    func normalized() -> CGVector {
        let length = sqrt(dx*dx + dy*dy)
        return length > 0 ? CGVector(dx: dx/length, dy: dy/length) : .zero
    }
}

