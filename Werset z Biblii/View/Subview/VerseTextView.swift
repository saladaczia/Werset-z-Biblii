//
//  VerseTextView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 27/06/2025.
//

import SwiftUI

struct VerseTextView: View {
    
    @EnvironmentObject private var viewModel: VersesViewModel
   
    var body: some View {
        VStack {
            // Text verse
                Text(viewModel.verses[0].text)
                    .font(.custom("HappyTime", size: 22))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
            
            
            HStack {
                Spacer()
                // Reference verse
                    Text(viewModel.verses[0].reference)
                        .font(.callout)
                        .foregroundStyle(.black)
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
