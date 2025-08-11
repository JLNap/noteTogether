import SwiftUI

struct NotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm = NotesVM()
    var folder: Folder
    @State private var showEditAlert = false
    @State private var editedText = ""
    @State private var selectedItem: Note?
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.bgCol.ignoresSafeArea()
            Header(image: "", action: { })
            
            VStack {
                HStack {
                    SideBtn(image: "arrow.left", action: { dismiss() }, bgColor: .black)
                    TextField("Добавьте товар", text: $vm.text)
                        .textFieldStyle(.roundedBorder)
                    SideBtn(image: "plus", action: { vm.addItem(context: viewContext, folder: folder) }, bgColor: .bgCol)
                }
                List {
                    ForEach(vm.notes, id: \.objectID) { item in
                        HStack {
                            Image(item.isChecked ? "checkOn" : "checkOff")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    item.isChecked.toggle()
                                    try? viewContext.save()
                                    vm.fetchItems(context: viewContext, folder: folder)
                                }
                            Text(item.note ?? "")
                                .onTapGesture {
                                    selectedItem = item
                                    editedText = item.note ?? ""
                                    showEditAlert = true
                                }
                        }
                    }
                    .onDelete { offsets in
                        vm.deleteItems(context: viewContext, offsets: offsets, folder: folder)
                    }
                }
                .padding(.top, 20)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .padding(.horizontal, 10)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            
            .onAppear {
                vm.fetchItems(context: viewContext, folder: folder)
            }
        }
        .alert("Редактировать товар", isPresented: $showEditAlert, actions: {
            TextField("Название товара", text: $editedText)
            Button("Сохранить") {
                if let item = selectedItem {
                    vm.updateItem(context: viewContext, item: item, newText: editedText, folder: folder)
                }
            }
            Button("Отмена", role: .cancel) {}
        }, message: {
            Text("Измените название товара")
        })
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let testFolder = Folder(context: context)
    testFolder.name = "Demo"
    
    return NotesView(folder: testFolder)
        .environment(\.managedObjectContext, context)
}
