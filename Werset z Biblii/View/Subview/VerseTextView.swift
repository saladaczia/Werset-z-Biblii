//
//  VerseTextView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 27/06/2025.
//

import SwiftUI

struct VerseTextView: View {
    
    // ViewModel
    @EnvironmentObject private var vm: VersesViewModel
   
    
    var body: some View {
        VStack {
            // Text verse
            Text(vm.currentVerse?.date ?? "Błąd")
                .font(.custom("Times New Roman", size: 25))
                .bold()
                    .foregroundStyle(vm.isDarkBackground ? .white : .black)
                    .shadow(color: vm.isDarkBackground ? .black : .white, radius: 10)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
            
            Text(vm.currentVerse?.message ?? "Błąd")
                .font(.custom("Times New Roman", size: 20))
                .foregroundStyle(vm.isDarkBackground ? .white : .black)
                .shadow(color: vm.isDarkBackground ? .black : .white, radius: 10)
                .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
            
            
            Text(vm.currentVerse?.verse ?? "Błąd")
                    .font(.custom("HappyTime", size: 22))
                    .foregroundStyle(vm.isDarkBackground ? .white : .black)
                    .shadow(color: vm.isDarkBackground ? .black : .white, radius: 10)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
            
            HStack {
                Spacer()
                // Reference verse
                Text(vm.currentVerse?.reference ?? "Błąd")
                        .font(.callout)
                        .foregroundStyle(Color(vm.isDarkBackground ? "textLightGray" : "textDarkGray"))
                        .shadow(color: vm.isDarkBackground ? .black : .white, radius: 10)
                        .padding(.trailing, 40)
                        .padding(.bottom, 20)
                
            }
            
            Spacer()
            
        }
        .padding(.top, 70)
        .padding(.bottom, 20)
        .ignoresSafeArea()
    }
}

#Preview {
    VerseTextView()
        .environmentObject(VersesViewModel())
}
