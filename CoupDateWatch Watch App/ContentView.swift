//
//  ContentView.swift
//  CoupDateWatch Watch App
//
//  Created by mo on 2024-09-24.
//

import SwiftUI

struct ContentView: View {
    @State var lottieFile: String = "Streak"
    @ObservedObject var viewModel: LottieViewModel = .init()
    
    var body: some View {
        Image(uiImage: viewModel.image)
            .resizable()
            .scaledToFit()
            .onAppear {
                       self.viewModel.loadAnimationFromFile(filename: lottieFile)
                   }
    }
}

#Preview {
    ContentView()
}
