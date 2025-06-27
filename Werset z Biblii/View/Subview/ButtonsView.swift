//
//  ButtonsView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 27/06/2025.
//

import SwiftUI

struct ButtonsView: View {
    
    @State private var onClickedHearth: Bool = false
    
    // Date formetter
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }
    
    var body: some View {
        VStack {
            HStack {
                // Gear icon
                Image(systemName: "gearshape")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.black)
                
                Spacer()
                
                // Data
                Text(formattedDate)
                    .font(.headline)
                    .foregroundStyle(.black)
                Spacer()
                
                // Heart icon
                Image(systemName: onClickedHearth ? "heart.fill" : "heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.black)
                    .onTapGesture {
                        onClickedHearth.toggle()
                    }
            }
            Spacer()
        }
        .padding(.top, 40)
        .padding(.horizontal, 20)
    }
}
