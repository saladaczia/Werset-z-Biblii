//
//  ThemesView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 02/07/2025.
//

import SwiftUI

struct ThemesView: View {
    
    // ViewModel
    @EnvironmentObject private var viewModel: VersesViewModel
    
    // colums for LazyVGrid
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Section illustrations
                    HStack {
                        Text("Ilustracja")
                            .foregroundStyle(Color.accentColor)
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    
                    // Themes grid (illustrations)
                    HStack {
                        Grid {
                            GridRow {
                                ForEach(viewModel.illustrationsBgName, id: \.self) { item in
                                    Image(item)
                                        .resizable()
                                        .frame(maxWidth: .infinity, maxHeight: 200)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(viewModel.selectedBackground == item ? Color.blue : Color.clear, lineWidth: 4)
                                        )
                                        .onTapGesture {
                                            viewModel.selectedBackground = item
                                        }
                                }
                            }
                        }
                    }
                    
                    // Section nature
                    HStack {
                        Text("Natura")
                            .foregroundStyle(Color.accentColor)
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    // Theme grid (Nature)
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.natureBgName, id: \.self) { item in
                            Image(item)
                                .resizable()
                                .frame(maxWidth: .infinity, maxHeight: 200)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(viewModel.selectedBackground == item ? Color.blue : Color.clear, lineWidth: 4)
                                )
                                .onTapGesture {
                                    viewModel.selectedBackground = item
                                }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Motywy")
    }
}

#Preview {
    ThemesView()
        .environmentObject(VersesViewModel())
}
