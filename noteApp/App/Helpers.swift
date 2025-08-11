import SwiftUI

struct Header: View {
    var image: String
    var title: String?
    var action: () -> Void
    var body: some View {
        HStack {
            Button(action: { action() }) {
                Image(systemName: image)
                    .resizable()
                    .frame(width: 30, height: 20)
                    .foregroundStyle(.white)
            }
            Text(title ?? "")
                .font(.largeTitle)
                .foregroundStyle(.white)
        Spacer()
        }   .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.headCol.opacity(0.8))
    }
}

struct FriendsSheetView: View {
    @ObservedObject var vm: FoldersVM
    var folderId: String

    var body: some View {
        NavigationStack {
            List(vm.friends, id: \.self) { friend in
                Button("Дать доступ: \(friend)") {
                    vm.shareFolder(folderId: folderId, with: friend)
                }
            }
            if vm.isSharing { ProgressView() }
            if let error = vm.errorMessage { Text(error).foregroundColor(.red) }
            if vm.shareSuccess { Text("Папка успешно общая!") }
        }
        .padding()
    }
}

struct FolderRow: View {
    var item: Folder
    var onRename: () -> Void

    var body: some View {
        NavigationLink(destination: NotesView(folder: item)) {
            HStack {
                Image(systemName: "bag.fill")
                Text(item.name ?? "")
            }
        }
        .contextMenu {
            Button("Переименовать", action: onRename)
        }
    }
}

struct AuthBtn: View {
    var text: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(text)
        }   .padding()
            .frame(width: 150, height: 40)
            .background(.btnCol)
            .foregroundStyle(.white)
            .clipShape(.capsule)
    }
}

struct SideBtn: View {
    var image: String
    var action: () -> Void
    var bgColor: Color
    var body: some View {
        Button(action: { action() }) {
            Image(systemName: image)
                .padding(5)
                .background(bgColor)
                .clipShape(.circle)
                .foregroundStyle(.white)
        }
    }
}


