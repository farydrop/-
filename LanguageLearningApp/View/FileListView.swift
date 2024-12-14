//
//  FileListView.swift
//  LanguageLearningApp
//
//  Created by Farida on 02.12.2024.
//

import SwiftUI

struct FileListView: View {
    
    
    @FetchRequest(
        entity: FileEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FileEntity.name, ascending: true)]
    ) var files: FetchedResults<FileEntity>
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showAddFileSheet = false

    var body: some View {
        NavigationView {
            Group {
                if files.isEmpty {
                    VStack {
                        Text("No files")
                            .font(.title)
                            .foregroundColor(.black)
                
                        Text("You haven't uploaded anything yet.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showAddFileSheet.toggle()
                        }) {
                            HStack {
                                Text("Add File")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                } else {
                    List {
                        ForEach(files, id: \.self) { file in
                            NavigationLink(destination: TranslationView(file: file)) {
                                FileView(file: file)
                            }
                        }
                        .onDelete(perform: deleteFile)
                    }
                }
            }
            .navigationTitle("Files")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddFileSheet.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddFileSheet) {
                AddBottomSheet()
            }
        }
    }

    private func deleteFile(at offsets: IndexSet) {
        offsets.map { files[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }
}

// Preview для визуализации
struct FileListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext

//        // Пример данных
        let exampleFile1 = FileEntity(context: context)
        exampleFile1.name = "Example File 1"
        exampleFile1.originalLanguage = "EN"
        exampleFile1.translationLanguage = "RU"
        

        return FileListView()
            .environment(\.managedObjectContext, context)
    }
}

