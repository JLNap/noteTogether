import SwiftUI

struct FoldersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var vm = FoldersVM()
    @State private var showEditAlert = false
    @State private var editedText = ""
    @State private var selectedItem: Folder?
    
    @State private var showShareSheet = false
    @State private var sharingFolderId: String?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.bgCol.ignoresSafeArea()
                Header(image: "", action: { })

                VStack {
                    HStack {
                        TextField("Поход в магазин", text: $vm.text)
                            .textFieldStyle(.roundedBorder)
                        SideBtn(image: "plus", action: { vm.addItem(context: viewContext) }, bgColor: .bgCol)
                    }
                    .padding(.bottom, 20)

                    List {
                        Section(header: Text("Общие папки")) {
                            ForEach(vm.sharedFolders, id: \.self) { item in
                                Text(item.name)
                            }
                        }
                        Section(header: Text("Мои папки")) {
                            ForEach(vm.folders, id: \.self) { item in
                                FolderRow(item: item) {
                                    selectedItem = item
                                    editedText = item.name ?? ""
                                    showEditAlert = true
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        if let index = vm.folders.firstIndex(of: item) {
                                            let offsets = IndexSet(integer: index)
                                            vm.deleteItems(context: viewContext, offsets: offsets)
                                        }
                                    } label: {
                                        Text("Удалить")
                                    }
                                    Button("Поделиться") {
                                        sharingFolderId = item.objectID.uriRepresentation().absoluteString
                                        vm.loadFriends(for: vm.uid)
                                        showShareSheet = true
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                .padding(.horizontal, 10)
                .onAppear {
                    vm.fetchItems(context: viewContext)
                }
                .alert("Сменить название покупок", isPresented: $showEditAlert, actions: {
                    TextField("Название покупок", text: $editedText)
                    Button("Сохранить") {
                        if let item = selectedItem {
                            vm.updateItem(context: viewContext, item: item, newText: editedText)
                        }
                    }
                    Button("Отмена", role: .cancel) {}
                }, message: {
                    Text("Измените название покупок")
                })
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let folderId = sharingFolderId {
                FriendsSheetView(vm: vm, folderId: folderId)
            }
        }
    }
}
