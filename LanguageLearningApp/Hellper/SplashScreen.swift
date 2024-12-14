//
//  SplashScreen.swift
//  LanguageLearningApp
//
//  Created by Farida on 02.12.2024.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        VStack {
            Image(systemName: "sparkles")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Welcome to the App")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea()
    }
}

#Preview {
    SplashScreen()
}
