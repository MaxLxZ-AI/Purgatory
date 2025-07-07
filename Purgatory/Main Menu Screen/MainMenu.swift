import SwiftUI

struct MainMenu: View {
    @State private var opacity: Double = Constants.MainMenuConstants.initialOpacity
    private let animationDuration = Constants.MainMenuConstants.animationDuration
    @State private var currentImage: ImageResource = .main1
    @State private var isGamePresented = false
//    @State private var isDisabled = true
    @State private var textOpacity: Double = 1
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image(currentImage)
                    .fullScreen(ignoreSafeAreaEdges: [.top, .bottom])
                    .position(x: geometry.size.width / Constants.MainMenuConstants.devide, y: geometry.size.height / Constants.MainMenuConstants.devide)
                    .onTapGesture {
                        isGamePresented.toggle()
                    }
//                    .disabled(isDisabled)
                Text("Tap on the screen to staret game")
                    .foregroundStyle(.white)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.9)
                    .opacity(textOpacity)
            }
            Color.black
                .ignoresSafeArea()
                .opacity(opacity)
            
            if isGamePresented {
                GameFortuneMergeView(isGamePresented: $isGamePresented)
            }
            

        }
        
        .onAppear() {
//            isDisabled = true
            firstAnimation()
        }
    }
    
    
    private func firstAnimation() {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Constants.LoadingConstants.delayBeforFirstAnimation) {
                if #available(iOS 17.0, *) {
                    withAnimation(.easeInOut(duration: Constants.LoadingConstants.animationDuration))
                    {
                        opacity = Constants.MainMenuConstants.endOpacity
                        
                    } completion: {
//                        isDisabled = false
                        
                        secondAnimation()
                    }
                } else {
                }
            }
    }
    
    private func secondAnimation() {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Constants.MainMenuConstants.delayAfterFirstAnimation) {
                if #available(iOS 17.0, *) {
                    withAnimation(.easeInOut(duration: Constants.MainMenuConstants.animationDuration)) {
                        opacity = Constants.MainMenuConstants.initialOpacity
                    } completion: {
                        textOpacity = 0
                        opacity = Constants.MainMenuConstants.endOpacity
                        currentImage = .main2
                        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.MainMenuConstants.darkEnriDelay) {
                            textOpacity = 1
                            currentImage = .main1
                            secondAnimation()
                        }
                    }
                } else {
                }
                
            }
    }
}

