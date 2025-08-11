import SwiftUI

@MainActor
class RegViewModel: ObservableObject {
    
    @Published var user: AuthModel = AuthModel(name: "", email: "", password: "")
    
    var emailBinding: Binding<String> {
        Binding {
            self.user.email
        } set: { newValue in
            self.user.email = newValue
        }
    }
    var nameBinding: Binding<String> {
        Binding {
            self.user.name ?? ""
        } set: { newValue in
            self.user.name = newValue
        }
    }
    var passwordBinding: Binding<String> {
        Binding {
            self.user.password
        } set: { newValue in
            self.user.password = newValue
        }
    }
    
    @Published var isUserCreated: Bool = false
    
    var regManager: RegUserProtocol = RegManager()
    
    func reg() {
        regManager.regUser(user: user) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                self.isUserCreated = success
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
