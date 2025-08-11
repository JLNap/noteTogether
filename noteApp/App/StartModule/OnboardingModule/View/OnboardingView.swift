import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var router: ScreenRouter
    var body: some View {
        ZStack(alignment: .top) {
            Color.bgCol.ignoresSafeArea()
            Header(image: "", title: "Добро пожаловать", action: { })
            VStack {
                AuthBtn(text: "Регистрация", action: { router.currentScreen = .reg })
                AuthBtn(text: "Авторизация", action: { router.currentScreen = .log })
                Button(action: { router.currentScreen = .main }) {
                    Text("Без регистрации")
                        .frame(width: 150)
                        .foregroundStyle(.black)
                        .font(.system(size: 15))
                }
            } .padding(.top, 150)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(ScreenRouter())
}
