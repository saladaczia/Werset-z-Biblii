//
//  HomeView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 27/06/2025.
//

import SwiftUI

struct HomeView: View {
    
    
    // Screen size area
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    @State private var showButtonsView: Bool = false
    @State private var animateShowVerseText: Bool = false
    @State var onClickedSettings: Bool = false
    
    var body: some View {
    
        // Main ZStack
        ZStack {
            // Background
            Image("background")
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
            ButtonsView(onClickedSettings: $onClickedSettings)
                .opacity(showButtonsView ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.5), value: showButtonsView)
            
            // Settings View sheet
                .sheet(isPresented: $onClickedSettings) {
                    SettingView()
                }
            /*
            if onClickedSettings {
                SettingView()
                    .padding(.top, 100)
                    .transition(.move(edge: .bottom))
                    .animation(.default)
            }
*/
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
}

