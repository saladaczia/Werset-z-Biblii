//
//  TestDesign.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 24/06/2025.
//

import SwiftUI

struct TestDesign: View {
    
    @State var onClicked: Bool = false
    @State var onClickedHearth: Bool = false
    @State var onClickedBg: Bool = false
     let text1 = "Ci, którzy zaufali Panu, odzyskują siły, otrzymują skrzydła jak orły; biegną bez zmęczenia, bez znużenia idą."
     let ver1 = "IZAJASZ 40:31"
    let text2 = "Nie lękaj się, bo Ja jestem z tobą, nie trwóż się, bo Ja jestem twoim Bogiem! Umacniam cię, tak, pomagam ci, podtrzymuję cię prawicą mej sprawiedliwości."
    let ver2 = "Izajasz 41:10"
    
    var body: some View {
        ZStack {
            Image(onClickedBg ? "background3" : "background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack {
                VStack {
                    Text(onClickedBg ? text2 : text1)
                        .font(.custom("HappyTime", size: 22))
                        .foregroundStyle(.black)
                        .padding(.vertical, 5)
                    HStack {
                        Spacer()
                        Text(onClickedBg ? ver2 : ver1)
                            .font(.callout)
                            .foregroundStyle(.black)
                            .padding(.trailing, 20)
                }
                
                }
                .frame(height: UIScreen.main.bounds.height / 2)
                Spacer()
            }
            .frame(width: 360)
            
            VStack {
                HStack {
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
                    Text(formattedDate)
                        .font(.headline)
                        .foregroundStyle(.black)
                    
                    .opacity(onClicked ? 1.0 : 0.0)
                    Spacer()
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
                .frame(width: 360)
                .padding(.horizontal, 30)
                Spacer()
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
                .frame(width: 360)
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
    
    var formattedDate: String {
         let formatter = DateFormatter()
         formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateStyle = .short // pokaże np. "wtorek, 24 czerwca 2025"
         formatter.timeStyle = .none
         return formatter.string(from: Date())
     }
    
}

#Preview {
    TestDesign()
}
