import SwiftUI

class ScreenRouter: ObservableObject {
    @Published var currentScreen: Screens = .load
    @Published var isLogin: Bool = false
    
    init(){
        self.isLogin = AuthStatus.shared.isLogin
        if isLogin {
            currentScreen = .main
        }
    }
}

enum Screens {
    case load, hello, reg, log, main
}

struct RootView: View {
    @EnvironmentObject var router: ScreenRouter
    
    var body: some View {
        Group {
            switch router.currentScreen {
            case .load:
                LoadView()
            case .hello:
                OnboardingView()
            case .reg:
                RegView()
            case .log:
                LogView()
            case .main:
                TabBar()
            }
        }
    }
}
