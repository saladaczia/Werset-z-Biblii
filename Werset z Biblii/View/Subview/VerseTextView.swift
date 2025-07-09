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
            Text(vm.currentVerse?.text ?? "Błąd")
                    .font(.custom("HappyTime", size: 22))
                    .foregroundStyle(vm.isDarkBackground ? .white : .black)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
            
            
            HStack {
                Spacer()
                // Reference verse
                Text(vm.currentVerse?.reference ?? "Błąd")
                        .font(.callout)
                        .foregroundStyle(Color(vm.isDarkBackground ? "textLightGray" : "textDarkGray"))
                        .padding(.trailing, 40)
                
            }
        }
        .frame(height: UIScreen.main.bounds.height / 2)
    }
}

#Preview {
    VerseTextView()
        .environmentObject(VersesViewModel())
}
