//
//  SettingView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 28/06/2025.
//

import SwiftUI

struct SettingView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack() {
                    
                    // Section theme
                    HStack {
                        // Theme setting label
                        Text("Wygląd")
                            .font(.title3)
                            .foregroundStyle(Color.accentColor)
                            .bold()
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Theme setting button
                    HStack {
                        NavigationLink {
                            EmptyView()
                        } label: {
                            Image(systemName: "paintpalette")
                                .font(.title2)
                                .foregroundStyle(.black)
                            Text("Wybór motywu")
                                .font(.headline)
                                .foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                    
                    // Section reminders
                    HStack {
                        // Reminders setting label
                        Text("Powiadomienia")
                            .font(.title3)
                            .foregroundStyle(Color.accentColor)
                            .bold()
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Reminders setting button
                    HStack {
                        NavigationLink {
                            EmptyView()
                        } label: {
                            Image(systemName: "bell")
                                .font(.title2)
                                .foregroundStyle(.black)
                            Text("Codzienne powiadomienie")
                                .font(.headline)
                                .foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                    
                    Spacer()
                }
                // Screen title
                .navigationTitle("Ustawienia")
                // Toolbar button exit from screen
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "xmark")
                            .onTapGesture {
                                dismiss()
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    SettingView()
        .environmentObject(VersesViewModel())
}
