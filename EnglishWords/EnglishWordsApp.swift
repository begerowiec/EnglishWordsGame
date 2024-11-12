//
//  EnglishWordsApp.swift
//  EnglishWords
//
//  Created by Adrian on 12/11/2024.
//

import SwiftUI

@main
struct EnglishWordsApp: App {
    @StateObject private var dataController = DataController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
