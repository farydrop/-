//
//  AddBottomSheet.swift
//  LanguageLearningApp
//
//  Created by Farida on 02.12.2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct AddBottomSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var fileName: String = ""
    @State private var selectedOriginalLanguage: String = "EN"
    @State private var selectedTranslationLanguage: String = "RU"
    @State private var uploadedFileName: String?
    //wtf
    
    let languages = ["EN", "RU", "ES", "FR", "GR", "IT", "DE"]
    
    @State private var isFilePickerPresented = false
    @State private var fileContent: String = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            // Заголовок
            Text("Add New File")
                .font(.headline)
                .padding()
            
            // Поле ввода названия файла
            TextField("Enter file name", text: $fileName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Загрузка файла
            Button(action: {
                isFilePickerPresented = true
            }) {
                HStack {
                    Image(systemName: "doc.fill")
                    Text(uploadedFileName ?? "Upload SRT or TXT file")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .sheet(isPresented: $isFilePickerPresented) {
                FilePicker(uploadedFileName: $uploadedFileName, fileContent: $fileContent, onComplete: sendGuessLanguageRequest)
            }
            
            if isLoading {
                ProgressView("Detecting language...")
                    .padding()
            }
            
            // Выбор языка оригинала
            HStack {
                Text("Original Language:")
                Spacer()
                Picker("Original Language", selection: $selectedOriginalLanguage) {
                    ForEach(languages, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Выбор языка перевода
            HStack {
                Text("Translation Language:")
                Spacer()
                Picker("Translation Language", selection: $selectedTranslationLanguage) {
                    ForEach(languages, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.horizontal)
            .padding(.top)
            
            Spacer()
            
            // Кнопка Готово
            Button(action: {
                addFile()
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "checkmark")
                Text("Accept")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(fileName.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(fileName.isEmpty)
            .padding()
            
        }
        .padding(.top)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
    
    private func sendGuessLanguageRequest(content: String) {
        isLoading = true
        let trimmedContent = content.components(separatedBy: .whitespacesAndNewlines).prefix(10).joined(separator: " ")
        
        guard let url = URL(string: "https://api.readyto.study/v1/subtitles/guess_language") else {
            print("Invalid URL")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["text_sample": trimmedContent]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                print("Error making request: \(error)")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Error with response")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let lang = json["lang"] as? String {
                    DispatchQueue.main.async {
                        selectedOriginalLanguage = lang
                    }
                }
            } catch {
                print("Error parsing response: \(error)")
            }
        }.resume()
    }
    
    private func addFile() {
        guard let url = URL(string: "https://api.readyto.study/v1/subtitles/upload") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = createMultipartBody(
            boundary: boundary,
            parameters: [
                "source_language": selectedOriginalLanguage,
                "target_language": selectedTranslationLanguage,
                "name": fileName
            ],
            fileData: fileContent.data(using: .utf8) ?? Data(),
            fileName: uploadedFileName ?? "file.txt",
            mimeType: "text/plain"
        )

        request.httpBody = body

        isLoading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                print("Error making request: \(error)")
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Error with response")
                return
            }

            print("File uploaded successfully")
            if let result = String(data: data, encoding: .utf8) {
                print("Response: \(result)")
            }
        }.resume()
    }

    private func createMultipartBody(
        boundary: String,
        parameters: [String: String],
        fileData: Data,
        fileName: String,
        mimeType: String
    ) -> Data {
        var body = Data()

        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")

        return body
    }


}


struct AddBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddBottomSheet()
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

