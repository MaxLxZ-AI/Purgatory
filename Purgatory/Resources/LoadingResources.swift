import SwiftUI

extension Image {
    func setAsBackground() -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fill)
        
            .frame(width: UIDevice.current.orientation.isLandscape
                          ? UIScreen.main.bounds.height
                          : UIScreen.main.bounds.width,
                   
                   height: UIDevice.current.orientation.isLandscape
                          ? UIScreen.main.bounds.width
                          : UIScreen.main.bounds.height)
        
            .ignoresSafeArea()
    }
    
    func setAsCustom(widthValue: CGFloat) -> some View {
        let deviderValue: CGFloat = UIDevice.current.orientation.isLandscape ? 2000 : 1080
        
        return self.resizable()
                   .aspectRatio(contentMode: .fit)
                   .frame(width: UIScreen.main.bounds.width * (widthValue / deviderValue))
    }
}

struct Offsdinator {
    
    static var isBigScreen: Bool { UIScreen.main.bounds.height > 736 }
    
    static func yOffset(multiplier: CGFloat) -> CGFloat {
        UIDevice.current.orientation.isLandscape
        ? UIScreen.main.bounds.width * multiplier
        : UIScreen.main.bounds.height * multiplier
    }
    
    static func xOffset(multiplier: CGFloat) -> CGFloat {
        UIDevice.current.orientation.isLandscape
        ? UIScreen.main.bounds.height * multiplier
        : UIScreen.main.bounds.width * multiplier
    }
}



extension Image {
    func fullScreen(ignoreSafeAreaEdges: Edge.Set = .all) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
            .ignoresSafeArea(edges: ignoreSafeAreaEdges)
    }
}



import SwiftUI

struct MenuButton: View {
    @State private var scaleValue = 1.0
    private let bImage: Image
    private let action: () -> Void
    init(scaleValue: Double = 1.0, bImage: Image, action: @escaping () -> Void) {
        self.bImage = bImage
        self.action = action
    }
    var body: some View {
        Button {
        } label: {
            bImage
                .resizable()
                .scaledToFit()
                .scaleEffect(scaleValue)
                .animation(.easeInOut(duration: 0.07), value: scaleValue)
                .onLongPressGesture(minimumDuration: .infinity) {
                } onPressingChanged: { isStarted in
                    isStarted ? tapAction() : dragAction()
                }
        }
    }
    private func tapAction() {
        scaleValue = 0.94
    }
    private func dragAction() {
//        ChickEscapeVibroManager.shared.makeTouch(with: .soft)
//        ChickEscapeSoundManager.shared.defaultButtonFeedback()
        scaleValue = 1.0
        action()
    }
}
