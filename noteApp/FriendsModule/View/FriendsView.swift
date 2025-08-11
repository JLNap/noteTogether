import SwiftUI

struct FriendsView: View {
    @StateObject var vm: FriendsVM = FriendsVM()
    @EnvironmentObject var appVm: ScreenRouter
    @State var isAddTapped: Bool = false
    @State var isAcceptFriends: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.bgCol.ignoresSafeArea()
            Header(image: "", action: { })
            
            VStack {
                HStack {
                    if isAddTapped {
                        TextField("Введите uid друга", text: $vm.friendUid)
                            .textFieldStyle(.roundedBorder)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        SideBtn(image: "person.fill.checkmark", action: {
                            vm.sendFriendRequest()
                            withAnimation { isAddTapped.toggle() }
                        }, bgColor: .bgCol)
                        .disabled(vm.userInfo?.uid.isEmpty ?? true)
                    } else {
                        SideBtn(image: "plus", action: {
                            withAnimation { isAddTapped.toggle() }
                        }, bgColor: .bgCol)
                        
                        VStack(alignment: .leading) {
                            Text("Профиль")
                                .font(.headline)
                            Text("Список друзей")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.white)
                        Spacer()
                        SideBtn(image: isAcceptFriends ? "person.fill" : "bell.fill", action: {
                            withAnimation { isAcceptFriends.toggle() }
                        }, bgColor: .red)
                    }
                }
                .animation(.bouncy, value: isAddTapped)
                .padding(.horizontal, 10)
                .padding(.bottom, isAddTapped ? 22 : 15)
                if isAcceptFriends {
                    Text("Заявки в друзья").font(.headline)
                    List {
                        ForEach(vm.incomingRequests) { user in
                            HStack {
                                Text(user.name)
                                Spacer()
                                Button("Принять") {
                                    vm.acceptFriend(requesterUid: user.uid)
                                }
                                Button("Отклонить") {
                                    vm.declineFriend(requesterUid: user.uid)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                } else {
                    Text("Мои друзья").font(.headline)
                    List {
                        ForEach(vm.friendList) { user in
                            VStack {
                                Text(user.name)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .onAppear {
                        vm.getUserInfo()
                        vm.getAllUsers()
                        vm.fetchIncomingRequests()
                    }
                }
            }
            .onChange(of: vm.userInfo) { _ in
                vm.fetchFriends()
            }
        }
    }
}
#Preview {
    FriendsView()
}
