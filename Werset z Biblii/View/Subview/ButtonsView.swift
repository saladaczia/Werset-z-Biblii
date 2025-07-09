//
//  ButtonsView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 27/06/2025.
//

import SwiftUI

struct ButtonsView: View {
    
    // ViewModel
    @EnvironmentObject private var vm: VersesViewModel
    
    //@State private var onClickedHearth: Bool = false
    @Binding var onClickedSettings: Bool
    
    
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
                // Settings icon
                Image(systemName: "gearshape")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(vm.isDarkBackground ? .white : .black)
                    .onTapGesture {
                        withAnimation {
                            onClickedSettings.toggle()
                            print("Open settings view")
                        }
                        
                    }
                Spacer()
                
                // Data
                Text(formattedDate)
                    .font(.headline)
                    .foregroundStyle(vm.isDarkBackground ? .white : .black)
                Spacer()
                
                if let verse = vm.currentVerse {
                    ShareLink(item: "„\(verse.text)” – \(verse.reference)") {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(vm.isDarkBackground ? .white : .black)
                    }
                }
                
            }
            Spacer()
            
        }
        .padding(.top, 40)
        .padding(.horizontal, 20)
    }
}

#Preview {
    @Previewable @State var sampleClickedSettings: Bool = false
    return ButtonsView(onClickedSettings: $sampleClickedSettings)
        .environmentObject(VersesViewModel())
    
}
