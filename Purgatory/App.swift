import SwiftUI

@main
struct PurgatoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var isMenu = true
    
    
    @State var isLoad = false
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isMenu { MainMenu() }
                else { LoadingView() }
//                LoadingView()
//                UIKitViewControllerWrapper()
//                ConnectionView()
            }
            .ignoresSafeArea()
            .onAppear {
                AppDelegate.orientationLock = .landscape
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.LoadingConstants.loadingDuration){
                    AppDelegate.orientationLock = .landscape
                    isMenu = true
                    isLoad = false
                }
            }
        }
    }
}
