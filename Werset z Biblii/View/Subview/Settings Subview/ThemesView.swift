//
//  ThemesView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 02/07/2025.
//

import SwiftUI

struct ThemesView: View {
    
    @EnvironmentObject private var viewModel: VersesViewModel
    
    var body: some View {
        Text("ThemesView")
    }
}

#Preview {
    ThemesView()
        .environmentObject(VersesViewModel())
}
