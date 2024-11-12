import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                LevelTile(level: 1)
                LevelTile(level: 2)
                LevelTile(level: 3)
                Spacer()
            }
            .navigationBarTitle("Wybierz Poziom", displayMode: .inline)
        }
    }
}

struct LevelTile: View {
    let level: Int

    var body: some View {
        NavigationLink(destination: destinationView()) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                Text("Level \(level)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(height: 100)
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    func destinationView() -> some View {
        if level == 3 {
            LevelThreeView()
        } else {
            LevelDetailView(level: level)
        }
    }
}
