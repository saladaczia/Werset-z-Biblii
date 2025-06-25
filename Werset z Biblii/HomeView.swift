//
//  TestDesign.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 24/06/2025.
//

import SwiftUI

struct TestDesign: View {
    // MARK: - Stan widoku
    @State private var showUIOverlay: Bool = false
    @State private var isHeartSelected: Bool = false
    @State private var useAltBackground: Bool = false

    // MARK: - Teksty biblijne
    private let verse1Text = "Ci, którzy zaufali Panu, odzyskują siły, otrzymują skrzydła jak orły; biegną bez zmęczenia, bez znużenia idą."
    private let verse1Ref = "IZAJASZ 40:31"

    private let verse2Text = "Nie lękaj się, bo Ja jestem z tobą, nie trwóż się, bo Ja jestem twoim Bogiem! Umacniam cię, tak, pomagam ci, podtrzymuję cię prawicą mej sprawiedliwości."
    private let verse2Ref = "Izajasz 41:10"

    // MARK: - Ciało widoku
    var body: some View {
        ZStack {
            // Tło – zmienia się dynamicznie
            Image(useAltBackground ? "background3" : "background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            GeometryReader { geometry in
                VStack {
                    // Główna część z tekstem
                    VStack {
                        Text(useAltBackground ? verse2Text : verse1Text)
                            .font(.custom("HappyTime", size: 22))
                            .foregroundStyle(.black)
                            .padding(.vertical, 5)

                        HStack {
                            Spacer()
                            Text(useAltBackground ? verse2Ref : verse1Ref)
                                .font(.callout)
                                .foregroundStyle(.black)
                                .padding(.trailing, 20)
                        }
                    }
                    .frame(height: geometry.size.height / 2)

                    Spacer()
                }
                .frame(width: 360)

                // Nakładka UI z ikonami
                VStack {
                    HStack {
                        // Ikona udostępniania
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 38, height: 38)
                            .foregroundStyle(.black)
                            .opacity(showUIOverlay ? 1.0 : 0.0)
                            .onTapGesture {
                                withAnimation {
                                    useAltBackground.toggle()
                                }
                            }

                        Spacer()

                        // Data
                        Text(formattedDate)
                            .font(.headline)
                            .foregroundStyle(.black)
                            .opacity(showUIOverlay ? 1.0 : 0.0)

                        Spacer()

                        // Ikona serca
                        Image(systemName: isHeartSelected ? "heart.fill" : "heart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.black)
                            .opacity(showUIOverlay ? 1.0 : 0.0)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    isHeartSelected.toggle()
                                }
                            }
                    }
                    .frame(width: 360)
                    .padding(.horizontal, 30)

                    Spacer()

                    // Menu dolne
                    HStack {
                        Image(systemName: "line.3.horizontal.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 38, height: 38)
                            .foregroundStyle(.gray)
                            .opacity(showUIOverlay ? 1.0 : 0.0)
                            .onTapGesture {
                                withAnimation {
                                    useAltBackground.toggle()
                                }
                            }
                        Spacer()
                    }
                    .frame(width: 360)
                    .padding(.horizontal, 30)
                }
            }
        }
        .onTapGesture {
            withAnimation {
                showUIOverlay.toggle()
            }
            print("Przełączono UI overlay na: \(showUIOverlay)")
        }
        .onAppear {
            AudioManager.shared.playBackgroundMusic()
        }
    }

    // MARK: - Formatowana data (PL)
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateStyle = .full // np. "wtorek, 25 czerwca 2025"
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }
}

// MARK: - Podgląd
#Preview {
    TestDesign()
}
