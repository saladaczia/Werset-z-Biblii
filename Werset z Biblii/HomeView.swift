//
//  TestDesign.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 24/06/2025.
//

import SwiftUI

struct TestDesign: View {
    
    // MARK: - Stan widoku
    @State var onClicked: Bool = false
    @State var onClickedHearth: Bool = false
    @State var onClickedBg: Bool = false
    
    // MARK: - Teksty biblijne
    let verse1Text = "Ci, którzy zaufali Panu, odzyskują siły, otrzymują skrzydła jak orły; biegną bez zmęczenia, bez znużenia idą."
    let verse1Ref = "IZAJASZ 40:31"
    
    let verse2Text = "Nie lękaj się, bo Ja jestem z tobą, nie trwóż się, bo Ja jestem twoim Bogiem! Umacniam cię, tak, pomagam ci, podtrzymuję cię prawicą mej sprawiedliwości."
    let verse2Ref = "Izajasz 41:10"
    
    // MARK: - Ciało widoku
    var body: some View {
        ZStack {
            // Tło – test zmiany
            Image(onClickedBg ? "background3" : "background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                // Główna część z tekstem
                VStack {
                    Text(onClickedBg ? verse2Text : verse1Text)
                        .font(.custom("HappyTime", size: 22))
                        .foregroundStyle(.black)
                        .padding(.vertical, 5)
                    HStack {
                        Spacer()
                        Text(onClickedBg ? verse2Ref : verse1Ref)
                            .font(.callout)
                            .foregroundStyle(.black)
                            .padding(.trailing, 20)
                }
                
                }
                .frame(height: UIScreen.main.bounds.height / 2)
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 40)
            
            // Nakładka UI z ikonami
            VStack {
                HStack {
                    // Ikona udostępniania
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                        .foregroundStyle(.black)
                        .opacity(onClicked ? 1.0 : 0.0)
                        .onTapGesture {
                            onClickedBg.toggle()
                        }
                    
                    Spacer()
                    
                    // Data
                    Text(formattedDate)
                        .font(.headline)
                        .foregroundStyle(.black)
                        .opacity(onClicked ? 1.0 : 0.0)
                    
                    Spacer()
                    
                    // Ikona serca
                    Image(systemName: onClickedHearth ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.black)
                        .opacity(onClicked ? 1.0 : 0.0)
                        .onTapGesture {
                            onClickedHearth.toggle()
                        }
                }
                .frame(width: UIScreen.main.bounds.width - 40)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Menu dolne
                HStack {
                    Image(systemName: "line.3.horizontal.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                        .foregroundStyle(.gray)
                        .opacity(onClicked ? 1.0 : 0.0)
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
            onClicked.toggle()
            print("Przełączono na \(onClicked)")
        }
        .onAppear {
                        AudioManager.shared.playBackgroundMusic()
                    }
    }
    
    // MARK: - Formatowana data (PL)
    var formattedDate: String {
         let formatter = DateFormatter()
         formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateStyle = .short // pokaże np. "wtorek, 24 czerwca 2025"
         formatter.timeStyle = .none
         return formatter.string(from: Date())
     }
    
}

// MARK: - Podgląd
#Preview {
    TestDesign()
}
