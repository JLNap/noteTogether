import SwiftUI
import CoreData
import FirebaseFirestore
import FirebaseAuth

class FoldersVM: ObservableObject {
    @Published var folders: [Folder] = []
    @Published var sharedFolders: [FolderDisplayModel] = []
    @Published var uid: String = Auth.auth().currentUser?.uid ?? "Нет UID"
    @Published var text = ""
    @Published var friends: [String] = []
    @Published var errorMessage: String?
    @Published var isSharing: Bool = false
    @Published var shareSuccess: Bool = false

    func fetchItems(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Folder.name, ascending: false)]
        do {
            folders = try context.fetch(request)
        } catch {
            print("Ошибка загрузки: \(error)")
        }
    }

    func addItem(context: NSManagedObjectContext) {
        let newItem = Folder(context: context)
        newItem.name = text
        text = ""
        saveContext(context: context)
    }

    func deleteItems(context: NSManagedObjectContext, offsets: IndexSet) {
        offsets.map { folders[$0] }.forEach(context.delete)
        saveContext(context: context)
    }

    func updateItem(context: NSManagedObjectContext, item: Folder, newText: String) {
        item.name = newText
        saveContext(context: context)
    }

    func saveContext(context: NSManagedObjectContext) {
        do {
            try context.save()
            fetchItems(context: context)
            text = ""
        } catch {
            print("Ошибка сохранения: \(error)")
            context.rollback()
        }
    }

    func loadFriends(for userId: String) {
        FriendsManager().fetchFriends(uid: userId) { [weak self] friends in
            DispatchQueue.main.async {
                if let friends = friends {
                    self?.friends = friends
                } else {
                    self?.errorMessage = "Не удалось загрузить друзей"
                }
            }
        }
    }
    
    func uploadFolderToFirestore(folder: Folder, access: [String] = []) {
        guard let folderId = folder.id?.uuidString else { return }
        let db = Firestore.firestore()
        let folderRef = db.collection("folders").document(folderId)
            
        // Получаем все notes этой папки из CoreData
        let notesFetch: NSFetchRequest<Note> = Note.fetchRequest()
        notesFetch.predicate = NSPredicate(format: "folder == %@", folder)
        var notesArray: [[String: Any]] = []
        if let notes = try? folder.managedObjectContext?.fetch(notesFetch) {
            notesArray = notes.map { note in
                [
                    "note": note.note ?? "",
                    "isChecked": note.isChecked
                ]
            }
        }
            
        // Формируем данные для Firestore
        let data: [String: Any] = [
            "id": folderId,
            "name": folder.name ?? "",
            "access": access.isEmpty ? [uid] : access, // uid — это владелец или массив с друзьями
            "createdBy": uid,
            "notes": notesArray,
            "createdAt": FieldValue.serverTimestamp()
        ]
            
        folderRef.setData(data, merge: true)
    }

    func shareFolder(folderId: String, with friendId: String) {
        guard let folder = folders.first(where: { $0.id?.uuidString == folderId }) else { return }
        isSharing = true
        
        // Создаём массив access: владелец + друг
        var sharedWith = [uid, friendId]
        
        // Можно добавить уже существующие access, если до этого папка была кем-то расшарена:
        // (для этого подгружайте access из Firestore, если нужно)
            
        SharedFolders().shareFolder(folderId: folderId, with: friendId) { [weak self] success in
            DispatchQueue.main.async {
                self?.isSharing = false
                self?.shareSuccess = success
                if success {
                    self?.uploadFolderToFirestore(folder: folder, access: sharedWith)
                } else {
                    self?.errorMessage = "Не удалось поделиться папкой"
                }
            }
        }
    }
}
