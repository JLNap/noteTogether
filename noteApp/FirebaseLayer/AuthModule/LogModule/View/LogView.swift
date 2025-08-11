import SwiftUI

struct LogView: View {
    @StateObject var vm = LogViewModel()
    @EnvironmentObject var router: ScreenRouter

    var body: some View {
        ZStack(alignment: .top) {
            Color.bgCol.ignoresSafeArea()
            Header(image: "arrowshape.backward.fill", action: { router.currentScreen = .hello })
            
            VStack {
                VStack {
                    TextField("Почта", text: vm.emailBinding)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    SecureField("Пароль", text: vm.passwordBinding)
                        .textFieldStyle(.roundedBorder)
                }
                AuthBtn(text: "Войти", action: { vm.log() })
            }
            .padding(.horizontal, 20)
            .padding(.top, 70)
        }
        .onChange(of: vm.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                router.currentScreen = .main
            }
        }
    }
}

#Preview {
    LogView()
}
