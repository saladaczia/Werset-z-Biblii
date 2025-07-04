//
//  RemindersView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 02/07/2025.
//

import SwiftUI

struct RemindersView: View {
    
    // ViewModel
    @EnvironmentObject private var viewModel: VersesViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Toggle(isOn: .constant(true)) {
                    Text("Codzienne Powiadomienia")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                    Text("Codziennie otrzymujesz powiadomienia o nowych wersach")
                        .font(.caption)
                        .frame(maxWidth: 250, alignment: .leading)
                }
                .tint(.accentColor)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .navigationTitle("Powiadomienia")
    }
}

#Preview {
    RemindersView()
        .environmentObject(VersesViewModel())
}
