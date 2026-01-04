import SpriteKit


protocol SelectableButtonDelegate: AnyObject {
    func buttonDidSelect(character: GameCharacter)
}

final class CharacterButton: SKSpriteNode {
    private let character: GameCharacter?
    private let wordToGuess: String?
    private var action: (() -> Void)?
    
    init(character: GameCharacter?, wordToGuess: String?, size: CGSize) {
        self.character = character
        self.wordToGuess = wordToGuess
        super.init(texture: nil, color: .red, size: size)
        
        setupButton()
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        var text = ""
        if character?.character == nil {
            text = wordToGuess!
        } else {
            text = "\(character!.character)"
        }
        let label = SKLabelNode(text: "\(text)")
        label.fontColor = .black
        label.fontName = "Avenir-Bold"
        label.fontSize = 16
        label.verticalAlignmentMode = .center
        addChild(label)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(.scale(to: 0.95, duration: 0.1))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(.sequence([
            .scale(to: 1.0, duration: 0.1),
            .run { [weak self] in
                self?.action?()
            }
        ]))
    }
    
    func setAction(_ action: @escaping () -> Void) {
        self.action = action
    }
}

final class SelectionManager {
    weak var scene: GameFortuneMergeScene?
    private var buttons: [CharacterButton] = []
    
    init(scene: GameFortuneMergeScene? = nil) {
        self.scene = scene
    }
    
    func showCharacterSelectionButtons(for characters: [GameCharacter], enriSelected: (() -> Void)?, emmaSelected: (() -> Void)?) {
        clearExistingButtons()
        
        for (index, character) in characters.enumerated() {
            
            let button = CharacterButton(
                character: character,
                wordToGuess: nil,
                size: CGSize(width: 200, height: 50)
            )
            button.zPosition = 999
            button.position = CGPoint(
                x: scene?.frame.midX ?? 0,
                y: (scene?.frame.midY ?? 0) + CGFloat(index * 60)
            )
            
            button.setAction { [weak self] in
                self?.handleCharacterSelection(character, enriSelected: {
                    enriSelected?()
                }, emmaSelected: {
                    emmaSelected?()
                })
            }
            
            scene?.addChild(button)
            buttons.append(button)
        }
        
        for button in buttons {
            button.position.y -= 30
        }
        
    }
    
    func showWordsSelectionButtons(for words: [String], rightWord: (() -> Void)?, wrongWord: (() -> Void)?, trigger: DialogTriggering) {
        clearExistingButtons()
        
        for (index, word) in words.enumerated() {
            
            let button = CharacterButton(
                character: nil,
                wordToGuess: word,
                size: CGSize(width: 200, height: 50)
            )
            button.zPosition = 999
            
            button.position = CGPoint(
                x: scene?.frame.midX ?? 0,
                y: (scene?.frame.midY ?? 0) + CGFloat(index * 60)
            )
            
            button.setAction { [weak self] in
                switch trigger.identity {
                case .bloodWriting:
                    self?.handleWordSelection(word, rightWord: {
                        rightWord?()
                    }, wrongWord: {
                        wrongWord?()
                    })
                case .magicRune:
                    break
                case .cursedMirror:
                    break
                case .corpseStrappedToATable:
                    break
                case .pillar:
                    self?.takeOrLeave(word, take: {
                        rightWord?()
                        self!.scene!.placeableArray.remove(at: index - 1)
                    }, leave: {
                        wrongWord?()
                    })
                }

            }
            
            scene?.addChild(button)
            buttons.append(button)
        }
        
        for button in buttons {
            button.position.y -= 90
        }
    }
    
    func selectObject(objects: [String], action: (() -> Void)?, leave: (() -> Void)?, trigger: DialogTriggering) {
        clearExistingButtons()
        
        for (index, object) in objects.enumerated() {
            
            let button = CharacterButton(
                character: nil,
                wordToGuess: object,
                size: CGSize(width: 200, height: 50)
            )
            button.zPosition = 999
            
            button.position = CGPoint(
                x: scene?.frame.midX ?? 0,
                y: (scene?.frame.midY ?? 0) + CGFloat(index * 60)
            )
            scene?.addChild(button)
            buttons.append(button)
            button.setAction {
                self.putOrLeave(object, put: {
                    self.clearExistingButtons()
                    
                    guard let pillar = trigger as? Pillar else { return }
                    self.scene?.checkOrder (onDialogEnd: {
                        action?()
                        self.scene?.setUpPillarObject(pillar: pillar, index: index)
                    }, trigger: pillar)
                }, leave: {
                    self.clearExistingButtons()
                    leave?()
                })
            }
        }
    }
    
    func finalDecision(objects: [String], action: (() -> Void)?, leave: (() -> Void)?) {
        clearExistingButtons()
        
        for (index, object) in objects.enumerated() {
            
            let button = CharacterButton(
                character: nil,
                wordToGuess: object,
                size: CGSize(width: 200, height: 50)
            )
            button.zPosition = 999
            
            button.position = CGPoint(
                x: scene?.frame.midX ?? 0,
                y: (scene?.frame.midY ?? 0) + CGFloat(index * 60)
            )
            scene?.addChild(button)
            buttons.append(button)
            button.setAction {
                self.putOrLeave(object, put: {
                    self.clearExistingButtons()
                    action?()
                }, leave: {
                    self.clearExistingButtons()
                    leave?()
                })
            }
        }
    }
    private func putOrLeave(_ word: String, put: (() -> Void)?, leave: (() -> Void)?) {
        if word == "Leave" {
            leave?()
        } else {
            put?()
        }
    }
    
    func findIndex(index: Int) -> Int {
        index
    }
    
    private func handleCharacterSelection(_ character: GameCharacter, enriSelected: (() -> Void)?, emmaSelected: (() -> Void)?) {
        switch character.character {
        case .Enri:
            clearExistingButtons()
            enriSelected?()
        case .Emma:
            clearExistingButtons()
            emmaSelected?()
        }
    }
    
    func pullOutShard(success: (() -> Void), fail: (() -> Void)) {
        let wasPulled = shouldHappen(percentage: 50)
        if wasPulled {
            success()
        } else {
            fail()
        }
        
    }
    
    private func shouldHappen(percentage: Double) -> Bool {
        let randomValue = Double.random(in: 0...100)
        return randomValue <= percentage
    }
    
    private func handleWordSelection(_ word: String, rightWord: (() -> Void)?, wrongWord: (() -> Void)?) {
        if word == "Echo" {
            clearExistingButtons()
            rightWord?()
        } else {
            clearExistingButtons()
            wrongWord?()
        }
    }
    
    
    private func takeOrLeave(_ word: String, take: (() -> Void)?, leave: (() -> Void)?) {
        if word == "Take" {
            clearExistingButtons()
            take?()
        } else {
            clearExistingButtons()
            leave?()
        }
    }
    

    
    private func clearExistingButtons() {
        buttons.forEach { $0.removeFromParent() }
        buttons.removeAll()
    }
    
    private func startHeroAction() {
        scene?.run(.playSoundFileNamed("hero.wav", waitForCompletion: false))
    }
    
    private func startVillainAction() {
        scene?.run(.playSoundFileNamed("villain.wav", waitForCompletion: false))
    }
}
