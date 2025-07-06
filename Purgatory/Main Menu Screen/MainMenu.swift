import SwiftUI

struct MainMenu: View {
    @State private var opacity: Double = Constants.MainMenuConstants.initialOpacity
    private let animationDuration = Constants.MainMenuConstants.animationDuration
    @State private var currentImage: ImageResource = .main1
    @State private var isGamePresented = false
    
    var body: some View {
        ZStack {

            GeometryReader { geometry in
                Image(currentImage)
                    .fullScreen(ignoreSafeAreaEdges: [.top, .bottom])
                    .position(x: geometry.size.width / Constants.MainMenuConstants.devide, y: geometry.size.height / Constants.MainMenuConstants.devide)
                
                HStack {
                    VStack(spacing: 25) {
                        MenuButton(bImage: Image(.fortuneMergeStartButton)) {
                            isGamePresented.toggle()
                        }
                        .frame(width: geometry.size.width * 0.2)
                        MenuButton(bImage: Image(.fortuneMergeStartButton)) {
                            isGamePresented.toggle()
                        }
                        .frame(width: geometry.size.width * 0.2)
                        MenuButton(bImage: Image(.fortuneMergeStartButton)) {
                            isGamePresented.toggle()
                        }
                        .frame(width: geometry.size.width * 0.2)
                        
                    }
                }
                .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.5)
            }

            
            Color.black
                .ignoresSafeArea()
                .opacity(opacity)
            
            if isGamePresented {
                GameFortuneMergeView(isGamePresented: $isGamePresented)
            }
        }
        .onAppear() {
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
                        opacity = Constants.MainMenuConstants.endOpacity
                        currentImage = .main2
                        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.MainMenuConstants.darkEnriDelay) {
                            currentImage = .main1
                            secondAnimation()
                        }
                    }
                } else {
                }
                
            }
    }
}

