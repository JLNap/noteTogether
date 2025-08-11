import SwiftUI
import Firebase

@MainActor
class FriendsVM: ObservableObject {
    private var manager: SignOut = SignOut()
    @Published var userInfo: UserInfo?
    @Published var allUsers = [UserInfo]() 
    @Published var friendUid: String = ""
    @Published var friendList = [UserInfo]()
    @Published var friendsUidArr = [String]()
    private var userManager = UserManager()
    private var friendsManager = FriendsManager()
    @Published var incomingRequests: [UserInfo] = []

    func fetchIncomingRequests() {
        guard let uid = userInfo?.uid else { return }
        let ref = Firestore.firestore().collection("users").document(uid)
        ref.addSnapshotListener { [weak self] snapshot, _ in
            if let data = snapshot?.data(), let requests = data["incomingFriendRequests"] as? [String] {
                self?.userManager.getUsersByUIDs(requests) { result in
                    switch result {
                    case .success(let users):
                        DispatchQueue.main.async { self?.incomingRequests = users }
                    case .failure:
                        DispatchQueue.main.async { self?.incomingRequests = [] }
                    }
                }
            } else {
                DispatchQueue.main.async { self?.incomingRequests = [] }
            }
        }
    }

    func acceptFriend(requesterUid: String) {
        guard let uid = userInfo?.uid else { return }
        friendsManager.acceptFriendRequest(for: uid, from: requesterUid) { [weak self] success in
            if success { self?.fetchFriends() }
        }
    }

    func declineFriend(requesterUid: String) {
        guard let uid = userInfo?.uid else { return }
        friendsManager.declineFriendRequest(for: uid, from: requesterUid) { [weak self] success in
            if success { self?.fetchIncomingRequests() }
        }
    }

  
    func getUserInfo() {
        userManager.getUserInfo { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self?.userInfo = user
                    self?.fetchFriends()
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func getAllUsers(){
        userManager.getAllUsers { [unowned self] result in
            switch result {
            case .success(let success):
                self.allUsers = success
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }


    func fetchFriends() {
        guard let uid = userInfo?.uid else { return }
        friendsManager.fetchFriends(uid: uid) { [weak self] friends in
            guard let self = self, let uids = friends else { return }
            DispatchQueue.main.async {
                self.friendsUidArr = uids
                self.loadFriendsInfo(for: uids)
            }
        }
    }

    private func loadFriendsInfo(for uids: [String]) {
        userManager.getUsersByUIDs(uids) { [weak self] (result: Result<[UserInfo], Error>) in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self?.friendList = users
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func sendFriendRequest() {
        guard let uid = userInfo?.uid, !friendUid.isEmpty else { return }
        friendsManager.sendFriendRequest(to: friendUid, from: uid) { [weak self] success in
            if success {
                DispatchQueue.main.async { self?.friendUid = "" }
            }
        }
    }
}

