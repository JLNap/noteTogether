import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    let uid: String = Auth.auth().currentUser?.uid ?? "Нет UID"
    @EnvironmentObject var router: ScreenRouter
    @State var isCodCopy: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.bgCol.ignoresSafeArea()
            Header(image: "", action: { })
            
            VStack {
                HStack {
                    SideBtn(image: "pencil", action: { }, bgColor: .bgCol)
                    VStack(alignment: .leading) {
                        Text("Профиль")
                            .font(.headline)
                        Button(action: {
                            UIPasteboard.general.string = uid
                            isCodCopy.toggle()
                        }) {
                            Text(isCodCopy ? "Код друга скопирован в буфер обмена" : "Код друга: \(uid)")
                                .font(.subheadline)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    SideBtn(image: "figure.walk", action: {
                        SignOut().signOut()
                        router.currentScreen = .hello
                    }, bgColor: .btnCol)
                } .padding(.horizontal, 10)
            }
        }
    }
}

#Preview {
    ProfileView()
}
