import SwiftUI
import CoreData

class NotesVM: ObservableObject {
    @Published var notes: [Note] = []
    @Published var text = ""

    func fetchItems(context: NSManagedObjectContext, folder: Folder) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "folder == %@", folder)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Note.note, ascending: false)]
        do {
            notes = try context.fetch(request)
        } catch {
            print("Ошибка загрузки: \(error)")
        }
    }

    func addItem(context: NSManagedObjectContext, folder: Folder) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newItem = Note(context: context)
        newItem.note = text
        newItem.isChecked = false
        newItem.folder = folder
        saveContext(context: context, folder: folder)
    }

    func deleteItems(context: NSManagedObjectContext, offsets: IndexSet, folder: Folder) {
        offsets.map { notes[$0] }.forEach(context.delete)
        saveContext(context: context, folder: folder)
    }

    func updateItem(context: NSManagedObjectContext, item: Note, newText: String, folder: Folder) {
        item.note = newText
        saveContext(context: context, folder: folder)
    }

    private func saveContext(context: NSManagedObjectContext, folder: Folder) {
        do {
            try context.save()
            fetchItems(context: context, folder: folder)
            text = ""
        } catch {
            print("Ошибка сохранения: \(error)")
            context.rollback()
        }
    }
}
