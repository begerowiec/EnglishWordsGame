import SwiftUI
import CoreData

struct LevelDetailView: View {
    let level: Int

    @Environment(\.managedObjectContext) private var viewContext

    @State private var currentWord: Word?
    @State private var options: [String] = []
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var resultText = ""
    @State private var backgroundColor = Color.white

    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut, value: backgroundColor)

            VStack(spacing: 20) {
                if showResult {
                    Text(resultText)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                } else if let currentWord = currentWord {
                    Text(currentWord.polish ?? "Brak słowa")
                        .font(.largeTitle)
                        .padding()

                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            checkAnswer(selectedOption: option)
                        }) {
                            Text(option)
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    Text("Brak słów w bazie danych.")
                }
                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadNewWord()
        }
    }

    func checkAnswer(selectedOption: String) {
        if selectedOption == currentWord?.english {
            isCorrect = true
            resultText = "Poprawna odpowiedź"
            backgroundColor = Color.green
        } else {
            isCorrect = false
            resultText = "Niepoprawna odpowiedź"
            backgroundColor = Color.red
        }

        showResult = true

        // Po 3 sekundach przejdź do następnego pytania
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            backgroundColor = Color.white
            showResult = false
            loadNewWord()
        }
    }

    func loadNewWord() {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.predicate = nil

        do {
            let words = try viewContext.fetch(fetchRequest)

            if words.isEmpty {
                currentWord = nil
                return
            }

            currentWord = words.randomElement()
            guard let currentWord = currentWord else { return }

            let correctTranslation = currentWord.english ?? ""

            var otherWords = words.filter { $0.english != correctTranslation }
            otherWords.shuffle()
            let option1 = otherWords.popLast()?.english ?? ""
            let option2 = otherWords.popLast()?.english ?? ""

            options = [correctTranslation, option1, option2].shuffled()
        } catch {
            print("Błąd podczas pobierania danych z Core Data: \(error.localizedDescription)")
        }
    }
}
