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
    
    func executeNextAction() {
        guard currentIndex < actions.count else {
//            print("Cutscene finished - all actions completed")
            isPlaying = false
            return
        }
        
        let action = actions[currentIndex]
//        print("Executing cutscene action \(currentIndex + 1)/\(actions.count) with delay: \(action.delay)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + action.delay) {
            if self.dialogManager.currentDialog == nil {
                self.executeAction(action)
                self.currentIndex += 1
                self.executeNextAction()
            } else {
//                print("Dialog is active, waiting for dialog to finish before executing action")
                // Попробуем снова через небольшую задержку
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.executeNextAction()
                }
            }
        }
    }
    
    private func executeAction(_ action: CutsceneAction) {
        switch action.type {
        case .moveCharacter(let character, let position, let duration):
//            print("Moving character to position: \(position)")
            scene?.isUserInteractionEnabled = false
            character.moveToPosition(position, duration: duration) {
                character.stopMoving()
                self.scene?.isUserInteractionEnabled = true
            }
        case .showDialog(let text, let texture):
//            print("Showing dialog: \(text)")
            dialogManager.presentSequence([(text, texture)])
        case .wait(let duration):
//            print("Waiting for \(duration) seconds")
            break
        case .cameraMove(let position, let duration):
//            print("Moving camera to position: \(position)")
            break
        case .playAnimation(let character, let animation):
//            print("Playing animation: \(animation)")
            break
        case .runBlock(let block):
//            print("Executing cutscene block")
            block()
//            print("Cutscene block executed successfully")
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

final class DialogManager {
    weak var scene: SKScene?
    
    private var dialogQueue: [(String, SKTexture?)] = []
    var currentDialog: DilogCharacterView?
    private var isPresenting = false

    var onDialogEnd: (() -> Void)?
    var cutsceneManager: CutsceneManager?

    init(scene: SKScene? = nil) {
        self.scene = scene
        self.cutsceneManager = CutsceneManager(dialogManager: self, scene: scene)
    }

    func presentSequence(_ dialogs: [(String, SKTexture?)]) {
//        print("Presenting sequence with \(dialogs.count) dialogs")
        dialogQueue = dialogs
        isPresenting = false
        showNextDialog()
    }

    func handleTap() {
        if currentDialog != nil {
            dismissCurrentDialog()
        } else if !dialogQueue.isEmpty {
            showNextDialog()
        }
    }

    private func showNextDialog() {
        guard let scene = scene, !dialogQueue.isEmpty else {
//            print("No more dialogs to show, calling onDialogEnd")
            onDialogEnd?()
            return
        }

        let (text, texture) = dialogQueue.removeFirst()
//        print("Showing dialog: \(text)")

        let dialog = DilogCharacterView(
            text: text,
            charcterTexture: texture,
            size: CGSize(width: 400, height: 100)
        )

        dialog.position = CGPoint(x: scene.frame.midX, y: 100)
        dialog.alpha = 0
        scene.addChild(dialog)
        currentDialog = dialog
        isPresenting = true

        dialog.run(.fadeIn(withDuration: 0.3))
    }

    private func dismissCurrentDialog() {
        guard let dialog = currentDialog else { return }
//        print("Dismissing current dialog")
        isPresenting = false
        dialog.run(.sequence([
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ])) { [weak self] in
//            print("Dialog dismissed, currentDialog set to nil")
            self?.currentDialog = nil
            if self?.cutsceneManager?.isPlaying == true {
//                print("Cutscene is playing, executing next action")
                self?.cutsceneManager?.executeNextAction()
            } else {
//                print("Cutscene is not playing, showing next dialog if available")
                self?.showNextDialog()
            }
        }
    }

    func isDialogActive() -> Bool {
        return currentDialog != nil || !dialogQueue.isEmpty
    }
    
    func createIntroCutscene(enri: GameCharacter, emma: GameCharacter, cutsceneType: CutsceneType, onEndOfCutscene: @escaping () -> Void) -> [CutsceneAction] {
        var actions: [CutsceneAction] = []
        switch cutsceneType {
        case .introduction:
            actions = [
                CutsceneAction(type: .showDialog("Welcome to the game!", texture: SKTexture(image: .defaultEnri)), delay: 0),
                CutsceneAction(type: .moveCharacter(emma, to: CGPoint(x: emma.position.x - 100, y: emma.position.y), duration: 2.0), delay: 0),
                CutsceneAction(type: .showDialog("Let's explore together!", texture: SKTexture(image: .defaultEmma)), delay: 2),
                CutsceneAction(type: .moveCharacter(enri, to: CGPoint(x: enri.position.x + 100, y: enri.position.y), duration: 2), delay: 0),
                CutsceneAction(type: .runBlock(onEndOfCutscene), delay: 2)
            ]
        case .secondRoom:
            actions = [
                CutsceneAction(type: .runBlock(onEndOfCutscene), delay: 0)
            ]
        }

        
//        print("Created cutscene with \(actions.count) actions")
        return actions
    }
    
    func playCutscene(_ actions: [CutsceneAction]) {
        cutsceneManager?.playCutscene(actions)
    }
    
    func isCutscenePlaying() -> Bool {
        return cutsceneManager?.isCutscenePlaying() ?? false
    }
    
    func stopCutscene() {
        cutsceneManager?.stop()
    }
}
