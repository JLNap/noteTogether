import Foundation
import FirebaseFirestore
import FirebaseAuth

struct UserInfo: Identifiable, Equatable {
    var id: String { uid }
    let uid: String
    let name: String
    let regData: Date

    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        if let ts = data["regisDate"] as? Timestamp {
            self.regData = ts.dateValue()
        } else {
            self.regData = Date()
        }
    }

    init(document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        self.init(data: data)
    }
}

class UserManager{
    
    func getUserInfo(completion: @escaping (Result<UserInfo, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            print("Текущий пользователь:", user.uid)
            Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .addSnapshotListener { snap, err in
                    if let err = err {
                        print("Ошибка:", err)
                        completion(.failure(err))
                        return
                    }
                    if let data = snap?.data() {
                        print("Данные пользователя:", data)
                        let userInfo = UserInfo(data: data)
                        completion(.success(userInfo))
                    } else {
                        print("Нет данных по uid \(user.uid)")
                    }
                }
        } else {
            print("Нет авторизованного пользователя!")
        }
    }
    
    func getUsersByUIDs(_ uids: [String], completion: @escaping (Result<[UserInfo], Error>) -> Void) {
        guard !uids.isEmpty else {
            completion(.success([]))
            return
        }
        let ref = Firestore.firestore().collection("users")
        ref.whereField("uid", in: uids).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let users = snapshot?.documents.compactMap { UserInfo(document: $0) } ?? []
                completion(.success(users))
            }
        }
    }
    
    func getAllUsers(completion: @escaping (Result<[UserInfo], Error>) -> Void){
        
        
        Firestore.firestore()
            .collection("users")
            .addSnapshotListener { snap, err in
                guard err == nil else {
                    completion(.failure(err!))
                    return
                }
                
                var users = [UserInfo]()
                
                if let docs = snap?.documents{
                    docs.forEach { item in
                        let doc = item.data()
                        let user = UserInfo(data: doc)
                        users.append(user)
                    }
                    
                    completion(.success(users))
                }
            }
    }
}


