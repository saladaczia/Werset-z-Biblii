//
//  HomeView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 27/06/2025.
//

import SwiftUI

struct HomeView: View {
    
    // ViewModel
    @EnvironmentObject private var viewModel: VersesViewModel
    
    // Screen size area
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    // Show buttons
    @State private var showButtonsView: Bool = false
    // Animate verse text
    @State private var animateShowVerseText: Bool = false
    
    
    
    var body: some View {
    
        // Main ZStack
        ZStack {
            // Background
            Image(viewModel.selectedBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .frame(width: screenWidth, height: screenHeight)
            
            // Main VStack
            VStack {
                // Varse text View
                VerseTextView()
                    .opacity(animateShowVerseText ? 1 : 0)
                    .animation(.easeInOut(duration: 4.0), value: animateShowVerseText)
                Spacer()
            }
            .frame(width: screenWidth, height: screenHeight)
            
            // Buttons View
            ButtonsView(onClickedSettings: $viewModel.onClickedSettings)
                .opacity(showButtonsView ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.5), value: showButtonsView)
            
            // Settings View sheet
                .sheet(isPresented: $viewModel.onClickedSettings) {
                    SettingView()
                }
        }
        .onTapGesture {
            // Animate for showing buttons
            withAnimation {
                showButtonsView.toggle()
            }
        }
        .onAppear {
            // Animate for showing text
                withAnimation {
                    animateShowVerseText = true
                }
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(VersesViewModel())
}

