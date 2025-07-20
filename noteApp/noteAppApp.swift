//
//  noteAppApp.swift
//  noteApp
//
//  Created by Андрей Чучупал on 20.07.2025.
//

import SwiftUI

@main
struct noteAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
