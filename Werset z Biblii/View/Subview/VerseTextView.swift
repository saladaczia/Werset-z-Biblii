//
//  VerseTextView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 27/06/2025.
//

import SwiftUI

struct VerseTextView: View {
    
    @Binding var verses: [(String, String)]
    
    var body: some View {
        VStack {
                Text(verses[0].0)
                    .font(.custom("HappyTime", size: 22))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
            
            
            HStack {
                Spacer()
                    Text(verses[0].1)
                        .font(.callout)
                        .foregroundStyle(.black)
                        .padding(.trailing, 20)
                
            }
        }
        .frame(height: UIScreen.main.bounds.height / 2)
    }
}

#Preview {
    @Previewable @State var sampleVerses = [("Nie lękaj się, bo Ja jestem z tobą, nie trwóż się, bo Ja jestem twoim Bogiem!", "Ref testowy")]
    return VerseTextView(verses: $sampleVerses)
}
