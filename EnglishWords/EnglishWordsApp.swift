//
//  EnglishWordsApp.swift
//  EnglishWords
//
//  Created by Adrian on 12/11/2024.
//

import SwiftUI

@main
struct EnglishWordsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
