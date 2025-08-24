import SpriteKit

struct CutsceneAction {
    enum ActionType {
        case moveCharacter(GameCharacter, to: CGPoint, duration: TimeInterval)
        case showDialog(String, texture: SKTexture?)
        case wait(TimeInterval)
        case cameraMove(to: CGPoint, duration: TimeInterval)
        case playAnimation(GameCharacter, animation: String)
        case runBlock(() -> Void)
    }
    
    let type: ActionType
    let delay: TimeInterval
}

enum CutsceneType {
    case introduction
    case secondRoom
    case illusionTrap
    case lastAttemptHasBeenLost
}
    


class CutsceneManager {
    private var actions: [CutsceneAction] = []
    private var currentIndex = 0
    var isPlaying = false
    private var dialogManager: DialogManager
    private var scene: SKScene?
    
    init(dialogManager: DialogManager, scene: SKScene?) {
        self.dialogManager = dialogManager
        self.scene = scene
    }
    
    func playCutscene(_ actions: [CutsceneAction]) {
        
        self.actions = actions
        self.currentIndex = 0
        self.isPlaying = true
        executeNextAction()
    }
    
    func dimTheLight() {
        guard let scene = scene else {
            return
        }
        let coverNode = SKSpriteNode(color: .black, size: scene.size)
        
        coverNode.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        coverNode.zPosition = 9999
        coverNode.color = .black
        coverNode.alpha = 0
        scene.addChild(coverNode)
        coverNode.run(.sequence([
            .fadeIn(withDuration: 0),
            .fadeOut(withDuration: 5),
            .removeFromParent()
        ]))
    }
    
    func dimTheLightBeforeExtraction() {
        guard let scene = scene else {
            return
        }
        let coverNode = SKSpriteNode(color: .black, size: scene.size)
        
        coverNode.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        coverNode.zPosition = 9999
        coverNode.color = .black
        coverNode.alpha = 0
        scene.addChild(coverNode)
        coverNode.run(.sequence([
            .fadeIn(withDuration: 5),
            
        ]))
    }
    
    func executeNextAction() {
        guard currentIndex < actions.count else {
            isPlaying = false
            return
        }
        
        let action = actions[currentIndex]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + action.delay) {
            if self.dialogManager.currentDialog == nil {
                self.executeAction(action)
                self.currentIndex += 1
                self.executeNextAction()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.executeNextAction()
                }
            }
        }
    }
    
    private func executeAction(_ action: CutsceneAction) {
        switch action.type {
        case .moveCharacter(let character, let position, let duration):
            scene?.isUserInteractionEnabled = false
            character.moveToPosition(position, duration: duration) {
                character.stopMoving()
                self.scene?.isUserInteractionEnabled = true
            }
        case .showDialog(let text, let texture):
            dialogManager.presentSequence([(text, texture)])
        case .wait(_):
            break
        case .cameraMove(_, _):
            break
        case .playAnimation(_, _):
            break
        case .runBlock(let block):
            block()
        }
    }
    
    func isCutscenePlaying() -> Bool {
        return isPlaying
    }
    
    func stop() {
        isPlaying = false
        actions.removeAll()
        currentIndex = 0
    }
}
