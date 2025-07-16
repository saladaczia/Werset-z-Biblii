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
            
            Text(vm.currentVerse?.verse ?? "Błąd")
                    .font(.custom("Times New Roman", size: 22))
                    .italic()
                    .foregroundStyle(vm.isDarkBackground ? .white : .black)
                    .shadow(color: vm.isDarkBackground ? .black : .white, radius: 10)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
                    .padding(.bottom, 2)
                    .padding(.horizontal, 20)
            
            HStack {
                Spacer()
                // Reference verse
                Text(vm.currentVerse?.reference ?? "Błąd")
                        .font(.custom("Times New Roman", size: 18))
                        .bold()
                        .foregroundStyle(vm.isDarkBackground ? .white : .black)
                        .shadow(color: vm.isDarkBackground ? .black : .white, radius: 10)
                        .padding(.trailing, 60)
                        .padding(.bottom, 20)
                
            }
            // Line
            Divider()
                .frame(height: 1)
                .background(Color.gray.opacity(0.3))
                .padding(.horizontal, 80)
            
            // Text message
            Text(vm.currentVerse?.message ?? "Błąd")
                .font(.custom("Times New Roman", size: 20))
                .foregroundStyle(vm.isDarkBackground ? .white : .black)
                .shadow(color: vm.isDarkBackground ? .black : .white, radius: 10)
                .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
            
            
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
