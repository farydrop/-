//
//  SplashScreenView.swift
//  LanguageLearningApp
//
//  Created by Farida on 02.12.2024.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isSplashScreenActive = true // Управление отображением сплэшскрина

    var body: some View {
        Group {
            if isSplashScreenActive {
                SplashScreen()
            } else {
                TabView {
                    FileListView()
                        .tabItem {
                            Label("Files", systemImage: "folder")
                        }
                    
                    AllWordsView()
                        .tabItem {
                            Label("All Words", systemImage: "text.book.closed")
                        }
                }
            }
        }
        .onAppear {
            // Задержка для сплэшскрина
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isSplashScreenActive = false
                }
            }
        }
    }
}

// Preview для сплэшскрина
#Preview {
    SplashScreenView()
}

