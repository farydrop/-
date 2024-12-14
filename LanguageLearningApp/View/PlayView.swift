//
//  PlayView.swift
//  LanguageLearningApp
//
//  Created by Farida on 04.12.2024.
//

import SwiftUI

struct PlayView: View {
    @FetchRequest(
        entity: TranslationResultEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TranslationResultEntity.reviewDate, ascending: true)],
        predicate: NSPredicate(format: "reviewDate <= %@", Date() as NSDate)
    ) var wordsFromFetchRequest: FetchedResults<TranslationResultEntity>

    var wordsForTesting: [TranslationResultEntity]?

    @Environment(\.presentationMode) private var presentationMode
    @State private var currentWordIndex = 0
    @State private var isAnimating = false
    @State private var cardOffset: CGSize = .zero // Для отслеживания свайпа
    @State private var isFlipped = false

    private var words: [TranslationResultEntity] {
        wordsForTesting ?? Array(wordsFromFetchRequest)
    }

    var body: some View {
        NavigationView {
            VStack {
                if words.isEmpty {
                    Text("No words to study")
                        .font(.title)
                        .foregroundColor(.gray)
                } else {
                    ZStack {
                        HStack {
                            Text("known ✅")
                                .font(.title3)
                                .foregroundColor(.green)
                                .opacity(textOpacity(for: .right))
                                .rotationEffect(.degrees(-15))
                                .padding(.leading)

                            Spacer()

                            Text("unknown ❌")
                                .font(.title2)
                                .foregroundColor(.red)
                                .opacity(textOpacity(for: .left))
                                .rotationEffect(.degrees(15))
                                .padding(.trailing)
                        }
                        .padding()

                        CardView(word: words[currentWordIndex],
                                 offset: $cardOffset,
                                 isAnimating: $isAnimating,
                                 isFlipped: $isFlipped) { direction in
                            if direction == .right {
                                markWordAsKnown(word: words[currentWordIndex])
                            } else if direction == .left {
                                markWordAsUnknown(word: words[currentWordIndex])
                            }
                            withAnimation {
                                showNextWord()
                                isAnimating = false
                                cardOffset = .zero
                                isFlipped = false
                            }
                        }
                    }
                }
            }
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func markWordAsKnown(word: TranslationResultEntity) {
        word.score += 10
        if word.score >= 100 {
            word.reviewDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        }
        saveContext()
    }

    private func markWordAsUnknown(word: TranslationResultEntity) {
        word.score = max(0, word.score - 30)
        word.reviewDate = Date()
        saveContext()
    }

    private func showNextWord() {
        if currentWordIndex < words.count - 1 {
            currentWordIndex += 1
        } else {
            currentWordIndex = 0
        }
        isFlipped = false
    }

    private func saveContext() {
        do {
            try words[currentWordIndex].managedObjectContext?.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }

    private func textOpacity(for direction: CardView.SwipeDirection) -> Double {
        if direction == .right {
            return max(0, min(1, cardOffset.width / 150))
        } else if direction == .left {
            return max(0, min(1, -cardOffset.width / 150))
        }
        return 0
    }
}



struct CardView: View {
    let word: TranslationResultEntity
    @Binding var offset: CGSize
    @Binding var isAnimating: Bool
    @Binding var isFlipped: Bool
    let onSwipe: (SwipeDirection) -> Void

    enum SwipeDirection {
        case left, right
    }

    var body: some View {
        ZStack {
            if !isFlipped {
                // Передняя сторона (оригинал слова)
                VStack {
                    if word.score < 20 {
                        Text(word.original ?? "Unknown")
                            .font(.largeTitle)
                            .padding()
                    } else if word.score < 40 {
                        Text(word.original ?? "Unknown")
                            .font(.largeTitle)
                            .blur(radius: 3) // Замыленное отображение
                            .padding()
                    } else if word.score < 60 {
                        Text("Context: \(word.context ?? "No context")")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .padding()
                    } else if word.score < 100 {
                        Text(word.original ?? "Unknown")
                            .font(.largeTitle)
                            .padding()
                    }
                }
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0), // Переворот текста вместе с карточкой
                    axis: (x: 0, y: 1, z: 0)
                )
            } else {
                // Задняя сторона (перевод слова)
                VStack {
                    Text(word.translate ?? "Unknown")
                        .font(.largeTitle)
                        .padding()
                        .rotation3DEffect(
                            .degrees(isFlipped ? -180 : 0), // Текст переворачивается обратно
                            axis: (x: 0, y: 1, z: 0)
                        )
                    if word.score >= 60 {
                        Text(word.original ?? "Unknown")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .padding(.top)
                            .rotation3DEffect(
                                .degrees(isFlipped ? -180 : 0), // Переворот текста обратно
                                axis: (x: 0, y: 1, z: 0)
                            )
                    }
                }
            }
        }
        .frame(maxWidth: 300, maxHeight: 400)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: shadowColor(), radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor(), lineWidth: 3)
        )
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0), // Анимация переворота карточки
            axis: (x: 0, y: 1, z: 0)
        )
        .onTapGesture {
            withAnimation {
                isFlipped.toggle()
            }
        }
        .offset(x: offset.width, y: 0)
        .rotationEffect(.degrees(Double(offset.width / 10)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if offset.width > 150 {
                        isAnimating = true
                        onSwipe(.right)
                    } else if offset.width < -150 {
                        isAnimating = true
                        onSwipe(.left)
                    } else {
                        withAnimation {
                            offset = .zero
                        }
                    }
                }
        )
        .animation(.spring(), value: offset)
        .opacity(isAnimating ? 0 : 1)
    }

    private func shadowColor() -> Color {
        if offset.width > 0 {
            return Color.green.opacity(0.5)
        } else if offset.width < 0 {
            return Color.red.opacity(0.5)
        } else {
            return Color.gray.opacity(0.3)
        }
    }

    private func borderColor() -> Color {
        if offset.width > 0 {
            return Color.green
        } else if offset.width < 0 {
            return Color.red
        } else {
            return Color.clear
        }
    }
}



struct StudyWordsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext

        let word1 = TranslationResultEntity(context: context)
        word1.original = "Hello"
        word1.translate = "Привет"
        word1.context = "A common greeting."
        word1.score = 10
        word1.reviewDate = Date()

        let word2 = TranslationResultEntity(context: context)
        word2.original = "World"
        word2.translate = "Мир"
        word2.context = "A word representing the Earth."
        word2.score = 30
        word2.reviewDate = Date()

        let word3 = TranslationResultEntity(context: context)
        word3.original = "Swift"
        word3.translate = "Свифт"
        word3.context = "A programming language."
        word3.score = 50
        word3.reviewDate = Date()

        return NavigationView {
            PlayView(wordsForTesting: [word1, word2, word3])
        }
    }
}
