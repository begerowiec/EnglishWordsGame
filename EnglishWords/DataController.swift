//
//  DataController.swift
//  EnglishWords
//
//  Created by Adrian on 12/11/2024.
//


import Foundation
import CoreData

class DataController: ObservableObject {
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "EnglishWords")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error loading persistent stores: \(error.localizedDescription)")
            }
        }

        // Sprawdź, czy baza danych jest pusta
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        let count = (try? container.viewContext.count(for: fetchRequest)) ?? 0

        if count == 0 {
            preloadData()
        }
    }

    func preloadData() {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json") else {
            print("Błąd: Nie znaleziono pliku words.json w głównym pakiecie")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let words = try decoder.decode([WordJSON].self, from: data)

            print("Liczba słów załadowanych z JSON: \(words.count)")

            for wordJSON in words {
                let word = Word(context: container.viewContext)
                word.polish = wordJSON.polish
                word.english = wordJSON.english
                print("Dodano słowo: \(word.polish ?? "Brak") - \(word.english ?? "Brak")")
            }

            try container.viewContext.save()
            print("Dane zostały zapisane w Core Data.")
        } catch {
            print("Błąd podczas preładowania danych: \(error.localizedDescription)")
        }
    }

}


struct WordJSON: Codable {
    let polish: String
    let english: String
}
