import SpriteKit



final class GameFortuneMergeScene: SKScene {
    var parentFortuneMergeView: GameFortuneMergeView?
    
    var enri: Enri!
    var emma: Emma!
    var moveLeftButton: SKSpriteNode!
    var moveRightButton: SKSpriteNode!
    
    var moveButtons: [Direction: SKSpriteNode] = [:]
    
    var dilogManager: DialogManager!
    
    private var characters: [Character] = []
    private var dialogTriggers: [DialogTriggerNode] = []
    
    override func didMove(to view: SKView) {
        setUpBackground()
        setUpEnri()
        setUpEmma()
        setupControlButtons()
        dilogManager = DialogManager(scene: self)
        setUpTrigger()
        
    }
    
    private func setUpTrigger() {
        let trigger = DialogTriggerNode(texture: SKTexture(image: .wft),
                                       size: CGSize(width: 100, height: 100),
                                       dialogManager: dilogManager)
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
        emma.position = CGPoint(x: frame.midX + 75, y: frame.midY)
        characters.append(emma)
        addChild(emma)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Update dialog triggers
        dialogTriggers.forEach { trigger in
            trigger.update(with: characters)
        }
    }
    
    private func setupControlButtons() {
        let buttonSize = CGSize(width: 80, height: 80)
        
        let leftButton = SKSpriteNode(color: .gray, size: buttonSize)
        leftButton.position = CGPoint(x: 100, y: 150)
        leftButton.name = "left"
        leftButton.alpha = 0.5
        addChild(leftButton)
        moveButtons[.left] = leftButton
        
        let rightButton = SKSpriteNode(color: .gray, size: buttonSize)
        rightButton.position = CGPoint(x: 200, y: 150)
        rightButton.name = "right"
        rightButton.alpha = 0.5
        addChild(rightButton)
        moveButtons[.right] = rightButton
        
        let upButton = SKSpriteNode(color: .gray, size: buttonSize)
        upButton.position = CGPoint(x: 150, y: 230)
        upButton.name = "up"
        upButton.alpha = 0.5
        addChild(upButton)
        moveButtons[.up] = upButton
        
        let downButton = SKSpriteNode(color: .gray, size: buttonSize)
        downButton.position = CGPoint(x: 150, y: 70)
        downButton.name = "down"
        downButton.alpha = 0.5
        addChild(downButton)
        moveButtons[.down] = downButton
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        dilogManager.present(text: "The first version of this screen, something myght not work properly", texture: SKTexture(image: .defaultEnri))
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            
            
            for node in nodes {
                if let direction = moveButtons.first(where: { $0.value == node })?.key {
                    enri.startMoving(in: direction)
                    emma.startMoving(in: direction)
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
            
            for node in nodes {
                if moveButtons.values.contains(node as! SKSpriteNode) {
                    shouldStop = false
                    break
                }
            }
        }
        
        if shouldStop {
            enri.stopMoving()
            emma.stopMoving()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for button in moveButtons.values {
            button.alpha = 0.5
        }
        enri.stopMoving()
        emma.stopMoving()
    }
}

// Helper extension for vector normalization
extension CGVector {
    func normalized() -> CGVector {
        let length = sqrt(dx*dx + dy*dy)
        return length > 0 ? CGVector(dx: dx/length, dy: dy/length) : .zero
    }
}

