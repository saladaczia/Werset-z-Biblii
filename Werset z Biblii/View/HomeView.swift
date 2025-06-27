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
    
    // Verse test text
    @State var verses = [
        (
            "Ci, którzy zaufali Panu, odzyskują siły, otrzymują skrzydła jak orły; biegną bez zmęczenia, bez znużenia idą.",
            "IZAJASZ 40:31"
        ),
        (
            "Nie lękaj się, bo Ja jestem z tobą, nie trwóż się, bo Ja jestem twoim Bogiem! Umacniam cię, tak, pomagam ci, podtrzymuję cię prawicą mej sprawiedliwości.",
            "Izajasz 41:10"
        )
    ]
    
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
                VerseTextView(verses: $verses)
                    .opacity(animateShowVerseText ? 1 : 0)
                    .animation(.easeInOut(duration: 4.0), value: animateShowVerseText)
                Spacer()
            }
            .frame(width: screenWidth, height: screenHeight)
            
            // Buttons View
            ButtonsView()
                .opacity(showButtonsView ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.5), value: showButtonsView)
                
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

