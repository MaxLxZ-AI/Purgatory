import SpriteKit


final class GameFortuneMergeScene: SKScene, SKPhysicsContactDelegate {
    var parentFortuneMergeView: GameFortuneMergeView?
    
    var enri: Enri!
    var emma: Emma!
    var moveLeftButton: SKSpriteNode!
    var moveRightButton: SKSpriteNode!
    var wrongAnswersCounter = 0
    var roomManager: RoomManager!
    var moveButtons: [Direction: MovementButton] = [:]
    
    var roomNumber = 1
    var dilogManager: DialogManager!
    var selectionManager: SelectionManager!
    
    var lastTriggered: DialogTriggering?
    
    private var characters: [GameCharacter] = []
    private var dialogTriggers: [DialogTriggerNode] = []
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        dilogManager = DialogManager(scene: self)
        selectionManager = SelectionManager(scene: self)
        roomManager = RoomManager(scene: self, dialogManager: dilogManager)
        roomManager.loadRoom(room: "room\(roomNumber)")
        setUpBackground()
        loadCharacters()
        loadGame()
    }
    
    private func initializeRoom() {
        guard size.width > 0 && size.height > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.initializeRoom()
            }
            return
        }
        

    }
    
    private func loadCharacters() {
        setUpEnri()
        setUpEmma()

    }
    
    private func loadGame() {
        setupControlButtons()
//        startIntroCutscene()
    }
    
    
    private func loadSecondRoom() {
        setupControlButtons()
        startSecondRoomCutscene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        enri.updateMovement()
        
//        emma.updateMovement()
        emma.updateFollowing()
    }
    
    func startIntroCutscene() {
        emma.removeLeader()
        actionWithButtons(action: .hide)
        let introCutscene = dilogManager.createCutscene(enri: enri, emma: emma, cutsceneType: .introduction, onEndOfCutscene: { [self] in
            emma.setupFollowing(leader: enri)
            actionWithButtons(action: .show)
        })
        dilogManager.playCutscene(introCutscene)
    }
    
    private func startTrapCutscene() {
        emma.removeLeader()
        let trapCutscene = dilogManager.createCutscene(enri: enri, emma: emma, cutsceneType: .illusionTrap, onEndOfCutscene: { [self] in
            emma.setupFollowing(leader: enri)
        })
        dilogManager.playCutscene(trapCutscene)
    }
    
    private func startExtractionCutscene() {
        emma.removeLeader()
        let trapCutscene = dilogManager.createCutscene(enri: enri, emma: emma, cutsceneType: .lastAttemptHasBeenLost, onEndOfCutscene: {
            
        })
        dilogManager.playCutscene(trapCutscene)
    }
    
    func startSecondRoomCutscene() {
        emma.removeLeader()
        let secondRoomCutscene = dilogManager.createCutscene(enri: enri, emma: emma, cutsceneType: .secondRoom, onEndOfCutscene: { [self] in
            emma.setupFollowing(leader: enri)
        })
        dilogManager.playCutscene(secondRoomCutscene)
    }
    
    private func setUpTrigger() {


//        dialogTriggers.append(trigger)
    }
    
    private func setUpBackground() {
        let background = SKSpriteNode(texture: SKTexture(image: .firstRoom),
                                      size: CGSize(width: frame.width, height: frame.height))
        background.zPosition = -1
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)
    }
    
    private func setUpEnri() {
        let calmTexture = SKTexture(image: .upWalkingClmEnri)
        
        enri = Enri(
            character: .Enri, calmState: calmTexture,
            size: CGSize(width: Constants.GameConstants.characterSize, height: Constants.GameConstants.characterSize)
        )
        enri.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        characters.append(enri)
        addChild(enri)
    }
    
    private func setCharactersPositions(roomNumber: Int) {
        switch roomNumber {
        case 1:
            enri.position = CGPoint(x: frame.midX, y: frame.midY - 100)
            addChild(enri)
            
            emma.position = CGPoint(x: frame.midX - 100, y: frame.midY - 100)
            addChild(emma)
            
        case 2:
            enri.position = CGPoint(x: frame.midX - 100, y: frame.midY)
            addChild(enri)
            
            emma.position = CGPoint(x: frame.midX - 170, y: frame.midY)
            addChild(emma)
        default:
            break
        }
    }
    
    
    private func setUpEmma() {
        let calmTexture = SKTexture(image: .downCalmEmma)
        
        emma = Emma(
            character: .Emma, calmState: calmTexture,
            size: CGSize(width: Constants.GameConstants.characterSize, height: Constants.GameConstants.characterSize)
        )
        emma.setupFollowing(leader: enri)
        emma.position = CGPoint(x: frame.midX - 100, y: frame.midY - 100)
        addChild(emma)
        characters.append(emma)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        handleContact(characterBody: bodyA, otherBody: bodyB)
        handleContact(characterBody: bodyB, otherBody: bodyA)
    }
    
    func dismissGameWithoutAnimation() {
        parentFortuneMergeView?.dismissWithoutAnimation()
    }
    
    func exitGame() {
        dismissGameWithoutAnimation()
    }
    
    private func handleContact(characterBody: SKPhysicsBody, otherBody: SKPhysicsBody) {
        guard characterBody.categoryBitMask == PhysicsCategory.character,
              let character = characterBody.node as? GameCharacter else { return }

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
            if !dilogManager.isCutscenePlaying() {
                enri.stopMoving()
                trigger.characterDidEnter(character)
                if !trigger.wasDialogTriggered  {
                    if !Constants.UserDefaultsConstants.wasPazzleSolved {
                        trigger.secondDialog(onDialogEnd: { [self] in
                            
                                trigger.wasDialogTriggered = true
                                
                                actionAfterDialog(identity: trigger.identity, trigger: trigger)
                        })
                    } else {
                        trigger.solved {
                            trigger.wasDialogTriggered = false
                        }
                    }

                }
            }


            
        }
        if otherBody.categoryBitMask == PhysicsCategory.door, let door = otherBody.node as? Door {
            if roomManager.doorArray.count >= 2 {
                switch door.id {
                case "Door1":
                    roomNumber -= 1
                    roomManager.loadRoom(room: "room\(roomNumber)")
                    loadCharactersToACertainRoom(roomNumber: roomNumber)
                    setupControlButtons()
                    
                case "Door2":
                    roomNumber += 1
                    roomManager.loadRoom(room: "room\(roomNumber)")
                    loadCharactersToACertainRoom(roomNumber: roomNumber)
                    setupControlButtons()
                default:
                    break
                }
            } else {
                roomNumber += 1
                roomManager.loadRoom(room: "room\(roomNumber)")
                loadCharactersToACertainRoom(roomNumber: roomNumber)
                setupControlButtons()
            }
        }
    }
    
    private func loadCharactersToACertainRoom(roomNumber: Int) {
        switch roomNumber {
        case 1:
            setCharactersPositions(roomNumber: roomNumber)
        case 2:
            setCharactersPositions(roomNumber: roomNumber)
        default:
            break
        }
    }
    
    private func actionAfterDialog(identity: TriggerIdentity, trigger: DialogTriggering) {
        switch identity {
        case .bloodWriting:
            selection(trigger: trigger)
            lastTriggered = trigger
        case .magicRune:
            break
        case .cursedMirror:
            break
        }
    }
    
    private func guessAword() {
        
    }
    
    func selection(trigger: DialogTriggering) {
        selectionManager.showCharacterSelectionButtons(for: characters) {
            self.dilogManager.presentSequence([
                ("", SKTexture(image: .defaultEnri))
            ])
            self.dilogManager.onDialogEnd = {
                let words = Constants.WordsToguess.echo.shuffled()
                
                self.selectionManager.showWordsSelectionButtons(for: words.dropLast()) {
                    print("Right word")
                    self.roomManager.releaseCharactersFromTrap()
                    Constants.UserDefaultsConstants.wasPazzleSolved = true
                } wrongWord: { [self] in
                    print("Wrong word")
                    trigger.wasDialogTriggered = false
                    self.wrongAnswersCounter += 1
                    if self.wrongAnswersCounter == 1 {
                        self.startTrapCutscene()
                    }
                    if self.wrongAnswersCounter == 2 {
                        self.startExtractionCutscene()
                    }
                }

            }
        } emmaSelected: {
            self.dilogManager.presentSequence([
                ("I will try", SKTexture(image: .defaultEmma))
            ])
            self.dilogManager.onDialogEnd = {
                let words = Constants.WordsToguess.echo.shuffled()
                
                self.selectionManager.showWordsSelectionButtons(for: words.dropLast()) {
                    print("Right word")
                    self.roomManager.releaseCharactersFromTrap()
                    Constants.UserDefaultsConstants.wasPazzleSolved = true
                } wrongWord: {
                    print("Wrong word")
                    trigger.wasDialogTriggered = false
                    self.wrongAnswersCounter += 1
                    if self.wrongAnswersCounter == 1 {
                        self.startTrapCutscene()
                    }
                    if self.wrongAnswersCounter == 2 {
                        self.startExtractionCutscene()
                    }
                }

            }
        }
    }
    
    private func animatedTransitionAmongRooms() {
        let coverNode = SKSpriteNode(color: .black, size: self.size)
        
        coverNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        coverNode.zPosition = 9999
        coverNode.color = .black
        coverNode.alpha = 0 
        addChild(coverNode)
        
        coverNode.run(.sequence([
            .fadeIn(withDuration: 2),
            .fadeOut(withDuration: 2),
            .removeFromParent()
        ]))
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
    
    func actionWithButtons(action: ActionsWithButtons) {
        switch action {
        case .hide:
            for button in moveButtons.values {
                button.alpha = 0
            }
        case .show:
            for button in moveButtons.values {
                button.alpha = 0.5
            }
        }

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
        if !dilogManager.cutsceneManager!.isPlaying {
            for button in moveButtons.values {
                button.alpha = 0.5
            }
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

