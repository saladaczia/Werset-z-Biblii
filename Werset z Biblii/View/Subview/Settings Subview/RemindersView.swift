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
                Text("Reminders View")
                    .font(.title2)
                    .bold()
                Spacer()
            }
        }
        .navigationTitle("Powiadomienia")
    }
}

#Preview {
    RemindersView()
        .environmentObject(VersesViewModel())
}
