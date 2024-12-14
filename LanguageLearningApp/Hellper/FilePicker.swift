//
//  FilePicker.swift
//  LanguageLearningApp
//
//  Created by Farida on 02.12.2024.
//

import SwiftUI
import UniformTypeIdentifiers


struct FilePicker: UIViewControllerRepresentable {
    @Binding var uploadedFileName: String?
    @Binding var fileContent: String
    let onComplete: (String) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.plainText, .text])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FilePicker

        init(_ parent: FilePicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }

            do {
                let content = try String(contentsOf: url)
                parent.fileContent = content
                parent.uploadedFileName = url.lastPathComponent
                parent.onComplete(content)
            } catch {
                print("Error reading file: \(error.localizedDescription)")
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("User cancelled document picker")
        }
    }
}
