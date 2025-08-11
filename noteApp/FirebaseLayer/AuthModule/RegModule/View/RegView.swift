import SwiftUI

struct RegView: View {
    
    @StateObject var vm = RegViewModel()
    @EnvironmentObject var router: ScreenRouter
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.bgCol.ignoresSafeArea()
            Header(image: "arrowshape.backward.fill", action: { router.currentScreen = .hello })
            
            VStack {
                VStack {
                    TextField("Имя", text: vm.nameBinding)
                        .autocapitalization(.none)
                        .keyboardType(.namePhonePad)
                    TextField("Почта", text: vm.emailBinding)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    SecureField("Пароль", text: vm.passwordBinding)
                }.textFieldStyle(.roundedBorder)
                AuthBtn(text: "Регистрация", action: { vm.reg() })
            }
            .padding(.horizontal, 20)
            .padding(.top, 70)
        }
        .onChange(of: vm.isUserCreated) { oldValue, newValue in
            if newValue {
                router.currentScreen = .log
            }
        }
    }
}

#Preview {
    RegView()
}
