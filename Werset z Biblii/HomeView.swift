//
//  TestDesign.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 24/06/2025.
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - Stany
    @State private var onClicked: Bool = false
    @State private var onClickedHearth: Bool = false
    @State private var onClickedBg: Bool = false
    
    @State private var currentVerseIndex: Int = 0
    @State private var showVerse: Bool = false
    
    // MARK: - Dane wersetów
    let verses = [
        (
            "Ci, którzy zaufali Panu, odzyskują siły, otrzymują skrzydła jak orły; biegną bez zmęczenia, bez znużenia idą.",
            "IZAJASZ 40:31"
        ),
        (
            "Nie lękaj się, bo Ja jestem z tobą, nie trwóż się, bo Ja jestem twoim Bogiem! Umacniam cię, tak, pomagam ci, podtrzymuję cię prawicą mej sprawiedliwości.",
            "Izajasz 41:10"
        )
    ]
    
    // MARK: - Ciało widoku
    var body: some View {
        ZStack {
            // Tło zmienne
            Image(onClickedBg ? "background3" : "background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                // Tekst weresetu i referencji
                VStack {
                        Text(verses[currentVerseIndex].0)
                            .font(.custom("HappyTime", size: 22))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 5)
                            .opacity(showVerse ? 1 : 0)
                            .animation(.easeInOut(duration: 4.0), value: showVerse)
                    
                    
                    HStack {
                        Spacer()
                            Text(verses[currentVerseIndex].1)
                                .font(.callout)
                                .foregroundStyle(.black)
                                .padding(.trailing, 20)
                                .opacity(showVerse ? 1 : 0)
                                .animation(.easeInOut(duration: 4.0), value: showVerse)
                        
                    }
                }
                .frame(height: UIScreen.main.bounds.height / 2)
                
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 40)
            
            // UI górny + dolny
            VStack {
                HStack {
                    // Ikona gear
                    Image(systemName: "gearshape")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.black)
                        .opacity(onClicked ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5), value: onClicked)
                        .onTapGesture {
                            onClickedBg.toggle()
                        }
                    
                    Spacer()
                    
                    // Data
                    Text(formattedDate)
                        .font(.headline)
                        .foregroundStyle(.black)
                        .opacity(onClicked ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5), value: onClicked)
                    
                    Spacer()
                    
                    // Serce
                    Image(systemName: onClickedHearth ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.black)
                        .opacity(onClicked ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5), value: onClicked)
                        .onTapGesture {
                            onClickedHearth.toggle()
                        }
                }
                .frame(width: UIScreen.main.bounds.width - 40)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Dolne menu
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .foregroundStyle(.gray)
                        .opacity(onClicked ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5), value: onClicked)
                        .onTapGesture {
                            onClickedBg.toggle()
                        }
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width - 40)
                .padding(.horizontal, 30)
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .onTapGesture {
            withAnimation {
                onClicked.toggle()
            }
            
            print("Przełączono na \(onClicked)")
        }
        .onAppear {
            
            
            // Animacja dla wersetu
                withAnimation {
                    showVerse = true
                }
            
        }
        }
    }
    
    // MARK: - Formatowana data (PL)
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }


// MARK: - Podgląd
#Preview {
    HomeView()
}
