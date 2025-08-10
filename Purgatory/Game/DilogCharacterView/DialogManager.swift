import SpriteKit



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
            onDialogEnd?()
            return
        }

        let (text, texture) = dialogQueue.removeFirst()

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
        isPresenting = false
        dialog.run(.sequence([
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ])) { [weak self] in
            self?.currentDialog = nil
            if self?.cutsceneManager?.isPlaying == true {
                self?.cutsceneManager?.executeNextAction()
            } else {
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
                CutsceneAction(type: .runBlock({
                    self.cutsceneManager?.dimTheLight()
                }), delay: 0),
                CutsceneAction(type: .showDialog("Welcome to the game!", texture: SKTexture(image: .defaultEnri)), delay: 5),
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
