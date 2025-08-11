import SwiftUI

@MainActor
class LogViewModel: ObservableObject{
    var logManager: LogUserProtocol = LogManager()

    @Published var isLoggedIn: Bool = false
    @Published var user: AuthModel = AuthModel(email: "", password: "")

    var emailBinding: Binding<String> {
        Binding {
            self.user.email
        } set: { newValue in
            self.user.email = newValue
        }
    }
    var passwordBinding: Binding<String> {
        Binding {
            self.user.password
        } set: { newValue in
            self.user.password = newValue
        }
    }
    
    func log(){
        logManager.logUser(user: AuthModel(email: user.email, password: user.password)) { [unowned self] result in
            switch result {
            case .success(let isLogin):
                self.isLoggedIn = isLogin
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
