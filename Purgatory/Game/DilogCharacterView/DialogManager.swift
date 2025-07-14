import SpriteKit

final class DialogManager {
    weak var scene: SKScene?
    
    private var dialogQueue: [(String, SKTexture?)] = []
    private var currentDialog: DilogCharacterView?
    private var isPresenting = false

    init(scene: SKScene? = nil) {
        self.scene = scene
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
        guard let scene = scene, !dialogQueue.isEmpty else { return }

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
            self?.showNextDialog()
        }
    }

    func isDialogActive() -> Bool {
        return currentDialog != nil || !dialogQueue.isEmpty
    }
}
