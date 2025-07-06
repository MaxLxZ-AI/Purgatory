import SwiftUI

struct LoadingView: View {
    
    @State private var opacity: Double = Constants.LoadingConstants.initialOpacity
    private let animationDuration = Constants.LoadingConstants.animationDuration
    
    
    var body: some View {
        ZStack {

            Image(.loadingBackground)
                .fullScreen(ignoreSafeAreaEdges: [.top, .bottom])
            
            Color.black
                .ignoresSafeArea()
                .opacity(opacity)
        }
        
        
        .onAppear() {
            animation()
        }
        
    }
    private func animation() {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Constants.LoadingConstants.delayBeforFirstAnimation) {
            withAnimation(.easeInOut(duration: Constants.LoadingConstants.animationDuration))
                {
                opacity = Constants.LoadingConstants.endOpacity
            }
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Constants.LoadingConstants.animationDuration + Constants.LoadingConstants.delayBeforSecondAnimation)
        {
            withAnimation(.easeInOut(duration: Constants.LoadingConstants.animationDuration)) {
                opacity = Constants.LoadingConstants.initialOpacity
            }
        }
    }
}
