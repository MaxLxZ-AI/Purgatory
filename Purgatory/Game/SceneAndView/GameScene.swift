import SpriteKit


final class GameFortuneMergeScene: SKScene, SKPhysicsContactDelegate {
    var parentFortuneMergeView: GameFortuneMergeView?
    
    var enri: Enri!
    var emma: Emma!
    var moveLeftButton: SKSpriteNode!
    var moveRightButton: SKSpriteNode!
    var roomManager: RoomManager!
    
    var moveButtons: [Direction: MovementButton] = [:]
    
    var dilogManager: DialogManager!
    
    private var characters: [GameCharacter] = []
    private var dialogTriggers: [DialogTriggerNode] = []
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        dilogManager = DialogManager(scene: self)
        loadCharacters()
        roomManager = RoomManager(scene: self, dialogManager: dilogManager, characters: characters)
        roomManager.loadRoom(withID: "room1")
//        setUpBackground()
        loadGame()

        
    }
    
    private func loadCharacters() {
        setUpEnri()
        setUpEmma()
    }
    
    private func loadGame() {
        setupControlButtons()
        startIntroCutscene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        enri.updateMovement()
        
//        emma.updateMovement()
        emma.updateFollowing()
    }
    
    func startIntroCutscene() {
        emma.removeLeader()
        let introCutscene = dilogManager.createIntroCutscene(enri: enri, emma: emma, onEndOfCutscene: { [self] in
            emma.setupFollowing(leader: enri)
        })
        dilogManager.playCutscene(introCutscene)
    }
    
    private func setUpTrigger() {


//        dialogTriggers.append(trigger)
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

    }
    
    private func setUpEmma() {
        let calmTexture = SKTexture(image: .downCalmEmma)
        
        emma = Emma(
            character: .Emma, calmState: calmTexture,
            size: CGSize(width: 64, height: 64)
        )
        emma.setupFollowing(leader: enri)

        characters.append(emma)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        handleContact(characterBody: bodyA, otherBody: bodyB)
        handleContact(characterBody: bodyB, otherBody: bodyA)
    }
    
    private func handleContact(characterBody: SKPhysicsBody, otherBody: SKPhysicsBody) {
        guard characterBody.categoryBitMask == PhysicsCategory.character,
              let character = characterBody.node as? GameCharacter else { return }

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

        if otherBody.categoryBitMask == PhysicsCategory.dialogTrigger,
           let trigger = otherBody.node as? DialogTriggering {
            enri.stopMoving()
            trigger.characterDidEnter(character)
            trigger.secondDialog(onDialogEnd: { [self] in
                enri.moveToPosition(CGPoint(x: enri.position.x - 300, y: enri.position.y), duration: 5)
            })
            
        }
        if otherBody.categoryBitMask == PhysicsCategory.door, let door = otherBody.node as? Door {
            handleDoorCollision(door: door)
        }
    }
    
    private func handleDoorCollision(door: Door) {
        guard let currentRoomNumber = getCurrentRoomNumber() else {
            print("Failed to get current room number")
            return
        }
        
        // Определяем целевую комнату на основе ID двери
        let targetRoomNumber = getTargetRoomNumber(for: door.id, currentRoom: currentRoomNumber)
        let targetRoomID = "room\(targetRoomNumber)"
        
        print("Door \(door.id) activated. Moving from room\(currentRoomNumber) to \(targetRoomID)")
        
        // Загружаем новую комнату и перезапускаем игру
        roomManager.loadRoom(withID: targetRoomID)
        loadGame()
    }
    
    private func getCurrentRoomNumber() -> Int? {
        let roomID = roomManager.currentID
        let numberString = roomID.replacingOccurrences(of: "room", with: "")
        return Int(numberString)
    }
    
    private func getTargetRoomNumber(for doorID: String, currentRoom: Int) -> Int {
        let doorConfig: [String: (Int, String)] = [
            "door_1": (currentRoom > 1 ? currentRoom - 1 : currentRoom + 1, "Main door - goes back if not first room, otherwise forward"),
            "door_2": (currentRoom + 1, "Forward door - always goes to next room"),
            "door_3": (currentRoom - 1, "Backward door - always goes to previous room")
        ]
        
        if let (targetRoom, description) = doorConfig[doorID] {
            print("Door \(doorID): \(description)")
            return targetRoom
        }
        
        print("Door \(doorID): Default behavior - going forward")
        return currentRoom + 1
    }

    
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

extension CGVector {
    func normalized() -> CGVector {
        let length = sqrt(dx*dx + dy*dy)
        return length > 0 ? CGVector(dx: dx/length, dy: dy/length) : .zero
    }
}

