import SpriteKit



final class GameFortuneMergeScene: SKScene {
    var parentFortuneMergeView: GameFortuneMergeView?
    
    var character: Character!
    var moveLeftButton: SKSpriteNode!
    var moveRightButton: SKSpriteNode!
    
    var moveButtons: [Direction: SKSpriteNode] = [:]
    
    var dilogManager: DialogManager!
    
    override func didMove(to view: SKView) {
        setUpBackground()
        setUpCharcter()
        setupControlButtons()
        dilogManager = DialogManager(scene: self)
        
    }
    
    private func setUpBackground() {
        let background = SKSpriteNode(texture: SKTexture(image: .firstRoom),
                                      size: CGSize(width: frame.width, height: frame.height))
        background.zPosition = 0
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)
    }
    
    private func setUpCharcter() {
        let calmTexture = SKTexture(image: .upWalkingClmEnri)
        
        character = Character(
            calmState: calmTexture,
            size: CGSize(width: 64, height: 64)
        )
        character.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(character)
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
        dilogManager.present(text: "The first version of this screen, something myght not work properly", texture: SKTexture(image: .defaultEnri))
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            
            
            for node in nodes {
                if let direction = moveButtons.first(where: { $0.value == node })?.key {
                    character.startMoving(in: direction)
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
            character.stopMoving()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for button in moveButtons.values {
            button.alpha = 0.5
        }
        character.stopMoving()
    }
}

// Helper extension for vector normalization
extension CGVector {
    func normalized() -> CGVector {
        let length = sqrt(dx*dx + dy*dy)
        return length > 0 ? CGVector(dx: dx/length, dy: dy/length) : .zero
    }
}

