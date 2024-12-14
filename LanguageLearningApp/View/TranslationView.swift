//
//  TranslationView.swift
//  LanguageLearningApp
//
//  Created by Farida on 02.12.2024.
//

import SwiftUI


struct TranslationView: View {
    let file: FileEntity
    
    @State private var showContext: Bool = true
    @State private var showStudyView = false
    
    @FetchRequest var words: FetchedResults<TranslationResultEntity>
    
    init(file: FileEntity) {
        self.file = file
        // Инициализируем FetchRequest для получения связанных слов
        _words = FetchRequest(
            entity: TranslationResultEntity.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "file == %@", file)
        )
    }
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(words, id: \.self) { word in
                        WordCard(word: word, showContext: showContext)
                    }
                }
                .padding()
            }
            
            Button(action: {
                            showStudyView = true
                        }) {
                            Text("START")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
        }
        .navigationTitle(file.name ?? "Unknown File")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showStudyView) {
            PlayView(wordsForTesting: Array(words))
        }
    }
}

struct WordCard: View {
    let word: TranslationResultEntity
    let showContext: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(word.original ?? "N/A")
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(word.translate ?? "N/A")
                .font(.subheadline)
            if showContext {
                Text(word.context ?? "N/A")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}


struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        
        // Создаем пример FileEntity
        let exampleFile = FileEntity(context: context)
        exampleFile.name = "Example File"
        exampleFile.originalLanguage = "EN"
        exampleFile.translationLanguage = "RU"
        
        // Создаем пример WordEntity 1
        let word1 = TranslationResultEntity(context: context)
        word1.original = "Example"
        word1.translate = "Пример"
        word1.context = "This is an example context."
        word1.file = exampleFile
        
        // Создаем пример WordEntity 2
        let word2 = TranslationResultEntity(context: context)
        word2.original = "Test"
        word2.translate = "Тест"
        word2.context = "This is a test context."
        word2.file = exampleFile
        
        // Создаем пример WordEntity 3
        let word3 = TranslationResultEntity(context: context)
        word3.original = "Translation"
        word3.translate = "Перевод"
        word3.context = "This is a translation context."
        word3.file = exampleFile
        
        let word4 = TranslationResultEntity(context: context)
        word4.original = "Translation"
        word4.translate = "Перевод"
        word4.context = "This is a translation context."
        word4.file = exampleFile
        
        let word5 = TranslationResultEntity(context: context)
        word5.original = "Test"
        word5.translate = "Тест"
        word5.context = "This is a test context."
        word5.file = exampleFile
        
        return TranslationView(file: exampleFile)
            .environment(\.managedObjectContext, context)
    }
}


