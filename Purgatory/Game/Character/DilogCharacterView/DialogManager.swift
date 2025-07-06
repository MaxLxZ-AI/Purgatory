import SpriteKit

final class DialogManager {
    weak var scene: SKScene?
    
    init(scene: SKScene? = nil) {
        self.scene = scene
    }
    
    func present(text: String, texture: SKTexture?) {
        guard let scene = scene else { return }
        let dilog = DilogCharacterView(
            text: text,
            charcterTexture: texture ?? SKTexture(image: .calmEnri),
            size: CGSize(width: 400, height: 100))
        
        dilog.position = CGPoint(x: scene.frame.midX, y: 100)
        scene.addChild(dilog)
        
        dilog.run(.sequence([
            .fadeIn(withDuration: 0.3),
            .wait(forDuration: 3),
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ]))
    }
    
    
}
