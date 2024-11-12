import SwiftUI
import CoreData

struct LevelThreeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var currentWord: Word?
    @State private var userInput: String = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var resultText = ""
    @State private var backgroundColor = Color.white
    @State private var answeredWords: Set<Word> = []
    @State private var allWordsCompleted = false

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut, value: backgroundColor)

            if allWordsCompleted {
                VStack {
                    Text("Gratulacje!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding()
                    Text("Ukończyłeś wszystkie słowa na tym poziomie.")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            } else if showResult {
                VStack {
                    Spacer()
                    Text(resultText)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()

                    if !isCorrect {
                        Text("Poprawna odpowiedź: \(currentWord?.english ?? "")")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }

                    if !isCorrect {
                        Button(action: {
                            nextQuestion()
                        }) {
                            Text("Następne pytanie")
                                .font(.title2)
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .keyboardShortcut(.defaultAction) // Obsługa klawisza Enter
                    }
                    Spacer()
                }
            } else if let currentWord = currentWord {
                VStack(spacing: 20) {
                    Spacer()
                    Text(currentWord.polish ?? "Brak słowa")
                        .font(.largeTitle)
                        .padding()

                    TextField("Wpisz tłumaczenie", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                        .padding()
                        .focused($isTextFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            checkAnswer()
                        }

                    Button(action: {
                        checkAnswer()
                    }) {
                        Text("Sprawdź")
                            .font(.title2)
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding()
                .onAppear {
                    isTextFieldFocused = true // Automatyczne skupienie na polu tekstowym
                }
            } else {
                Text("Brak słów w bazie danych.")
            }
        }
        .onAppear {
            loadNewWord()
        }
    }

    func checkAnswer() {
        isTextFieldFocused = false // Ukrycie klawiatury po sprawdzeniu odpowiedzi

        if userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == currentWord?.english?.lowercased() {
            isCorrect = true
            resultText = "Poprawna odpowiedź"
            backgroundColor = Color.green

            if let currentWord = currentWord {
                answeredWords.insert(currentWord)
            }

            showResult = true
            userInput = "" // Czyszczenie pola tekstowego

            checkIfAllWordsCompleted()

            // Automatyczne przejście do następnego pytania po 3 sekundach
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if !allWordsCompleted {
                    nextQuestion()
                }
            }
        } else {
            isCorrect = false
            resultText = "Niepoprawna odpowiedź"
            backgroundColor = Color.red
            showResult = true
            userInput = "" // Czyszczenie pola tekstowego
        }
    }

    func nextQuestion() {
        backgroundColor = Color.white
        showResult = false
        userInput = ""
        loadNewWord()
        isTextFieldFocused = true // Skupienie na polu tekstowym dla nowego pytania
    }

    func loadNewWord() {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.predicate = nil

        do {
            let words = try viewContext.fetch(fetchRequest)

            // Filtruj słowa, które zostały już zaliczone
            let remainingWords = words.filter { !answeredWords.contains($0) }

            if remainingWords.isEmpty {
                currentWord = nil
                allWordsCompleted = true
                return
            }

            currentWord = remainingWords.randomElement()
        } catch {
            print("Błąd podczas pobierania danych z Core Data: \(error.localizedDescription)")
        }
    }

    func checkIfAllWordsCompleted() {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.predicate = nil

        do {
            let totalWords = try viewContext.fetch(fetchRequest)
            if answeredWords.count >= totalWords.count {
                allWordsCompleted = true
            }
        } catch {
            print("Błąd podczas sprawdzania liczby słów: \(error.localizedDescription)")
        }
    }
}
