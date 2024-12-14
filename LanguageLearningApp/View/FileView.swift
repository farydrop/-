//
//  FileView.swift
//  LanguageLearningApp
//
//  Created by Farida on 02.12.2024.
//

import SwiftUI
import CoreData

struct FileView: View {
    let file: FileEntity
    
    var body: some View {
        NavigationLink(destination: TranslationView(file: file)) {
            HStack {
                Text(file.name ?? "Unknown")
                    .font(.title2)
                
                Spacer()
                
                VStack {
                    HStack {
                        Text(file.originalLanguage ?? "Unknown")
                            .font(.caption)
                        Text("to")
                            .font(.caption)
                        Text(file.translationLanguage ?? "Unknown")
                            .font(.caption)
                    }
                    .padding(.leading, 4)
                    
                    HStack {
                        Text("3")
                            .font(.caption)
//                        Text(file.count ?? 0)
//                            .font(.caption)
                        Text("words")
                            .font(.caption)
                    }
                    .padding(.leading, 4)
                }
            }.padding()
        }
    }
}
struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        // Создаем пример RTFolderEntity для предпросмотра
        let context = PersistenceController.shared.container.viewContext
        let exampleFile = FileEntity(context: context)
        exampleFile.name = "Example Folder"
        exampleFile.originalLanguage = "EN"
        exampleFile.translationLanguage = "RU"
        
        return FileView(file: exampleFile)
    }
}
