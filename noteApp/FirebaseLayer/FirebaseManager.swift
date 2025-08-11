import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol RegUserProtocol: AnyObject {
    func regUser(user: AuthModel, completion: @escaping (Result<Bool, Error>) -> Void)
}

class RegManager: RegUserProtocol {
    var backgroudQueue = DispatchQueue.global(qos: .userInteractive)
    var lock = NSLock()
    func regUser(user: AuthModel, completion: @escaping (Result<Bool, Error>) -> Void) {
        backgroudQueue.async {
            Auth.auth()
                .createUser(withEmail: user.email, password: user.password) { [weak self] result, error in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        completion(.failure(error!))
                        return
                    }
                    result?.user.sendEmailVerification()
                    if let currentUser = result?.user{
                        self?.lock.lock()
                        self?.saveUserData(uid: currentUser.uid, user: user)
                    }
                    
                    try? Auth.auth().signOut()
                    completion(.success(true))
                    
                }
        }
    }
    
    private func saveUserData(uid: String, user: AuthModel){
        backgroudQueue.async {
            let ref = Firestore.firestore()
                .collection("users")
                .document(uid)
            
            ref.setData([
                "name": user.name,
                "email": user.email,
                "uid": uid,
                "regisDate": Date(),
                "friends": user.friends,
            ]) { [weak self] error in
                
                self?.lock.unlock()
            }
        }
    }
    
    private func savePhoto(uid: String, image: Data?, completion: @escaping (Result<URL, Error>) -> Void){
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        guard let imageData = image else { return }
        
        let ref = Storage.storage().reference().child("avatar/\(uid)/photo.jpg")
        
        DispatchQueue.global(qos: .userInteractive).async{
            ref.putData(imageData, metadata: metadata) { meta, err in
                guard let _ = meta else {
                    completion(.failure(err!))
                    return
                }
                
                ref.downloadURL { url, err in
                    guard let url = url else {
                        completion(.failure(err!))
                        return
                    }
                    
                    completion(.success(url))
                }
            }
        }
    }
}


protocol LogUserProtocol: AnyObject {
    func logUser(user: AuthModel, completion: @escaping(Result<Bool, Error>) -> Void)
}

class LogManager: LogUserProtocol {
    func logUser(user: AuthModel, completion: @escaping (Result<Bool, any Error>) -> Void) {
        Auth.auth()
            .signIn(withEmail: user.email, password: user.password) { result, error in
                guard error == nil else {
                    print(error!.localizedDescription)
                    completion(.failure(error!))
                    return
                }
                if let user = result?.user, user.isEmailVerified {
                    print("Пользователь верифицирован")
                    completion(.success(true))
                } else {
                    print("Пользователь не верифицирован")
                    completion(.success(false))
                }
            }
    }
}

class AuthStatus{
    static let shared = AuthStatus()
    private init(){}
    var isLogin: Bool {
        if let _ = Auth.auth().currentUser {
            return true
        }
        return false
    }
}

class SignOut{
    func signOut() {
        try? Auth.auth().signOut()
    }
}

protocol FriendsProtocol {
    func sendFriendRequest(to uid: String, from requesterUid: String, completion: @escaping (Bool) -> Void)
    func acceptFriendRequest(for uid: String, from requesterUid: String, completion: @escaping (Bool) -> Void)
    func declineFriendRequest(for uid: String, from requesterUid: String, completion: @escaping (Bool) -> Void)
    func fetchFriends(uid: String, completion: @escaping ([String]?) -> Void)
    func addFriend(uid: String, friend: String, completion: @escaping (Bool) -> Void)
    func delFriend(uid: String, friend: String, completion: @escaping (Bool) -> Void)
}

class FriendsManager: FriendsProtocol {
    
        func sendFriendRequest(to uid: String, from requesterUid: String, completion: @escaping (Bool) -> Void) {
            let ref = Firestore.firestore().collection("users").document(uid)
            ref.updateData([
                "incomingFriendRequests": FieldValue.arrayUnion([requesterUid])
            ]) { error in
                completion(error == nil)
            }
        }

        func acceptFriendRequest(for uid: String, from requesterUid: String, completion: @escaping (Bool) -> Void) {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(uid)
            let requesterRef = db.collection("users").document(requesterUid)

            let batch = db.batch()
            // Удалить заявку у себя, добавить в друзья себе и другу
            batch.updateData([
                "incomingFriendRequests": FieldValue.arrayRemove([requesterUid]),
                "friends": FieldValue.arrayUnion([requesterUid])
            ], forDocument: userRef)
            batch.updateData([
                "friends": FieldValue.arrayUnion([uid])
            ], forDocument: requesterRef)
            batch.commit { error in
                completion(error == nil)
            }
        }

        func declineFriendRequest(for uid: String, from requesterUid: String, completion: @escaping (Bool) -> Void) {
            let ref = Firestore.firestore().collection("users").document(uid)
            ref.updateData([
                "incomingFriendRequests": FieldValue.arrayRemove([requesterUid])
            ]) { error in
                completion(error == nil)
            }
        }

    func fetchFriends(uid: String, completion: @escaping ([String]?) -> Void) {
        guard !uid.isEmpty else {
            completion(nil)
            return
        }
        let ref = Firestore.firestore().collection("users").document(uid)
        ref.getDocument { (snapshot, error) in
            if let data = snapshot?.data(), let friends = data["friends"] as? [String] {
                completion(friends)
            } else {
                completion(nil)
            }
        }
    }
    

    func addFriend(uid: String, friend: String, completion: @escaping (Bool) -> Void) {
        let ref = Firestore.firestore().collection("users").document(uid)
        ref.updateData([
            "friends": FieldValue.arrayUnion([friend])
        ]) { error in
            completion(error == nil)
        }
    }

    func delFriend(uid: String, friend: String, completion: @escaping (Bool) -> Void) {
        let ref = Firestore.firestore().collection("users").document(uid)
        ref.updateData([
            "friends": FieldValue.arrayRemove([friend])
        ]) { error in
            completion(error == nil)
        }
    }
}

protocol SharedProtocol {
    func shareFolder(folderId: String, with userId: String, completion: @escaping (Bool) -> Void)
}

final class SharedFolders: SharedProtocol {
    func shareFolder(folderId: String, with userId: String, completion: @escaping (Bool) -> Void) {
        let ref = Firestore.firestore().collection("folders")
            .document(folderId)
        ref.updateData([
            "access": FieldValue.arrayUnion([userId])
        ]) { error in
            completion(error == nil)
        }
    }
}
