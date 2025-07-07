import SwiftUI
import SpriteKit

struct GameFortuneMergeView: View {
    @Binding var isGamePresented: Bool
    @State private var gameFortuneMergeScene = GameFortuneMergeScene()
    
    
    @State var isSettiFortuneMergeesented: Bool = false
    @State var isWinFortuneMergeented: Bool = false
    
    var body: some View {
        ZStack {
            SpriteView(scene: gameFortuneMergeScene).ignoresSafeArea()
        }
        
        .onAppear {
            setupFortuneMergeScene()
        }
    }
    
    private func setupFortuneMergeScene() {
        gameFortuneMergeScene.scaleMode = .aspectFill
        gameFortuneMergeScene.size = UIScreen.main.bounds.size
        gameFortuneMergeScene.parentFortuneMergeView = self
    }
}
