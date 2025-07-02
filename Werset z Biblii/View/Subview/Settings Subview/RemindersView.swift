//
//  RemindersView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 02/07/2025.
//

import SwiftUI

struct RemindersView: View {
    
    @EnvironmentObject private var viewModel: VersesViewModel
    
    var body: some View {
        Text("RemindersView")
    }
}

#Preview {
    RemindersView()
        .environmentObject(VersesViewModel())
}
