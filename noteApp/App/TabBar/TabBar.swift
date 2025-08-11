import SwiftUI

struct TabBar: View {
    @State private var selectedTab = 1
    
    init() {
          let appearance = UITabBarAppearance()
          appearance.configureWithOpaqueBackground()
          appearance.backgroundColor = UIColor.white

          UITabBar.appearance().standardAppearance = appearance
          if #available(iOS 15.0, *) {
              UITabBar.appearance().scrollEdgeAppearance = appearance
          }
      }
    var body: some View {
            TabView(selection: $selectedTab) {
                FriendsView()
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Друзья")
                    }
                    .tag(0)
                
                FoldersView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .tabItem {
                        Image(systemName: "bag")
                        Text("Покупки")
                    }
                    .tag(1)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Профиль")
                    }
                    .tag(2)
            }
            .accentColor(.black)
        }
}

#Preview {
    TabBar()
}
