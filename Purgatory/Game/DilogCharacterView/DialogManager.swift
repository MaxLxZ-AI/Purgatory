import SpriteKit

// Структура для действий в катсцене
struct CutsceneAction {
    enum ActionType {
        case moveCharacter(Character, to: CGPoint, duration: TimeInterval)
        case showDialog(String, texture: SKTexture?)
        case wait(TimeInterval)
        case cameraMove(to: CGPoint, duration: TimeInterval)
        case playAnimation(Character, animation: String)
    }
    
    let type: ActionType
    let delay: TimeInterval
}

// Менеджер катсцен
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
            isPlaying = false
            return
        }
        
        let action = actions[currentIndex]
        DispatchQueue.main.asyncAfter(deadline: .now() + action.delay) {
            if self.dialogManager.currentDialog == nil {
                self.executeAction(action)
                self.currentIndex += 1
                self.executeNextAction()
            }
        }
    }
    
    private func executeAction(_ action: CutsceneAction) {
        switch action.type {
        case .moveCharacter(let character, let position, let duration):
            character.moveToPosition(position, duration: duration) {
                character.stopMoving()
            }
        case .showDialog(let text, let texture):
            dialogManager.presentSequence([(text, texture)])
        case .wait(let duration):
            // Just wait
            break
        case .cameraMove(let position, let duration):
            // Implement camera movement if needed
            break
        case .playAnimation(let character, let animation):
            // Implement animation if needed
            break
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
            // Очередь пуста — диалоги закончились
            onDialogEnd?()
            return
        }

        let (text, texture) = dialogQueue.removeFirst()

        let dialog = DilogCharacterView(
            text: text,
            charcterTexture: texture ?? SKTexture(image: .calmEnri),
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
        isPresenting = false
        dialog.run(.sequence([
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ])) { [weak self] in
            self?.currentDialog = nil
            if self?.cutsceneManager?.isPlaying == true {
                self?.cutsceneManager?.executeNextAction()
            }
            print(self?.cutsceneManager?.isPlaying)
            self?.showNextDialog()
        }
    }

    func isDialogActive() -> Bool {
        return currentDialog != nil || !dialogQueue.isEmpty
    }
    
    // Методы для создания катсцен
    func createIntroCutscene(enri: Character, emma: Character) -> [CutsceneAction] {
        return [
            CutsceneAction(type: .showDialog("Welcome to the game!", texture: SKTexture(image: .defaultEnri)), delay: 0),
            CutsceneAction(type: .moveCharacter(enri, to: CGPoint(x: enri.position.x - 100, y: enri.position.y), duration: 2.0), delay: 0),
            CutsceneAction(type: .showDialog("Let's explore together!", texture: SKTexture(image: .defaultEmma)), delay: 0),
            CutsceneAction(type: .moveCharacter(enri, to: CGPoint(x: enri.position.x + 100, y: enri.position.y), duration: 2), delay: 0)
        ]
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
